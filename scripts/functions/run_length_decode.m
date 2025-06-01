function vec = run_length_decode(rle)
    vec = [];
    for i = 1:2:length(rle)-1
        count = rle(i);
        value = rle(i+1);
        vec = [vec, repmat(value, 1, count)];
        if length(vec) >= 64
            break;
        end
    end
    vec = vec(1:min(length(vec), 64));  % Clip just in case
end
