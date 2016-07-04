function [branchOff, flagVoltageViolation, voltageViolation, flagPowerViolation, powerViolation] = ...
    SecurityCertification(filename, iBranch)

[PQ, PV, REF, NONE, BUS_I, BUS_TYPE, PD, QD, GS, BS, BUS_AREA, VM, ...
    VA, BASE_KV, ZONE, VMAX, VMIN, LAM_P, LAM_Q, MU_VMAX, MU_VMIN] = idx_bus;
[F_BUS, T_BUS, BR_R, BR_X, BR_B, RATE_A, RATE_B, RATE_C, ...
    TAP, SHIFT, BR_STATUS, PF, QF, PT, QT, MU_SF, MU_ST, ...
    ANGMIN, ANGMAX, MU_ANGMIN, MU_ANGMAX] = idx_brch;
[GEN_BUS, PG, QG, QMAX, QMIN, VG, MBASE, GEN_STATUS, PMAX, PMIN, ...
    MU_PMAX, MU_PMIN, MU_QMAX, MU_QMIN, PC1, PC2, QC1MIN, QC1MAX, ...
    QC2MIN, QC2MAX, RAMP_AGC, RAMP_10, RAMP_30, RAMP_Q, APF] = idx_gen;
% IEEE14 包含20个支路，增加一个支路
% n-1 安全校验, 依次断开每条线路，计算潮流
mpopt = mpoption('verbose', 0, 'out.all', 0); % 潮流计算不输出结果
rOrigin = runpf(filename, mpopt); % 原来电网潮流计算
rOrigin.branch(iBranch, :) = [];

MPC = loadcase(filename);
branchOff = MPC.branch(iBranch, [F_BUS, T_BUS]);
MPC.branch(iBranch, :) = []; % 断开支路iBranch

% savecase('my_case14_SC.m', MPC);
rNow = runpf(MPC, mpopt); % 新电网潮流计算
flagVoltageViolation = any(abs(rNow.bus(:, VM) - 1) > 0.5); % 判断断开支路后电网电压是否越限
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