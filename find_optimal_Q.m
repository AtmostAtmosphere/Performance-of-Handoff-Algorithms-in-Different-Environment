function Q_results = find_optimal_Q(num_BS, L, BW, tot_time, time_unit, handoff_thd, ho_delay_wired, ho_wireless_bits, bad_signal_thd, shading_dev, pos_MS, dir_MS, spd_MS, movement_mode, para_P, para_M, Q_arr, ada_mode, num_sim, show_info, seed_of_seed)
    % random seed array
    rng(seed_of_seed)
    seed_arr = randi(100000, 1, num_sim);

    % result of simultation
    % order: [ho_number, ho_delay, avg_throughput, bad_signal_time]
    ada_timer_results = zeros(4, num_sim);
    
    % result for different time length
    % order: [ho_number, avg_throughput]
    Q_results = zeros(3, length(Q_arr));
    
    for j = 1:length(Q_arr)
        for i = 1:num_sim
            [ada_timer_results(1, i), ada_timer_results(2, i), ada_timer_results(3, i), ada_timer_results(4, i)] = adaptive_timer(num_BS, L, BW, tot_time, time_unit, handoff_thd, ho_delay_wired, ho_wireless_bits, bad_signal_thd, shading_dev, pos_MS, dir_MS, spd_MS, para_P, para_M, Q_arr(j), ada_mode, show_info, seed_arr(i), movement_mode);
        end
        Q_results(1, j) = mean(ada_timer_results(1, :));
        Q_results(2, j) = mean(ada_timer_results(3, :));
        Q_results(3, j) = mean(ada_timer_results(4, :));
    end
    %% Visualization
    figure('Name','Adaptive timer algorithm- different Q','NumberTitle','off');
    scatter(Q_results(1, :), Q_results(2, :))
    
    for i = 1:length(Q_arr)
        text(Q_results(1, i), Q_results(2, i), num2str(Q_arr(i)), 'HorizontalAlignment', 'left', 'VerticalAlignment', 'top');
    end
    
    xlabel('average number of HO');
    ylabel('average throughout (bit/s)');
    title('Adaptive timer algorithm- different Q');
    
    %% Save Data and Figures
    % data destination
    datadir = fullfile(fileparts(pwd),'\data');
    
    % timestamp
    timestamp = datestr(now, 'mmm-dd-yyyy, HH-MM');
    
    % file name
    file_name = [timestamp,'_', num2str(seed_of_seed), '_optimal_Q_'];
    saveas(gcf, fullfile(datadir, file_name), 'png');
    saveas(gcf, fullfile(datadir, file_name), 'm');
    save(fullfile(datadir, file_name));
    fprintf('Successfully Saved\n');
end