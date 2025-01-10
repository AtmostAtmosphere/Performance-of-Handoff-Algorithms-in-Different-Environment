%% im_BS_pos_generator
% pos_im_BS(1:2)-> pos
% pos_im_BS(3)-> ID of corresponding BS
function pos_im_BS = im_BS_pos_generator(L) 
    pos_im_BS = zeros(18, 3);
    pos_im_BS(1, :) = [0, 3*sqrt(3), 12];
    pos_im_BS(2, :) = [0, -3*sqrt(3), 18];
    pos_im_BS(3, :) = [3/2, 2.5*sqrt(3), 19];
    pos_im_BS(4, :) = [3/2, -2.5*sqrt(3), 15];
    pos_im_BS(5, :) = [-3/2, 2.5*sqrt(3), 9];
    pos_im_BS(6, :) = [-3/2, -2.5*sqrt(3), 11];
    pos_im_BS(7, :) = [3, 2*sqrt(3), 16];
    pos_im_BS(8, :) = [3, -2*sqrt(3), 4];
    pos_im_BS(9, :) = [-3, 2*sqrt(3), 5];
    pos_im_BS(10, :) = [-3, -2*sqrt(3), 8];
    pos_im_BS(11, :) = [4.5, 0.5*sqrt(3), 18];
    pos_im_BS(12, :) = [4.5, 1.5*sqrt(3), 5];
    pos_im_BS(13, :) = [4.5, -0.5*sqrt(3), 17];
    pos_im_BS(14, :) = [4.5, -1.5*sqrt(3), 19];
    pos_im_BS(15, :) = [-4.5, 0.5*sqrt(3), 10];
    pos_im_BS(16, :) = [-4.5, 1.5*sqrt(3), 11];
    pos_im_BS(17, :) = [-4.5, -0.5*sqrt(3), 12];
    pos_im_BS(18, :) = [-4.5, -1.5*sqrt(3), 4];
    pos_im_BS(:, 1:2) = pos_im_BS(:, 1:2)*L;
end