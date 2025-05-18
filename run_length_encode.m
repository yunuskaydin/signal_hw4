function rle = run_length_encode(vec)
    rle = [];
    count = 1;
    prev = vec(1);
    for i = 2:length(vec)
        if vec(i) == prev
            count = count + 1;
        else
            rle = [rle, count, prev];
            count = 1;
            prev = vec(i);
        end
    end
    rle = [rle, count, prev];
end
