function time_length_results = find_optimal_T(num_BS, L, BW, tot_time, time_unit, handoff_thd, ho_delay_wired, ho_wireless_bits, bad_signal_thd, shading_dev, pos_MS, dir_MS, spd_MS, movement_mode, timer_length_arr, num_sim, show_info, seed_of_seed)
    % set random seed array
    rng(seed_of_seed)
    seed_arr = randi(100000, 1, num_sim);
    
    % result of simultation
    % order: [ho_number, ho_delay, avg_throughput, bad_signal_time]
    fix_timer_results = zeros(4, num_sim);
    
    % result for different time length
    % order: [ho_number, avg_throughput, avg_bad_signal]
    time_length_results = zeros(3, length(timer_length_arr));
    
    for j = 1:length(timer_length_arr)
        for i = 1:num_sim
            [fix_timer_results(1, i), fix_timer_results(2, i), fix_timer_results(3, i), fix_timer_results(4, i)] = fixed_timer(num_BS, L, BW, tot_time, time_unit, handoff_thd, ho_delay_wired, ho_wireless_bits, bad_signal_thd, shading_dev, pos_MS, dir_MS, spd_MS, timer_length_arr(j), show_info, seed_arr(i), movement_mode);
        end
        time_length_results(1, j) = mean(fix_timer_results(1, :));
        time_length_results(2, j) = mean(fix_timer_results(3, :));
        time_length_results(3, j) = mean(fix_timer_results(4, :));
    end
    %% Visualization
    figure('Name','Timer-based algorithm- different T','NumberTitle','off');
    scatter(time_length_results(1, :), time_length_results(2, :))
    
    for i = 1:length(timer_length_arr)
        text(time_length_results(1, i), time_length_results(2, i), num2str(timer_length_arr(i)), 'HorizontalAlignment', 'left', 'VerticalAlignment', 'top');
    end
    
    xlabel('average number of HO');
    ylabel('average throughout (bit/s)');
    title('Timer-based algorithm- different T');
    %% Save Data and Figures
    % data destination
    datadir = fullfile(fileparts(pwd),'\data');
    
    % timestamp
    timestamp = datestr(now, 'mmm-dd-yyyy, HH-MM');
    
    % file name
    file_name = [timestamp,'_', num2str(seed_of_seed), '_optimal_T_'];
    saveas(gcf, fullfile(datadir, file_name), 'png');
    saveas(gcf, fullfile(datadir, file_name), 'm');
    save(fullfile(datadir, file_name));
    fprintf('Successfully Saved\n');
end