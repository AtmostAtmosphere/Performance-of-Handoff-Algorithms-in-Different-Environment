% Find optimal h, T and Q
%% Settings
clear
% general 
num_BS = 19;        % number of base station
L = 500/sqrt(3);    % side length of a cell 
center = [0, 0];    % center of the cell
BW = 10^7;          % bandwidth (Hz)
tot_time= 100;      % total simulation time (sec)
time_unit = 0.01;   % time unit of simultaion (sec)
handoff_thd = 5;    % handoff threshold (dB)
ho_delay_wired = 0.12;   % fixed handoff delay (wired part) (sec)
ho_wireless_bits = 1000; % fixed handoff bit to transmit (wireless part) (bit)
bad_signal_thd = 10^6;   % bad signal threshold 
shading_dev = 20;         % deviation of shadowing (dB)
pos_MS = [250, 0];       % Initial position of MS
dir_MS = 0;              % Initial direction of MS
spd_MS = 0;              % Initial speed of MS
movement_mode = 0;       % mode 0: random walk, mode 1: related to previous movement

% fixed timer 
timer_length = 50;       % fixed timer length (T) (time unit)  

% adaptive timer
para_P = 5;              % parameter P used in adaptive timer
para_M = 70;             % parameter M used in adaptive timer
para_Q = 10;             % parameter Q used in adaptive timer
ada_mode = 1;            % adaptive mode (0: timer decrease with distance, 1: timer increase with distance)

% simulation
num_sim = 20;            % number of simulation
show_info = false;       % print the result of simulation

% set seed of random seed 
seed_of_seed = 77;

% Range of Q
Q_arr = 5:5:100;

% Range of T
timer_length_arr = 5:5:100;

% Range of h
handoff_thd_arr = 5:5:100;

% run option
run_T = true;
run_Q = true;
run_h = false;

%% Add path
% add path " ../functions"
addpath(fullfile(fileparts(pwd),'\function'));

%% Simulation 
if run_Q
    Q_results = find_optimal_Q(num_BS, L, BW, tot_time, time_unit, handoff_thd, ho_delay_wired, ho_wireless_bits, bad_signal_thd, shading_dev, pos_MS, dir_MS, spd_MS, movement_mode, para_P, para_M, Q_arr, ada_mode, num_sim, show_info, seed_of_seed);
end
if run_h
    hyster_results = find_optimal_h(num_BS, L, BW, tot_time, time_unit, handoff_thd_arr, ho_delay_wired, ho_wireless_bits, bad_signal_thd, shading_dev, pos_MS, dir_MS, spd_MS, movement_mode, timer_length, num_sim, show_info, seed_of_seed);
end
if run_T
    time_length_results = find_optimal_T(num_BS, L, BW, tot_time, time_unit, handoff_thd, ho_delay_wired, ho_wireless_bits, bad_signal_thd, shading_dev, pos_MS, dir_MS, spd_MS, movement_mode, timer_length_arr, num_sim, show_info, seed_of_seed);
end