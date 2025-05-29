function [best_block, dy, dx] = motion_estimate(curr_block, ref_frame, i, j)
    search_range = 4;
    best_score = Inf;
    best_block = zeros(8,8,3);
    dy = 0;
    dx = 0;

    for y = -search_range:search_range
        for x = -search_range:search_range
            ref_i = i + y;
            ref_j = j + x;

            if ref_i < 1 || ref_j < 1 || ref_i > 45 || ref_j > 60
                continue;
            end

            candidate = ref_frame{ref_i, ref_j};
            score = sum(abs(curr_block(:) - candidate(:)));

            if score < best_score
                best_score = score;
                best_block = candidate;
                dy = y;
                dx = x;
            end
        end
    end
end
