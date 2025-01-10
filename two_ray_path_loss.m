%% Path loss of two-ray ground model
function g_d = two_ray_path_loss(h_t, h_r, d_arr)
    loss = (h_t*h_r)^2./(d_arr.^4); % path loss (W)
    g_d = 10*log10(loss); 
end