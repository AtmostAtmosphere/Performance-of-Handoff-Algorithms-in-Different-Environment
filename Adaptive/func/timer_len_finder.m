function timer_len_arr = timer_len_finder(d_arr, para_P, para_M, para_Q, ada_mode)
    % timer decrease with distance
    if(ada_mode == 0)
        temp = -(1-d_arr/1350)*para_P;
        temp = exp(temp);
        temp = para_M*(1-temp);
        temp = max(temp, 1);
        timer_len_arr = round(temp);
    % timer increase with distance
    elseif(ada_mode == 1)
        timer_len_arr = round(max(d_arr*para_Q/500, 1));
    else
        error("no corresponding mode")
    end
end