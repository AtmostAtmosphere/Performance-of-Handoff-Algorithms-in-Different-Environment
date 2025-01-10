% performance comparison
%% Settings
clear
% general 
num_BS = 19;        % number of base station
L = 500/sqrt(3);    % side length of a cell
center = [0, 0];    % center of the cell
BW = 10^7;          % bandwidth (Hz)
tot_time= 100;      % total simulation time (sec)
time_unit = 0.01;   % time unit of simultaion (sec)
handoff_thd = 20;    % handoff threshold (dB)
ho_delay_wired = 0.12;   % fixed handoff delay (wired part) (sec)
ho_wireless_bits = 1000; % fixed handoff bit to transmit (wireless part) (bit)
bad_signal_thd = 10^6;   % bad signal threshold 
shading_dev = 6;         % deviation of shadowing (dB)
pos_MS = [250, 0];       % Initial position of MS
dir_MS = 0;              % Initial direction of MS
spd_MS = 0;              % Initial speed of MS
movement_mode = 0;       % mode 0: random walk, mode 1: related to previous movement

% fixed timer
timer_length = 5;       % fixed timer length (time unit)  

% adaptive timer
para_P = 5;              % parameter P used in adaptive timer
para_M = 70;             % parameter M used in adaptive timer
para_Q = 20;             % parameter Q used in adaptive timer
ada_mode = 1;            % adaptive mode (0: timer decrease with distance, 1: timer increase with distance)

% simulation
num_sim = 20;            % number of simulation
show_info = false;       % print the result of simulation

% set random seed 
seed_of_seed = 7;
rng(seed_of_seed)
seed_arr = randi(100000, 1, num_sim); 

%% Add path
% add path " ../functions"
addpath(fullfile(fileparts(pwd),'\function'));

%% Results
% result of simultation
% order: [ho_number, ho_delay, avg_throughput, bad_signal_time]
fix_hys_results = zeros(4, num_sim);
fix_timer_results = zeros(4, num_sim);
ada_timer_results = zeros(4, num_sim);

for i = 1:num_sim
    [fix_hys_results(1, i), fix_hys_results(2, i), fix_hys_results(3, i), fix_hys_results(4, i)] = fixed_hysteresis(num_BS, L, BW, tot_time, time_unit, handoff_thd, ho_delay_wired, ho_wireless_bits, bad_signal_thd, shading_dev, pos_MS, dir_MS, spd_MS, show_info, seed_arr(i), movement_mode);
    [fix_timer_results(1, i), fix_timer_results(2, i), fix_timer_results(3, i), fix_timer_results(4, i)] = fixed_timer(num_BS, L, BW, tot_time, time_unit, handoff_thd, ho_delay_wired, ho_wireless_bits, bad_signal_thd, shading_dev, pos_MS, dir_MS, spd_MS, timer_length, show_info, seed_arr(i), movement_mode);
    [ada_timer_results(1, i), ada_timer_results(2, i), ada_timer_results(3, i), ada_timer_results(4, i)] = adaptive_timer(num_BS, L, BW, tot_time, time_unit, handoff_thd, ho_delay_wired, ho_wireless_bits, bad_signal_thd, shading_dev, pos_MS, dir_MS, spd_MS, para_P, para_M, para_Q, ada_mode, show_info, seed_arr(i), movement_mode);
end

%% Visiualization of average result
% type = categorical({'fixed hys', 'fixed timer', 'adaptive timer'});
% type = reordercats(type,{'fixed hys', 'fixed timer', 'adaptive timer'});
type = categorical({'fixed hys', 'fixed timer'});
type = reordercats(type,{'fixed hys', 'fixed timer'});

% number of HO
% avg_ho_num = [mean(fix_hys_results(1, :)), mean(fix_timer_results(1, :)), mean(ada_timer_results(1, :))];
avg_ho_num = [mean(fix_hys_results(1, :)), mean(fix_timer_results(1, :))];

figure('Name','average number of HO','NumberTitle','off');
bar(type, avg_ho_num)
grid on
xlabel('type');
ylabel('average number of HO');
title('average number of HO');

% delay of HO
% avg_ho_delay = [mean(fix_hys_results(2, :)), mean(fix_timer_results(2, :)), mean(ada_timer_results(2, :))];
avg_ho_delay = [mean(fix_hys_results(2, :)), mean(fix_timer_results(2, :))];

figure('Name','average delay of HO','NumberTitle','off');
bar(type, avg_ho_delay)
grid on
xlabel('type');
ylabel('average delay of HO');
title('average delay of HO');

% throughput
% avg_throughput = [mean(fix_hys_results(3, :)), mean(fix_timer_results(3, :)), mean(ada_timer_results(3, :))];
avg_throughput = [mean(fix_hys_results(3, :)), mean(fix_timer_results(3, :))];

figure('Name','average throughput','NumberTitle','off');
bar(type, avg_throughput)
grid on
xlabel('type');
ylabel('average throughput');
title('average throughput');

% bad signal time
% avg_bad_signal = [mean(fix_hys_results(4, :)), mean(fix_timer_results(4, :)), mean(ada_timer_results(4, :))];
avg_bad_signal = [mean(fix_hys_results(4, :)), mean(fix_timer_results(4, :))];

figure('Name','average bad signal time','NumberTitle','off');
bar(type, avg_bad_signal)
grid on
xlabel('type');
ylabel('average bad signal time');
title('average bad signal time');
