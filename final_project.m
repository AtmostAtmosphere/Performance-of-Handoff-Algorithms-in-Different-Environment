T = 27 + 273.16; %temperature
k = 1.38*10^(-23); %Boltzman's constant
BS = zeros(19,3);
ISD = 500;
r = ISD/sqrt(3);
bw = 10^7;
pt_bs = 33;
pt_ms = 23;
gt = 14; %transmitter gain
gr = 14; %receiver gain
ht = 51.5; %base station height
hr = 1.5; %mobile service height
n = 100; %number of MS


%Location of 100 mobile devices in 19-cell map
count = 1;
for i = 0:2
    for j = 0:2
        BS(count, 1) = i*ISD/2*sqrt(3) - j*ISD/2*sqrt(3);
        BS(count, 2) = i*ISD/2 + j*ISD/2;
        count = count + 1;
    end
end
for i = 0:2
    for j = 0:2
        BS(count, 1) = i*ISD/2*sqrt(3) - j*ISD/2*sqrt(3);
        BS(count, 2) = -i*ISD/2 - j*ISD/2;
        count = count + 1;
    end
end
BS(10, 1) = -3*r;
BS(10, 2) = 0;
BS(count, 1) = 3*r;
BS(count, 2) = 0;

% extension of 19-cell map
BS_bd = zeros(18,3);
BS_bd(1,:) = [BS(3,1),BS(3,2)+ISD,18];
BS_bd(2,:) = [BS(6,1),BS(6,2)+ISD,17];
BS_bd(3,:) = [BS(9,1),BS(9,2)+ISD,16];
BS_bd(4,:) = [BS(8,1),BS(8,2)+ISD,12];
BS_bd(5,:) = [BS(7,1),BS(7,2)+ISD,15];
BS_bd(6,:) = [BS(12,1),BS(12,2)-ISD,8];
BS_bd(7,:) = [BS(15,1),BS(15,2)-ISD,7];
BS_bd(8,:) = [BS(18,1),BS(18,2)-ISD,3];
BS_bd(9,:) = [BS(17,1),BS(17,2)-ISD,6];
BS_bd(10,:) = [BS(16,1),BS(16,2)-ISD,9];
BS_bd(11,:) = [BS(8,1)+3*r,BS(8,2),18];
BS_bd(12,:) = [BS(4,1)+3*r,BS(4,2),3];
BS_bd(13,:) = [BS(13,1)+3*r,BS(13,2),10];
BS_bd(14,:) = [BS(17,1)+3*r,BS(17,2),12];
BS_bd(15,:) = [BS(6,1)-3*r,BS(6,2),7];
BS_bd(16,:) = [BS(2,1)-3*r,BS(2,2),19];
BS_bd(17,:) = [BS(11,1)-3*r,BS(11,2),16];
BS_bd(18,:) = [BS(15,1)-3*r,BS(15,2),9];

time = 0;

handoff = zeros(7,1);
throughput = zeros(10,7);
badsignaltime = zeros(10,7);
for z = 1:7
for y = 1:10
time = time + 1;

MS = zeros(n,7);
for i = 1:n
    cell_id = randi(19);
    a = unifrnd(0,1);
    b = unifrnd(0,1);
    ram = randi([0 2], 1);
    if ram == 0
        MS(i,1) = BS(cell_id, 1)-r+a*r+b*r/2;
        MS(i,2) = BS(cell_id, 2)+b*ISD/2;
        MS(i,3) = cell_id;
        %BS(cell_id,3) = BS(cell_id,3)+1;
    elseif ram == 1
        MS(i,1) = BS(cell_id, 1)-r+a*r+b*r/2;
        MS(i,2) = BS(cell_id, 2)-b*ISD/2;
        MS(i,3) = cell_id;
        %BS(cell_id,3) = BS(cell_id,3)+1;
    else 
        MS(i,1) = BS(cell_id, 1)+a*r/2+b*r/2;
        MS(i,2) = BS(cell_id, 2)+a*ISD/2-b*ISD/2;
        MS(i,3) = cell_id;
        %BS(cell_id,3) = BS(cell_id,3)+1;
    end
end
%{
if time == 1

figure
scatter(MS(:,1), MS(:,2),'.','b.');
hold on
plot(BS(:,1),BS(:,2),'.','MarkerSize',10);
xlim([-4*r,4*r])
ylim([-5/2*ISD,5/2*ISD])
xlabel('Distance(m)');
ylabel('Distance(m)');
title('Location of 100 mobile devices in 19-cell map');

end
%}

capacity_bar = 10^5; %SINR handoff criterion
inf = zeros(n,1) + k*T*bw;
mov = zeros(n,2);
t = 0; % time interval unit be 10ms
fprintf('Time  Source_Cell_ID  Destination_Cell_ID %d\n', time);
count = 0;


capacity = zeros(n,1);
shadowing = zeros(n,19);
c_av = 0;
time_limit = 100;
iter = 0;
handoff_signal_interval = 0.1*2^z;
bad_signal_time = zeros(n,1);
pr = zeros(n,1);
BS_cap_max = zeros(19,1) + 120*10^6;
count_test = 0;
while t < time_limit
    for j = 1:n
        % interference calulation
        inf(j) = 0;
        for k = 1:19
            shadowing(j,k) = normrnd(0,10);
            if k == MS(j,3)
                continue
            end
            p = rss(j,k,MS,BS);
            inf(j) = inf(j) + 10^((p+shadowing(j,k))/10);
        end
        pr(j) = rss(j,MS(j,3),MS,BS);
        SINR = pr(j)-10*log10(inf(j));
        capacity(j) = bw*log2(1+10^(SINR/10)); 
        %BS_cap_max(MS(j,3),1) = BS_cap_max(MS(j,3),1) - capacity(j);
    end

    for j = 1:n
        if t == 0
            MS(j,5) = unifrnd(0,handoff_signal_interval);
            
        end


        % if on the boundary, then check if need extension

        if (MS(j,3) ~= 1)&&(MS(j,3) ~= 2)&&(MS(j,3) ~= 4)&&(MS(j,3) ~= 5)&&(MS(j,3) ~= 11)&&(MS(j,3) ~= 13)&&(MS(j,3) ~= 14)           
            x_c = 0;
            flag = 0;
            d = (MS(j,1)-BS(MS(j,3),1))^2+(MS(j,2)-BS(MS(j,3),2))^2;
            for x = 1:18
                dis = (MS(j,1)-BS_bd(x,1))^2+(MS(j,2)-BS_bd(x,2))^2;
                if dis < d
                    x_c = x;
                    d = dis;
                    flag = 1;
                end
            end
            if flag == 1
                MS(j,1) = MS(j,1)-BS_bd(x_c,1)+BS(BS_bd(x_c,3),1);
                MS(j,2) = MS(j,2)-BS_bd(x_c,2)+BS(BS_bd(x_c,3),2);
                MS(j,3) = BS_bd(x_c,3);
            end
        end

        % simulate continuous, predictable trajectory
        if MS(j,4) <= 0

                mov_dir = unifrnd(0, 2*pi);
                speed = unifrnd(1, 15);
            %{
            else
                mov_dir = unifrnd(0, 2*pi);
                speed = unifrnd(1, 15);
                
                mov_dir = mov(j,2) + unifrnd(-pi/9, pi/9);
                speed = mov(j,1) + unifrnd(-2, 2);
            %}   
            mov(j,1) = speed;
            mov(j,2) = mov_dir;
            mov_time = unifrnd(1,6);
            MS(j,4) = mov_time; 
        end    
        
        swap_now = 0;
        swap_later = 0;
        flag_now = 0;
        flag_later = 0;
     
        % predict future SINR to decide handoff
        ms_laterx = MS(j,1) + mov(j,1)*cos(mov(j,2))*handoff_signal_interval/2;
        ms_latery = MS(j,2) + mov(j,1)*sin(mov(j,2))*handoff_signal_interval/2;   

        if MS(j,5) < 0
            MS(j,5) = handoff_signal_interval;
            pr_c = pr(j);
            for k = 1:19
                if k == MS(j,3)
                    continue
                end
                d = sqrt((MS(j,1)-BS(k,1))^2+(MS(j,2)-BS(k,2))^2);
                two_ray = 10*log10((ht*hr)^2/d^4);
                pr_e = pt_bs+gt+gr+two_ray+shadowing(j,k); 

                if ((flag_now == 0)&&(pr_e  > pr_c + 10))||((flag_now == 1)&&(pr_e  > pr_c))
                    pr_c = pr_e;
                    swap_now = k;
                    flag_now = 1;
                end
            end

            pr_max = pr(j);
            for k = 1:19
                if k == MS(j,3)
                    continue
                end
                
                d = sqrt((ms_laterx-BS(k,1))^2+(ms_latery-BS(k,2))^2);
                two_ray = 10*log10((ht*hr)^2/d^4);
                pr_later = pt_bs+gt+gr+two_ray+shadowing(j,k); 
                if ((swap == 0)&&(pr_later > pr(j) + 10))||((swap ~= 0)&&(pr_later > pr_max))
                   pr_max = pr_later;
                   swap_later = k;
                   flag_later = 1;
                end
            end

            if (flag_now == 0)&&(flag_later == 1)
                MS(j,6) = handoff_signal_interval/2;
                MS(j,7) = swap_later;
            elseif (flag_now == 1)&&(flag_later == 1)
                if swap_now == swap_later
                    fprintf('%d  %d  %d\n', t, MS(j,3), swap_now);
                    MS(j,3) = swap_now;
                    count = count + 1;
                    MS(j,6) = 1;
                    MS(j,7) = 0;
                else
                    fprintf('%d  %d  %d\n', t, MS(j,3), swap_now);
                    MS(j,3) = swap_now;
                    count = count + 1;
                    MS(j,6) = handoff_signal_interval/2;
                    MS(j,7) = swap_later;
                end
            else 
                MS(j,6) = 1;
                MS(j,7) = 0;
            end
        end

        if MS(j,6) < 0
            fprintf('%d  %d  %d\n', t, MS(j,3), MS(j,7));
            MS(j,3) = MS(j,7); %execute handoff to target BS
            MS(j,6) = 1; %no handoff needed 
            MS(j,7) = 0; 
            count = count + 1;
        end
        
        %{
        if swap ~= 0
            HO_access = 1000/(bw*log2(1+10^(SINR/10)));
            MS(j,6) = 0.12 + HO_access + handoff_signal_interval/2;
            if flag == 1
                MS(j,6) = MS(j,6) - handoff_signal_interval/2;
            end
            MS(j,7) = swap;
        end
        %}

        if capacity(j) < 10^6
            bad_signal_time(j) = bad_signal_time(j) + 0.01;
        end


        MS(j,1) = MS(j,1) + mov(j,1)*cos(mov(j,2))*0.01;
        MS(j,2) = MS(j,2) + mov(j,1)*sin(mov(j,2))*0.01;
        MS(j,4) = MS(j,4) - 0.01;
        MS(j,5) = MS(j,5) - 0.01;
        if MS(j,7) ~= 0
            MS(j,6) = MS(j,6) - 0.01;
        end
    end
    %{
    if (mod(iter,10) == 0)&&(time == 1)
        scatter(MS(:,1), MS(:,2),'.','b.');
    end
    %}
    c_av = c_av + sum(capacity)/(time_limit*100*n);
    t = t+0.01;    
    iter = iter+1;
end
%{
fprintf('There are %d handoffs\n',count);
fprintf('The average throughput for each MS is %d\n',c_av);
fprintf('The average bad signal time for each MS is %d\n',sum(bad_signal_time)/n);
%}
handoff(z,1) = handoff(z,1) + count;
throughput(y,z) = c_av;
badsignaltime(y,z) = sum(bad_signal_time)/n;
end
handoff(z,1) = handoff(z,1)/10;
end
av_throughput = sum(throughput)/10;
av_badsignaltime = sum(badsignaltime)/10;
figure
errorbar(handoff,av_throughput,max(throughput)-av_throughput, av_throughput-min(throughput),'o')
%errorbar(handoff,av_badsignaltime, max(badsignaltime)-av_badsignaltime, av_badsignaltime-min(badsignaltime),'o')

function pr = rss(ms, bs, MS, BS)
    ht = 51.5; %base station height
    hr = 1.5;
    pt_bs = 33;
    gt = 14; %transmitter gain
    gr = 14; %receiver gain
    d = sqrt((MS(ms,1)-BS(bs,1))^2+(MS(ms,2)-BS(bs,2))^2);
    two_ray = 10*log10((ht*hr)^2/d^4);
    pr = pt_bs+gt+gr+two_ray;
end

%{
        d = sqrt((MS(j,1)-BS(MS(j,3),1))^2+(MS(j,2)-BS(MS(j,3),2))^2);
        two_ray = 10*log10((ht*hr)^2/d^4);
        pr = pt_bs+gt+gr+two_ray+shadowing(j,MS(j,3));
%}

        %{
        if  capacity < capacity_bar
            for x = 1:19
                dis = sqrt((MS(j,1)-BS(x,1))^2+(MS(j,2)-BS(x,2))^2);
                t_r = 10*log10((ht*hr)^2/dis^4);
                shadowing = normrnd(0,6);
                if pt_bs+gt+gr+t_r-10*log10(inf(x))+shadowing >= SINR_bar
                    fprintf('%d  %d  %d\n', t, MS(j,3), x);
                    MS(j,3) = x;
                    count = count + 1;
                    break;
                end
            end
        end
        %}


