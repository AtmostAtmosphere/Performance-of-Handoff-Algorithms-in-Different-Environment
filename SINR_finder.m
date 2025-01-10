% SINR between BS(i) & MS
function SINR_arr = SINR_finder(d_arr, shading_dev) 
    h_BS = 51.5; % height of base station(m)
    h_MS = 1.5;  % height of mobile station(m)
    P_t_BS = 3;    % power of transmitter - base station(dB)
    T = 300.15; % temperature(K)
    G_t = 14;   % transmitter gain (dB) 
    G_r = 14;   % receiver gain (dB)
    BW = 10^7;   % bandwidth (Hz)  
    k = 1.38*10^(-23); % Boltzmann's constant
    num_BS = 19; % number of base station
    S = normrnd(0, shading_dev, size(d_arr)); % shadowing (dB) 
    
    % radio propagation with path loss only (dB)
    g_d_arr = two_ray_path_loss(h_BS, h_MS, d_arr); 
    
    % power received (dB)
    P_r_arr = g_d_arr + G_t + G_r + P_t_BS + S;
    
    % power received (watt)
    % P_r_w_arr[i]: power from i^th BS
    P_r_w_arr = 10.^(P_r_arr/10);
    
    % total power received (watt)
    tot_P_r_w = sum(P_r_w_arr);
    
    % thermal noise power (watt)
    TN_w = k*T*BW;
    
    % N+I (watt)
    % NI_w[i]: N+I for i^th BS to MS transmission
    NI_w = zeros(num_BS, 1);
    for i = 1:num_BS
        NI_w(i) = (tot_P_r_w-P_r_w_arr(i))+TN_w;
    end
    
    % N+I (dB)
    NI = 10*log10(NI_w);
    
    % SINR
    % SINR_arr[i]: SINR for i^th BS to MS transmission
    SINR_arr = P_r_arr - NI;
end