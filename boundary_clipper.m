%% clip MS within boundary
function pos_MS = boundary_clipper(pos_MS, d_arr, pos_im_BS, pos_BS) 
    % min_distance between MS and BS
    min_d_BS = min(d_arr);

    % min_distance between MS and im_BS
    min_d_im_BS = 10^10;

    % ID of min_distance im_BS
    min_im_BS_id = -1;

    % Index of min_distance im_BS
    min_im_BS_idx = -1;

    for i = 1:18
        d_im_BS = norm(pos_MS-pos_im_BS(i, 1:2));
        if(d_im_BS<min_d_im_BS)
            min_d_im_BS = d_im_BS;
            min_im_BS_id = pos_im_BS(i, 3);
            min_im_BS_idx = i;
        end
    end
    % if MS is out-of-boundary-> translation
    if(min_d_im_BS<min_d_BS)
        pos_MS = (pos_MS-pos_im_BS(min_im_BS_idx, 1:2))+pos_BS(min_im_BS_id, :);
    end
end