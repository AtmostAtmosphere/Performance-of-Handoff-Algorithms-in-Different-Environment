%% BS_pos_generator 
%  (generate position of 19 base stations)  
function pos_BS = BS_pos_generator(L) 
    pos_BS = zeros(19, 2);
    pos_BS(1, :) = [0, 0];
    pos_BS(2, :) = [0, sqrt(3)];
    pos_BS(3, :) = [0, -sqrt(3)];
    pos_BS(4, :) = [0, 2*sqrt(3)];
    pos_BS(5, :) = [0, -2*sqrt(3)];
    pos_BS(6, :) = [3/2, sqrt(3)/2];
    pos_BS(7, :) = [3/2, -sqrt(3)/2];
    pos_BS(8, :) = [3/2, 3*sqrt(3)/2];
    pos_BS(9, :) = [3/2, -3*sqrt(3)/2];
    pos_BS(10, :) = [3, 0];
    pos_BS(11, :) = [3, sqrt(3)];
    pos_BS(12, :) = [3, -sqrt(3)];
    pos_BS(13:19, :) = pos_BS(6:12, :);
    pos_BS(13:19, 1) = -pos_BS(13:19, 1);
    pos_BS = pos_BS*L;
end