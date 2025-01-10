function [ho_number, ho_delay, avg_throughput, bad_signal_time] = fixed_hysteresis(num_BS, L, BW, tot_time, time_unit, handoff_thd, ho_delay_wired, ho_wireless_bits, bad_signal_thd, shading_dev, pos_MS, dir_MS, spd_MS, show_info, seed, movement_mode)
    % set random seed 
    rng(seed)
    
    % Position of base station
    pos_BS = BS_pos_generator(L);
    
    % Position of imaginary base station
    pos_im_BS = im_BS_pos_generator(L);

    % time left on this walk
    countdown = 0;
    
    % ID of initial current BS 
    current_id = 1;
    
    % handoff history
    % ho_history(1)-> time
    % ho_history(2)-> source cell ID
    % ho_history(3)-> destination cell ID
    ho_history = zeros(tot_time, 3);
    
    % idx of HO
    ho_idx = 1; 
    
    % delay of HO (sec)
    ho_delay = 0;
    
    % bad signal time
    bad_signal_time = 0;
    
    % average throughput
    avg_throughput = 0;
    
    for t = 1:time_unit:tot_time
        % mode 0: random walk
        % mode 1: related to previous movement
        if(abs(countdown-0) < 10^(-9))
            [dir_MS, spd_MS, countdown] = new_movement(dir_MS, spd_MS, movement_mode, seed); 
        end
        
        % update pos_MS
        pos_MS = pos_MS + time_unit*spd_MS*[cos(dir_MS), sin(dir_MS)];
        
        % distance between MS and BS
        % d_arr[i]: MS & i^th BS
        d_arr = zeros(num_BS, 1);
        for i=1:num_BS
            d_arr(i)=norm(pos_MS-pos_BS(i, :));
        end
    
        % clip MS within boundary
        pos_MS = boundary_clipper(pos_MS, d_arr, pos_im_BS, pos_BS); 
    
        % update countdown
        countdown = countdown-time_unit;
        
        % SINR between BS(i) & MS
        SINR_arr = SINR_finder(d_arr, shading_dev); 
        
        % SINR between current BS & MS
        SINR_now = SINR_arr(current_id);
    
        % Shannon capacity between current BS & MS
        SC_now = BW*log2(1+10^(SINR_now/10));
    
        % update bad signal time
        if(SC_now<bad_signal_thd)
            bad_signal_time = bad_signal_time + time_unit;
        end
    
        % update average throughput
        avg_throughput = avg_throughput + SC_now*(time_unit/tot_time);
    
        % max SINR at present
        [max_SINR, max_id] = max(SINR_arr); 
    
        % if max_SINR> present BS SINR+(handoff_thd) -> Handoff 
        if(max_id~=current_id)
            if(max_SINR > SINR_arr(current_id)+handoff_thd)
                % log into history
                ho_history(ho_idx, 1) = t; 
                ho_history(ho_idx, 2) = current_id;
                ho_history(ho_idx, 3) = max_id;
                
                % update handoff index
                ho_idx = ho_idx+1;
    
                % update current BS
                current_id = max_id;
    
                % update delay of HO (wired part: 120ms)
                ho_delay = ho_delay + ho_delay_wired;
                
                % update delay of HO (wireless part: 1000 bits)
                % SINR (linear scale)
                max_SINR_linear = 10^(max_SINR/10);
                shannon_capa = BW * log2(1+max_SINR_linear); 
                ho_delay_wireless = ho_wireless_bits/shannon_capa;
                ho_delay = ho_delay + ho_delay_wireless; 
                
                % if ho_delay_wireless exceed time_unit, I have to deal with
                % boundary case
                if (ho_delay_wireless > time_unit)
                    fprintf('ho_delay_wireless > time_unit\n')
                end
            end
        end
    end
    ho_number = ho_idx-1;
    if show_info
        fprintf('Number of HO: %d\n', ho_number)
        fprintf('Delay of HO: %f\n', ho_delay)
        fprintf('Average throughput: %f\n', avg_throughput)
        fprintf('Bad signal time: %f\n', bad_signal_time)
    end
end