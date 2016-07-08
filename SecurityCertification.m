function [branchOff, flagVoltageViolation, voltageViolation, flagPowerViolation, powerViolation] = ...
    SecurityCertification(filename, iBranch)
% 参数含义
% 输入参数
% filename		电网数据文件
% iBranch		断开支路编号
% 输出参数
% branchOff 		断开支路起始节点编号
% flagVoltageViolation	判断断开支路iBranch后电压是否越限，如果越限，则�?，否则为0
% voltageViolation	记录越限节点电压
% flagPowerViolation	判断断开支路iBranch后线路功率是否越限，如果越限，则�?，否则为0
% powerViolation	记录越限线路功率情况，数据格式为
% PowerViolation = 
%	各列含义为起始节点�?末端节点、线路首端流向末端视在功率�?线路末端流向首端视在功率�?
%	线路首端流向末端有功功率、线路首端流向末端无功功率�?
%	线路末端流向首端有功功率、线路末端流向首端无功功�?
%	[4.0000	9.0000	16.5119	16.4341	16.4326	1.6161	-16.4326	-0.2195
%	4.0000	9.0000	31.3803	30.6433	30.5782	7.0496	-30.5782	-1.9961
%	相邻两列支路编号（每行前两列）相同，分别为断�?��路iBranch前越限支路功率状况，�?
%	断开iBranch后支路功率状�?
%	6.0000	11.0000	7.7175	7.6241	6.9120	3.4327	-6.8607	-3.3253
%	6.0000	11.0000	16.4393	16.0894	15.8367	4.4102	-15.6039	-3.9227]

[PQ, PV, REF, NONE, BUS_I, BUS_TYPE, PD, QD, GS, BS, BUS_AREA, VM, ...
    VA, BASE_KV, ZONE, VMAX, VMIN, LAM_P, LAM_Q, MU_VMAX, MU_VMIN] = idx_bus;
[F_BUS, T_BUS, BR_R, BR_X, BR_B, RATE_A, RATE_B, RATE_C, ...
    TAP, SHIFT, BR_STATUS, PF, QF, PT, QT, MU_SF, MU_ST, ...
    ANGMIN, ANGMAX, MU_ANGMIN, MU_ANGMAX] = idx_brch;
[GEN_BUS, PG, QG, QMAX, QMIN, VG, MBASE, GEN_STATUS, PMAX, PMIN, ...
    MU_PMAX, MU_PMIN, MU_QMAX, MU_QMIN, PC1, PC2, QC1MIN, QC1MAX, ...
    QC2MIN, QC2MAX, RAMP_AGC, RAMP_10, RAMP_30, RAMP_Q, APF] = idx_gen;
% IEEE14 包含20个支路，增加�?��支路
mpopt = mpoption('verbose', 0, 'out.all', 0); % 潮流计算不输出结�?
% mpopt = mpoption;
rOrigin = runpf(filename, mpopt); % 原来电网潮流计算
rOrigin.branch(iBranch, :) = [];

MPC = loadcase(filename);
branchOff = MPC.branch(iBranch, [F_BUS, T_BUS]);
MPC.branch(iBranch, :) = []; % 断开支路iBranch

% savecase('my_case14_SC.m', MPC);
rNow = runpf(MPC, mpopt); % 新电网潮流计�?
flagVoltageViolation = any(abs(rNow.bus(:, VM) - 1) > 0.5); % 判断断开支路后电网电压是否越�?
voltageViolation = [];
for k = 1:size(MPC.bus)
    if abs(rNow.bus(k, VM) - 1) > 0.5
        voltageViolation = [voltageViolation; rNow.bus(k, [BUS_I, VM])];
    end
end
branchPowerOrigin = rOrigin.branch(:, [PF, QF, PT, QT]);
% branchPowerOrigin(iBranch, :) = [];
branchApparentPowerOrigin = [sqrt(branchPowerOrigin(:, 1) .^ 2 + branchPowerOrigin(:, 2) .^ 2) ...
    sqrt(branchPowerOrigin(:, 3) .^ 2 + branchPowerOrigin(:, 4) .^ 2)];
branchPowerNow = rNow.branch(:, [PF, QF, PT, QT]);
branchApparentPowerNow = [sqrt(branchPowerNow(:, 1) .^ 2 + branchPowerNow(:, 2) .^ 2) ...
    sqrt(branchPowerNow(:, 3) .^ 2 + branchPowerNow(:, 4) .^ 2)];
powerViolationFlag = branchApparentPowerNow > 1.5 * branchApparentPowerOrigin;
flagPowerViolation = any(any(powerViolationFlag));
powerViolationBranch = [rNow.branch(:, [F_BUS, T_BUS]), powerViolationFlag];
powerViolation = [];
for j = 1:size(MPC.branch, 1)
    if any(powerViolationBranch(j, 3:4) ~= 0)
%         powerViolation = [powerViolation; powerViolationBranch(j, :), ...
%             branchApparentPowerOrigin(j, :), branchApparentPowerNow(j, :)];
        powerViolation = [powerViolation; rOrigin.branch(j, [F_BUS, T_BUS]), ...
            branchApparentPowerOrigin(j, :), rOrigin.branch(j, [PF, QF, PT, QT]); ...
            rNow.branch(j, [F_BUS, T_BUS]), branchApparentPowerNow(j, :), ...
            rNow.branch(j, [PF, QF, PT, QT])];
    end
end
