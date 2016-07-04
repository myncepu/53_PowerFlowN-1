clc, clear all;
%%
[PQ, PV, REF, NONE, BUS_I, BUS_TYPE, PD, QD, GS, BS, BUS_AREA, VM, ...
    VA, BASE_KV, ZONE, VMAX, VMIN, LAM_P, LAM_Q, MU_VMAX, MU_VMIN] = idx_bus;
[F_BUS, T_BUS, BR_R, BR_X, BR_B, RATE_A, RATE_B, RATE_C, ...
    TAP, SHIFT, BR_STATUS, PF, QF, PT, QT, MU_SF, MU_ST, ...
    ANGMIN, ANGMAX, MU_ANGMIN, MU_ANGMAX] = idx_brch;
[GEN_BUS, PG, QG, QMAX, QMIN, VG, MBASE, GEN_STATUS, PMAX, PMIN, ...
    MU_PMAX, MU_PMIN, MU_QMAX, MU_QMIN, PC1, PC2, QC1MIN, QC1MAX, ...
    QC2MIN, QC2MAX, RAMP_AGC, RAMP_10, RAMP_30, RAMP_Q, APF] = idx_gen;

filename = 'my_case14.m';
%% 断开支路1-2
iBranch = 21;
switch iBranch
    case 1
        [bOff, fV, V, fP, P] = SecurityCertification(filename, iBranch)
        % 修改电网参数，使得线路功率不越限
        MPC = loadcase(filename);
        MPC.gen(2, [PG, QG]) = MPC.gen(1, [PG, QG]); % 调整发电机2输出功率
        [bOff, fV, V, fP, P] = SecurityCertification(MPC, iBranch)
    case 2
        [bOff, fV, V, fP, P] = SecurityCertification(filename, iBranch)
        % 修改电网参数，使得线路功率不越限
        MPC = loadcase(filename);
        MPC.gen(4, [PG, QG]) = MPC.gen(1, [PG, QG]); % 调整发电机4输出功率
        [bOff, fV, V, fP, P] = SecurityCertification(MPC, iBranch)
    case 3 % 支路2-3双回路断开一回路
        [bOff, fV, V, fP, P] = SecurityCertification(filename, iBranch)
        % 修改电网参数，使得线路功率不越限
        MPC = loadcase(filename);
        MPC.gen(3, [PG, QG]) = MPC.gen(1, [PG, QG]);
        MPC.bus(4, [PD, QD]) = MPC.bus(4, [PD, QD]) * 1.1;
        [bOff, fV, V, fP, P] = SecurityCertification(MPC, iBranch)
    case 4
        [bOff, fV, V, fP, P] = SecurityCertification(filename, iBranch)
        % 修改电网参数，使得线路功率不越限
        MPC = loadcase(filename);
        MPC.gen(4, [PG, QG]) = MPC.gen(1, [PG, QG]);
        [bOff, fV, V, fP, P] = SecurityCertification(MPC, iBranch)
    case 5
        [bOff, fV, V, fP, P] = SecurityCertification(filename, iBranch)
    case 6
        [bOff, fV, V, fP, P] = SecurityCertification(filename, iBranch)
    case 7
        [bOff, fV, V, fP, P] = SecurityCertification(filename, iBranch)
        MPC = loadcase(filename);
        MPC.gen(4, [PG, QG]) = MPC.gen(1, [PG, QG]);
        MPC.gen(5, [PG, QG]) = MPC.gen(1, [PG, QG]);
        [bOff, fV, V, fP, P] = SecurityCertification(MPC, iBranch)
    case 8
        [bOff, fV, V, fP, P] = SecurityCertification(filename, iBranch)
        MPC = loadcase(filename);
        MPC.gen(4, [PG, QG]) = MPC.gen(1, [PG, QG]);
        MPC.bus(9, [PD, QD]) = MPC.bus(9, [PD, QD]) * 1.1;
        [bOff, fV, V, fP, P] = SecurityCertification(MPC, iBranch)
    case 9
        [bOff, fV, V, fP, P] = SecurityCertification(filename, iBranch)
        MPC = loadcase(filename);
        MPC.gen(5, [PG, QG]) = MPC.gen(1, [PG, QG]);
        [bOff, fV, V, fP, P] = SecurityCertification(MPC, iBranch)
    case 10 % 有问题
        [bOff, fV, V, fP, P] = SecurityCertification(filename, iBranch)
        MPC = loadcase(filename);
        % MPC.gen(4, [PG, QG]) = MPC.gen(1, [PG, QG]);
        % MPC.gen(5, [PG, QG]) = MPC.gen(1, [PG, QG]);
        MPC.bus(:, [PD, QD]) = MPC.bus(:, [PD, QD]) * 1.1;
        [bOff, fV, V, fP, P] = SecurityCertification(MPC, iBranch)
    case 11
        [bOff, fV, V, fP, P] = SecurityCertification(filename, iBranch)
        MPC = loadcase(filename);
        MPC.bus(10, [PD, QD]) = MPC.bus(10, [PD, QD]) * 0.1;
        MPC.bus(11, [PD, QD]) = MPC.bus(11, [PD, QD]) * 0.1;
        [bOff, fV, V, fP, P] = SecurityCertification(MPC, iBranch)
    case 12
        [bOff, fV, V, fP, P] = SecurityCertification(filename, iBranch)
        MPC = loadcase(filename);
        MPC.bus(12, [PD, QD]) = MPC.bus(12, [PD, QD]) * 0.1;
        [bOff, fV, V, fP, P] = SecurityCertification(MPC, iBranch)
    case 13 % 有问题
        [bOff, fV, V, fP, P] = SecurityCertification(filename, iBranch)
        MPC = loadcase(filename);
        % MPC.bus(9:14, [PD, QD]) = MPC.bus(9:14, [PD, QD]) * 0.8;
        % MPC.bus(12, [PD, QD]) = MPC.bus(12, [PD, QD]) + 5;
        % MPC.bus(13:14, [PD, QD]) = MPC.bus(13:14, [PD, QD]) * 0.5;
        MPC.gen(5, [PG, QG]) = MPC.gen(5, [PG, QG]) * 0.5;
        MPC.bus(12, [PD, QD]) = MPC.bus(12, [PD, QD]) * 0.5;
        MPC.bus(13, [PD, QD]) = MPC.bus(13, [PD, QD]) * 0.0;
        MPC.bus(14, [PD, QD]) = MPC.bus(14, [PD, QD]) * 0.3;
        [bOff, fV, V, fP, P] = SecurityCertification(MPC, iBranch)
    case 14
        [bOff, fV, V, fP, P] = SecurityCertification(filename, iBranch)
    case 15 % 有问题
        [bOff, fV, V, fP, P] = SecurityCertification(filename, iBranch)
        MPC = loadcase(filename);
        MPC.bus(9, [PD, QD]) = MPC.bus(9, [PD, QD]) * 0.3;
        [bOff, fV, V, fP, P] = SecurityCertification(MPC, iBranch)
    case 16
        [bOff, fV, V, fP, P] = SecurityCertification(filename, iBranch)
        MPC = loadcase(filename);
        MPC.bus(10, [PD, QD]) = MPC.bus(10, [PD, QD]) * 0.1;
        [bOff, fV, V, fP, P] = SecurityCertification(MPC, iBranch)
    case 17
        [bOff, fV, V, fP, P] = SecurityCertification(filename, iBranch)
        MPC = loadcase(filename);
        MPC.bus(14, [PD, QD]) = MPC.bus(14, [PD, QD]) * 0.1;
        [bOff, fV, V, fP, P] = SecurityCertification(MPC, iBranch)
    case 18
        [bOff, fV, V, fP, P] = SecurityCertification(filename, iBranch)
        MPC = loadcase(filename);
        MPC.bus(10, [PD, QD]) = MPC.bus(10, [PD, QD]) * 0.1;
        [bOff, fV, V, fP, P] = SecurityCertification(MPC, iBranch)
    case 19
        [bOff, fV, V, fP, P] = SecurityCertification(filename, iBranch)
    case 20
        [bOff, fV, V, fP, P] = SecurityCertification(filename, iBranch)
        MPC = loadcase(filename);
        MPC.bus(14, [PD, QD]) = MPC.bus(14, [PD, QD]) * 0.1;
        [bOff, fV, V, fP, P] = SecurityCertification(MPC, iBranch)
    case 21
        [bOff, fV, V, fP, P] = SecurityCertification(filename, iBranch)
        % 修改电网参数，使得线路功率不越限
        MPC = loadcase(filename);
        MPC.gen(3, [PG, QG]) = MPC.gen(1, [PG, QG]);
        MPC.bus(4, [PD, QD]) = MPC.bus(4, [PD, QD]) * 1.1;
        [bOff, fV, V, fP, P] = SecurityCertification(MPC, iBranch)
    otherwise
        
end
