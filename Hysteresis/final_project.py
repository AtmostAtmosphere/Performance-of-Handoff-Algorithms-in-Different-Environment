import matplotlib.pyplot as plt
import numpy as np
np.random.seed(12345)
class Hexagon():
    def __init__(self, x, y, r, id=7777):
        self.x = x
        self.y = y
        self.r = r
        self.points = [(self.x+r*np.cos(2*np.pi/6*i), self.y+r*np.sin(2*np.pi/6*i)) for i in range(6)]
        self.hex_x, self.hex_y = zip(*self.points)
        self.mobile = []
        self.ID = id

    def has_device(self, m_x, m_y):
            if (m_x-self.x)**2+(m_y-self.y)**2<=r**2 and \
                np.abs(m_y-self.y)<=r/2*np.sqrt(3) and \
                np.sqrt(3)*np.abs(m_x-self.x)+np.abs(m_y-self.y)-np.sqrt(3)*r<=0:        
                return True
            else:
                return False
class MobileDevice():
    def __init__(self, x, y, id, BSs) -> None:
        self.x = x
        self.y = y
        self.timer = 0
        self.timeLimit = 250
        self.minSpeed = 1
        self.maxSpeed = 15
        self.minT = 1
        self.maxT = 6
        self.id = id
        self.BSs = BSs

        self.trackx = []
        self.tracky = []


        self.handoff_hist = []
        self.HO_sleep_time = 0

        self.sent_bits = 0
        self.bad_signal_time = 0
        self.bad_signal_thre = 10**6

        self.theta = 0
        self.velocity = 0
        self.time = 0

        self.roll_dice()


        r = 500/2/np.sqrt(3)*2
        outer_BSs_coords = np.array([
            (3,6), (4,5), (5,4), (6,3), (5,1),
            (4,-1), (3,-3), (1,-4), (-1,-5), (-3,-6),
            (-4,-5), (-5,-4), (-6,-3), (-5,-1), (-4,1),
            (-3,3), (-1,4), (1,5)
        ])
        outer_BSs_coords = np.matmul(outer_BSs_coords, np.array([[r, 0], [-r/2, np.sqrt(3)*r/2]]))

        outer2inner_BSs_coords = np.array([
            (2,-2), (-4,-2), (-3,-3), (-2,-4), (-2,2),
            (-3,0), (-4,-2), (2,4), (0,3), (-2,2),
            (4,2), (3,3), (2,4), (2,-2), (3,0), (4,2),
            (-2,-4), (0,-3)
        ])
        outer2inner_BSs_coords = np.matmul(outer2inner_BSs_coords, np.array([[r, 0], [-r/2, np.sqrt(3)*r/2]]))
        
        self.outer_BSs = [ Hexagon(x, y, r) for (x,y) in outer_BSs_coords.tolist() ]



        self.outer2inner = {}
        for out, inner in zip(outer_BSs_coords, outer2inner_BSs_coords):
            self.outer2inner[tuple(out)]=tuple(inner)
        self.cellID = self.update_cellID()
        self.check_boundary()

        self.asso_bs = self.cellID

        # DEBUG
        self.drs = []

    def start_simulation(self):
        print('='*40)
        print(f'Time | Source cell ID | Destination cell ID')

        while(self.timer < self.timeLimit):
            # print(self.timer)
            self.one_move()

    def roll_dice(self):
        self.theta = np.random.uniform(0, np.pi * 2)
        self.velocity = np.random.uniform(self.minSpeed, self.maxSpeed)
        self.time = np.random.uniform(self.minT, self.maxT)
        # self.theta += np.random.uniform(-np.pi * 2 / 36 *2 , np.pi * 2 / 36*2)
        # self.velocity += np.random.uniform(-2, 2)
        # self.time = np.random.uniform(self.minT, self.maxT)

    def one_move(self, ms_coords_x, ms_coords_y, threshold, MSs, _dt=1, hdf_plcy='SINR'):
        dt = _dt
        self.timer += dt
        self.time -= dt
        if self.HO_sleep_time > 0:
            if self.HO_sleep_time - dt > 0 :
                self.HO_sleep_time -= dt
            else:
                dt = -(self.HO_sleep_time - dt)
                self.HO_sleep_time = 0
        else:

            # print(self.x, self.y)
            self.x += dt*self.velocity * np.cos(self.theta)
            self.y += dt*self.velocity * np.sin(self.theta)

            # print(self.x, self.y)


            # print(self.velocity, self.time)
            
            # check boundary
            # update cellID
            originalID = self.cellID
            self.cellID = self.update_cellID()
            if self.cellID==None:
                self.check_boundary()
                self.cellID = self.update_cellID()

            if hdf_plcy == 'SINR':
                has_handoff = self.check_handoff(
                    ms_coords_x=ms_coords_x,
                    ms_coords_y=ms_coords_y,
                    MSs=MSs, 
                    threshold=threshold
                )
                if not has_handoff:
                    dr = self.data_rate(MSs)
                    self.sent_bits += dr * dt
                    if dr < self.bad_signal_thre:
                        self.bad_signal_time += dt
            elif hdf_plcy == 'Hys':
                has_handoff = self.check_handoff_v2(MSs, 5)
                if not has_handoff:
                    dr = self.data_rate(MSs)
                    self.sent_bits += dr * dt
                    if dr < self.bad_signal_thre:
                        self.bad_signal_time += dt
            elif hdf_plcy == 'MaxSINR':
                has_handoff = self.max_sinr_handoff(MSs)
                if not has_handoff:
                    dr = self.data_rate(MSs)
                    self.sent_bits += dr * dt
                    if dr < self.bad_signal_thre:
                        self.bad_signal_time += dt
            
            elif hdf_plcy == 'VAH2':
                has_handoff = self.velocity_adaptive_handoff_2(MSs)
                if not has_handoff:
                    dr = self.data_rate(MSs)
                    self.sent_bits += dr * dt
                    if dr < self.bad_signal_thre:
                        self.bad_signal_time += dt
            elif hdf_plcy == 'VAH4':
                has_handoff = self.velocity_adaptive_handoff_4(MSs)
                if not has_handoff:
                    dr = self.data_rate(MSs)
                    self.sent_bits += dr * dt
                    if dr < self.bad_signal_thre:
                        self.bad_signal_time += dt
            elif hdf_plcy =='DIS':
                has_handoff = self.check_handoff_dis(MSs, 5)
                if not has_handoff:
                    dr = self.data_rate(MSs)
                    self.sent_bits += dr * dt
                    if dr < self.bad_signal_thre:
                        self.bad_signal_time += dt
            else:
                if originalID != self.cellID:
                    # pass
                    # print(f'{self.timer:>6.2f} | {originalID:>2} | {self.cellID:>2}')
                    self.handoff_hist.append(f'{self.timer:>6.2f}s | {originalID:>2} | {self.cellID:>2}')


            self.trackx.append(tuple(self.x))
            self.tracky.append(tuple(self.y))

            self.drs.append(self.data_rate(MSs))

            # If the random time for ms is up, randomly set new time
            if self.time < 0:
                self.roll_dice()

    def update_cellID(self):
        for bs in self.BSs:
            if bs.has_device(self.x, self.y):
                # print(bs.ID)
                return bs.ID
        return None

    def check_boundary(self):
        if self.cellID == None:
            # print('Out of map')
            #out of map
            mapped_x=0
            mapped_y = 0
            idx = 0
            for i, bs in enumerate(self.outer_BSs):
                if bs.has_device(self.x, self.y):
                    mapped_x, mapped_y = self.outer2inner[(bs.x, bs.y)]
                    idx = i
                    break
            move_x, move_y = self.x - self.outer_BSs[idx].x, self.y - self.outer_BSs[idx].y
            # self.cellID = self.outer_BSs[idx].ID
            self.x = mapped_x + move_x
            self.y = mapped_y + move_y

    def check_handoff(self, ms_coords_x, ms_coords_y, MSs, threshold = 5):
        '''
        Hysterisis handoff with H = threshold
        '''
        if self.cellID != self.asso_bs:
            SINR_current = self.sinr(self.cellID, MSs)
            SINR_original = self.sinr(self.asso_bs, MSs)
            # Do handoff if SINR diff larger than some threshold
            if SINR_current - SINR_original > threshold:
                print(f'current: {self.cellID}, {SINR_current}, original: {self.asso_bs} {SINR_original}, v = {np.abs(self.velocity)}')
                self.handoff_hist.append(f'{self.timer:>6.2f}s | {self.asso_bs:>2} | {self.cellID:>2}')
                self.asso_bs = self.cellID
                self.compute_HO_delay(MSs)
                return True
        return False
    
    def check_handoff_v2(self, MSs, threshold = 5):
        '''
        Hysterisis handoff with H = threshold
        '''
        if self.cellID != self.asso_bs:
            original_asso_bs = self.asso_bs
            original_asso_bs_sinr = self.sinr(original_asso_bs, MSs)
            # Find BS with max sinr
            max_asso_bs = self.asso_bs
            max_asso_bs_sinr = original_asso_bs_sinr
            for bs_idx in range(len(self.BSs)):
                bs_idx_sinr = self.sinr(bs_idx, MSs)
                if bs_idx_sinr > max_asso_bs_sinr:
                    max_asso_bs = bs_idx + 1
                    max_asso_bs_sinr = bs_idx_sinr
            
            # Do handoff if SINR diff larger than some threshold
            if original_asso_bs != max_asso_bs:
                if max_asso_bs_sinr - original_asso_bs_sinr > threshold:
                    print(f'current: {max_asso_bs}, {max_asso_bs_sinr}, original: {self.asso_bs} {original_asso_bs_sinr}, v = {self.velocity}')
                    self.handoff_hist.append(f'{self.timer:>6.2f}s | {self.asso_bs:>2} | {max_asso_bs:>2}')
                    self.asso_bs = max_asso_bs
                    # self.compute_HO_delay(MSs)
                    return False
        return False

    def check_handoff_dis(self, MSs, threshold = 5):
        '''
        Hysterisis handoff with H = threshold
        '''
        if self.cellID != self.asso_bs:
            original_asso_bs = self.asso_bs
            original_asso_bs_sinr = self.sinr(original_asso_bs, MSs)
            # Find BS with max sinr
            max_asso_bs = self.asso_bs
            max_asso_bs_sinr = original_asso_bs_sinr
            for bs_idx in range(len(self.BSs)):
                bs_idx_sinr = self.sinr(bs_idx, MSs)
                if bs_idx_sinr > max_asso_bs_sinr:
                    max_asso_bs = bs_idx + 1
                    max_asso_bs_sinr = bs_idx_sinr
            
            # Do handoff if SINR diff larger than some threshold
            if original_asso_bs != max_asso_bs:
                r = 500/2/np.sqrt(3)*2
                dis_origin_bs = np.sqrt(
                    (self.x - self.BSs[original_asso_bs-1].x)**2+
                    (self.y - self.BSs[original_asso_bs-1].y)**2
                )
                rate = 0
                if 1 - (dis_origin_bs/r)**4 > 0:
                    rate = 1 - (dis_origin_bs/r)**4
                if max_asso_bs_sinr - original_asso_bs_sinr > threshold*rate:
                    # print(f'current: {max_asso_bs}, {max_asso_bs_sinr}, original: {self.asso_bs} {original_asso_bs_sinr}, v = {self.velocity}')
                    self.handoff_hist.append(f'{self.timer:>6.2f}s | {self.asso_bs:>2} | {max_asso_bs:>2}')
                    self.asso_bs = max_asso_bs
                    # self.compute_HO_delay(MSs)
                    return False
        return False

    def max_sinr_handoff(self, MSs):
        original_asso_bs = self.asso_bs
        original_asso_bs_sinr = self.sinr(original_asso_bs, MSs)
        # Find BS with max sinr
        max_asso_bs = self.asso_bs
        max_asso_bs_sinr = original_asso_bs_sinr
        for bs_idx in range(len(self.BSs)):
            bs_idx_sinr = self.sinr(bs_idx, MSs)
            if bs_idx_sinr > max_asso_bs_sinr:
                max_asso_bs = bs_idx + 1
                max_asso_bs_sinr = bs_idx_sinr
        if original_asso_bs != max_asso_bs:
            # Need handoff
            # print(f'current: {max_asso_bs} {max_asso_bs_sinr}, original: {original_asso_bs}, {original_asso_bs_sinr},')
            self.handoff_hist.append(f'{self.timer:>6.2f}s | {original_asso_bs:>2} | {max_asso_bs:>2}')
            self.asso_bs = max_asso_bs
            # self.compute_HO_delay(MSs)
            return False
        
        return False

    def velocity_adaptive_handoff_2(self, MSs):
        need_handoff = False
        if np.abs(self.velocity) > 7.5 :
            need_handoff = self.check_handoff_v2(MSs, threshold = 2.5)
        else:
            need_handoff = self.check_handoff_v2(MSs, threshold = 5)
        # print(need_handoff)
        # return need_handoff
        return False

    def velocity_adaptive_handoff_4(self, MSs):
        need_handoff = False
        if np.abs(self.velocity) > 11.25 :
            need_handoff = self.check_handoff_v2(MSs, threshold = 1)
        elif 7.5 < np.abs(self.velocity) < 11.25:
            need_handoff = self.check_handoff_v2(MSs, threshold = 2.5)
        elif 3.75 < np.abs(self.velocity) < 7.5:
            need_handoff = self.check_handoff_v2(MSs, threshold = 5)
        else:
            need_handoff = self.check_handoff_v2(MSs, threshold = 7.5)

        # print(need_handoff)
        # return need_handoff
        return False

    def sinr(self, bs_chosed, MSs):
        '''
        Calculate SINR of the ms for a chosed bs
        '''
        I = 0 # Watt
        # for ms in MSs:
        #     if ms.asso_bs == bs_chosed and ms.x != self.x and ms.y != self.y:
        #         I += recv_power_gen(ms.x, ms.y, self.BSs[bs_chosed-1].x, self.BSs[bs_chosed-1].y)[1]
        for bs in self.BSs:
            if bs.ID != bs_chosed:
                I += recv_power_gen(ms.x, ms.y, bs.x, bs.y)[1]
        S = recv_power_gen(self.x, self.y, self.BSs[bs_chosed-1].x, self.BSs[bs_chosed-1].y)[1]
        B = 10*10**6
        T = 300
        k = 1.38*10**(-23)
        N_thermal = k*T*B

        SINR = S / (N_thermal + I)

        return 10*np.log10(SINR)    

    def data_rate(self, MSs):
        """
        return data rate of MS connect to BS
        (Downlink)
        """
        # I = 0 # Watt
        # for ms in MSs:
        #     if ms.asso_bs == self.asso_bs and ms.x != self.x and ms.y != self.y:
        #         I += recv_power_gen(ms.x, ms.y, self.BSs[self.asso_bs-1].x, self.BSs[self.asso_bs-1].y)[1]
        # S = recv_power_gen(self.x, self.y, self.BSs[self.asso_bs-1].x, self.BSs[self.asso_bs-1].y)[1]
        B = 10*10**6
        T = 300
        k = 1.38*10**(-23)
        N_thermal = k*T*B

        # SINR = S / (N_thermal + I)
        SINR_dB = self.sinr(self.asso_bs, MSs)
        SINR = 10**(SINR_dB/10)
        dr = B * np.log2(1 + SINR)
        # print(dr[0])
        return dr[0]

    def compute_HO_delay(self, MSs):
        # HO_command = 0.1
        # data_rate = self.data_rate(MSs)
        # HO_access = 1000 / data_rate
        # HO_complete = 0.02
        # self.HO_sleep_time = HO_command + HO_access + HO_complete    
        self.HO_sleep_time = 0    
    
            
def recv_power_gen(x, y, bs_x, bs_y):
    d = np.sqrt((x-bs_x)**2+(y-bs_y)**2)
    s = np.random.normal(loc=0, scale=6)
    pt = 33-30 #dBm to dB
    gt = 14
    gr = 14
    pr = 23-30
    ht = 50+1.5
    hr = 1.5
    g_d = (ht*hr)**2/(d**4)
    P_recv = 10*np.log10(g_d)+pr+gr+gt+s #dB
    P_recv = 10**(P_recv/10) # Watt

    return d, P_recv

if __name__=="__main__":
    r = 500/2/np.sqrt(3)*2
    BSs = np.array([ (0,0), 
            (1,2), (0,3), (2,4), (3,3), (2,1), (4,2), (3,0),
           (-1,1), (-2,2), (-3,0),
           (-2,-1), (-4,-2), (-3,-3),(-1,-2), (-2,-4),
           (1,-1), (2,-2),(0,-3)
           ])
    BSs = np.matmul(BSs, np.array([[r, 0], [-r/2, np.sqrt(3)*r/2]]))
    BS_Hexagons = [ Hexagon(x,y,r, id+1) for id, (x,y) in enumerate(BSs.tolist()) ]
    fig, ax = plt.subplots(1,1)

    colorList = [ np.random.rand(1, 3) for i in range(len(BSs))]
    for i in range(len(BSs)):
        ax.scatter(BSs[i,0], BSs[i,1], c=colorList[i], label=f'BS {i+1}')
        # ax.scatter(BSs[i,0], BSs[i,1], marker='a', label=f'BS {i+1}')
        ax.annotate(f'BS {i+1}', (BSs[i,0], BSs[i,1]) )
    
    for hex in BS_Hexagons:
        ax.fill(hex.hex_x, hex.hex_y, facecolor='none', edgecolor='blue', alpha=1)
    ax.legend(bbox_to_anchor = (1.2, 0.5), loc='center right')

    ms_coords_x = []
    ms_coords_y = []
    MSs = []
    num_ms = 10
    for idx in range(num_ms):
        bs_id = np.random.randint(0,19)
        # print(bs_id)
        counter = 0
        ms_x = 0
        ms_y = 0
        while counter<1:
            x = np.random.uniform(low = -r+BS_Hexagons[bs_id].x, high = r+BS_Hexagons[bs_id].x, size=1)
            y = np.random.uniform(low = -r+BS_Hexagons[bs_id].y, high = r+BS_Hexagons[bs_id].y, size=1)
            if (x-BS_Hexagons[bs_id].x)**2+(y-BS_Hexagons[bs_id].y)**2<=r**2 and \
                np.abs(y-BS_Hexagons[bs_id].y)<=r/2*np.sqrt(3) and \
                np.sqrt(3)*np.abs(x-BS_Hexagons[bs_id].x)+np.abs(y-BS_Hexagons[bs_id].y)-np.sqrt(3)*r<=0:
                ms_x = x
                ms_y = y
                counter += 1
        ms = MobileDevice(ms_x, ms_y, idx, BS_Hexagons)
        ms_coords_x.append(ms_x)
        ms_coords_y.append(ms_y)
        MSs.append(ms)
    
    plt.savefig('ax1.png')
    
    fig2, ax2 = plt.subplots(1,1)
    for i in range(len(BSs)):
        ax2.scatter(BSs[i,0], BSs[i,1], c=colorList[i], label=f'BS {i+1}')
        # ax.scatter(BSs[i,0], BSs[i,1], marker='a', label=f'BS {i+1}')
        ax2.annotate(f'BS {i+1}', (BSs[i,0], BSs[i,1]) )
    
    for hex in BS_Hexagons:
        ax2.fill(hex.hex_x, hex.hex_y, facecolor='none', edgecolor='blue', alpha=1)
    
    # for ms_x, ms_y in zip(ms_coords_init_x, ms_coords_init_y):
    #     ax2.scatter(ms_x, ms_y, c='r', marker='*', s=5, label='ms')

    ax2.scatter(ms_coords_x, ms_coords_y, c='r', marker='*', s=5, label='ms')

    # for ms in MSs:
    #     ms.start_simulation()
    timeLmt = 100
    dt = 0.01
    steps = int(timeLmt/dt)
    threshold = 5
    hnd_ply = 'DIS'
    for step in range(steps):
        for idx, ms in enumerate(MSs):
            # ms.one_move(ms_coords_x, ms_coords_y, threshold, MSs, dt, 'SINR' )
            # ms.one_move(ms_coords_x, ms_coords_y, threshold, MSs, dt, 'SINR_global' )
            # ms.one_move(ms_coords_x, ms_coords_y, threshold, MSs, dt, 'MaxSINR' )
            ms.one_move(ms_coords_x, ms_coords_y, threshold, MSs, dt, hnd_ply )
            ms_coords_x[idx] = ms.x
            ms_coords_y[idx] = ms.y
        if (step + 1) % 100 == 0:
            print((step+1)/100)

    # for ms in MSs:
    #     # ax2.plot(ms.trackx, ms.tracky, c='r')
    #     print('='*10+str(ms.id)+'='*10)
    #     for his in ms.handoff_hist:
    #         print(his)

    with open('output.txt', 'w') as f:
        for ms in MSs:
            # print('='*10+str(ms.id)+'='*10)
            f.write('='*10+'ms '+str(ms.id)+'='*10)
            f.write('\n')
            f.write('time | src ID | dest ID')
            f.write('\n')

            for his in ms.handoff_hist:
                # print(his)
                f.write(his)
                f.write('\n')
        
    ax2.legend(bbox_to_anchor = (1.2, 0.5), loc='center right')

    
    plt.tight_layout()
    # plt.show()
    plt.savefig('ax2.png')

    total_handoff = 0
    mean_data_rate = []
    mean_bad_signal_time = []
    mean_sent_bits = []
    ms_v = []
    for ms in MSs:
        # print(len(ms.handoff_hist))
        total_handoff += len(ms.handoff_hist)
        print(f'{np.mean(ms.drs):.2e}, {ms.bad_signal_time:>.3f}, {ms.sent_bits/timeLmt:.2e}')
        mean_data_rate.append(np.mean(ms.drs))
        mean_bad_signal_time.append(ms.bad_signal_time)
        mean_sent_bits.append(ms.sent_bits)
        ms_v.append(ms.velocity)
    
    fig3, ax3 = plt.subplots(1,1)
    ax3.hist(np.abs(ms_v), 10)
    plt.tight_layout()
    plt.savefig('ax3.png')


    print(f'mean data rate: {np.mean(mean_data_rate):.2e} bis/s')
    print(f'mean bad sig t: {np.mean(mean_bad_signal_time):.2e} s')
    print(f'mean throughput: {np.mean(mean_sent_bits)/timeLmt:.2e} bis/s')
    print(hnd_ply)
    print(num_ms)
    print(f'{np.mean(mean_data_rate):.2e}, {np.mean(mean_bad_signal_time):.2e}, {np.mean(mean_sent_bits)/timeLmt:.2e}, {total_handoff}')
    print(f"Total number of handoffs: {total_handoff}")
