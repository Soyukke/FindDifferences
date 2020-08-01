module FindDifferences

using Images

"""
2つの画像を見つけ出す
2つの画像は重ならない
widthを半分にして，探す
差分率が最小となる二つの矩形を探索する
"""
function find_two_images(fn_img; max_count=3)
    dn_img = dirname(fn_img)
    fn_img1 = joinpath(dn_img, "img1.png")
    fn_img2 = joinpath(dn_img, "img2.png")
    fn_img_diff = joinpath(dn_img, "img_diff.png")
    # size(img) => (height, width)
    img = load(fn_img)
    img1t = nothing
    img2t = nothing

    height_0, width_0 = size(img)
    height = height_0
    width = floor(Int, width_0 / 2)

    diff_rate_min = Inf
    count_no_update = 0

    # widthを小さくしていく
    # widthを小さくしていき，小さくしても最小値が更新されない場合はstop
    while width > 0 && count_no_update <= max_count
        @show width
        begin_idx_width_1 = 0 

        while begin_idx_width_1 + width < width_0
            # img1をずらしていく begin_idx_width_1を増やしていく
            begin_idx_width_1 += 1
            end_idx_width_1 = begin_idx_width_1 + width - 1
            # end_idx_width_1 + widthが元の画像サイズを超えていたらcontinue
            if end_idx_width_1 + width > width_0; continue; end
            img1 = img[1:height, begin_idx_width_1:end_idx_width_1]

            begin_idx_width_2 = 0 + end_idx_width_1
            while begin_idx_width_2 + width < width_0
                # img2をずらしていく
                begin_idx_width_2 += 1
                end_idx_width_2 = begin_idx_width_2 + width - 1
                img2 = img[1:height, begin_idx_width_2:end_idx_width_2]
                img_diff = img1 .- img2
                rgb_zero = zero(img_diff[1])
                # 差分が存在する面積を計算する
                is_diffs::BitArray{2} = img_diff .!= rgb_zero
                # 差分率 0 ~ 1
                diff_rate = sum(is_diffs) / length(is_diffs)
                if diff_rate < diff_rate_min
                    count_no_update = 0
                    diff_rate_min = diff_rate
                    @show diff_rate_min
                    # 画像を保存する
                    Images.save(fn_img1, img1)
                    Images.save(fn_img2, img2)
                    save_diff_image(fn_img_diff, img1, img2)
                    img1t = img1
                    img2t = img2
                end
            end
        end
        width -= 1
        count_no_update += 1
    end
    return img1t, img2t
end

"""
差分があるところを分かりやすくして保存する
"""
function save_diff_image(fn_img, img1, img2)
    img_diff = img1 .- img2
    rgb_zero = zero(img_diff[1])
    rgb_red = isa(rgb_zero, RGB) ? RGB(1, 0, 0) : RGBA(1, 0, 0, 0)
    # 差分があるところを塗り替える
    idx_diff = img_diff .!= rgb_zero
    img = copy(img1)
    img[idx_diff] .= rgb_red
    Images.save(fn_img, img)
end

end # module