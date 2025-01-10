function [dir_MS, spd_MS, countdown] = new_movement(dir_MS, spd_MS, movement_mode, seed)
    % set random seed 
    rng(seed)

    % mode 0: random walk
    if(movement_mode == 0)
        % direction: [0, 2*pi] rad
        dir_MS = 2*pi*rand;
        
        % speed: [1, 15] m/s
        spd_MS = (14*rand+1);       
    % mode 1: related to previous movement
    elseif(movement_mode == 1)
        % direction: previous dir + [-20, 20] degree
        dir_MS = dir_MS + (pi/180)*(40*rand-20);
        
        % speed: previous spd + [-2, 2] m/s
        spd_MS = spd_MS + (4*rand-2);
    else
        error('no corresponding mode')
    end
    % countdown: [1, 6] sec
    countdown = randi([1, 6]);
end