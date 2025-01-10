% figure_painter
% clear workspace 
clear

% directories
data_dir = fullfile(fileparts(pwd),'\data');

% add path " ../data"
addpath(data_dir);
% paste the file name of the desired data
load("Jun-18-2023, 13-06_7_optimal_h_")
load("Jun-18-2023, 13-09_7_optimal_T_")
%% Visualization
figure('Name','Adaptive timer algorithm- different Q','NumberTitle','off');
% plot(hyster_results(1, 1:length(hyster_results)), hyster_results(2, 1:length(hyster_results)), '-s')

hold on
plot(time_length_results(1, :), time_length_results(2, :), "-o")

hold on 
plot(Q_results(1, 2:length(Q_results)), Q_results(2, 2:length(Q_results)), '-*')

% for i = 1:length(timer_length_arr)
    % text(hyster_results(1, i), hyster_results(2, i), num2str(handoff_thd_arr(i)), 'HorizontalAlignment', 'left', 'VerticalAlignment', 'top');
% end
% for i = 1:length(timer_length_arr)
    % text(time_length_results(1, i), time_length_results(2, i), num2str(timer_length_arr(i)), 'HorizontalAlignment', 'left', 'VerticalAlignment', 'top');
% end
% for i = 1:length(Q_arr)
    % text(Q_results(1, i), Q_results(2, i), num2str(Q_arr(i)), 'HorizontalAlignment', 'left', 'VerticalAlignment', 'top');
% end

xlabel('average number of HO');
ylabel('average throughout (bit/s)');
% legend("Adaptive", "Timer-based", "Location","southeast")
title('Performance comparision: $\displaystyle \sigma = 15~ dB$','interpreter','latex');

%% Save figure
% data destination
datadir = fullfile(fileparts(pwd),'\data');

% timestamp
timestamp = datestr(now, 'mmm-dd-yyyy, HH-MM');

% file name
file_name = [timestamp,'_shadow_', num2str(shading_dev)];
saveas(gcf, fullfile(datadir, file_name), 'png');
saveas(gcf, fullfile(datadir, file_name), 'm');
fprintf('Successfully Saved\n');