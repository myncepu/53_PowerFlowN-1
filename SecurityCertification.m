% function [flagVoltage, voltage, flagPower, Power] = SecurityCertification(filename, iBranch)

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
r0 = runpf('my_case14.m', mpopt);
for iBranch = 1:21
    MPC = loadcase('my_case14.m');
    MPC.branch(iBranch, :) = [];
    savecase('my_case14_SC.m', MPC);
    r(iBranch) = runpf('my_case14_SC.m', mpopt);
    flagVoltage(iBranch) = any(abs(r(iBranch).bus(:, VM) - 1) > 0.5);
    branchPowerOrigin = r0.branch(:, [PF, QF, PT, QT]);
    branchPowerOrigin(iBranch, :) = [];
    branchApparentPowerOrigin = [sqrt(branchPowerOrigin(:, 1) .^ 2 + branchPowerOrigin(:, 2) .^ 2) ...
        sqrt(branchPowerOrigin(:, 3) .^ 2 + branchPowerOrigin(:, 4) .^ 2)];
    branchPowerNow = r(iBranch).branch(:, [PF, QF, PT, QT]);
    branchApparentPowerNow = [sqrt(branchPowerNow(:, 1) .^ 2 + branchPowerNow(:, 2) .^ 2) ...
        sqrt(branchPowerNow(:, 3) .^ 2 + branchPowerNow(:, 4) .^ 2)];
    powerViolationFlag = branchApparentPowerNow > 1.5 * branchApparentPowerOrigin;
    powerViolation(:, :, iBranch) = powerViolationFlag;
    powerViolationBranch = [r(iBranch).branch(:, [F_BUS, T_BUS]), powerViolationFlag];
    temp = [];
    for j = 1:20
        if any(powerViolationBranch(j, 3:4) ~= 0)
            temp = [temp; powerViolationBranch(j, :)];
        end
    end
    flagPowerViolationBranch{iBranch} = temp;
    flagPower(:, :, iBranch) = any(any(branchApparentPowerNow > 1.5 * branchApparentPowerOrigin));
end

% %% 1-2 支路断
% MPC = loadcase('my_case14.m');
% MPC.branch(1, :) = [];
% % MPC.gen(1, [PG, QG]) = MPC.gen(1, [PG, QG]) / 2;
% MPC.bus(:, [PD, QD]) = MPC.bus(:, [PD, QD]) / 2;
% savecase('my_case14_SC.m', MPC);
% result = runpf('my_case14_SC.m');
% 
% branchPowerOrigin = r0.branch(:, [PF, QF, PT, QT]);
% branchPowerOrigin(1, :) = [];
% branchApparentPowerOrigin = [sqrt(branchPowerOrigin(:, 1) .^ 2 + branchPowerOrigin(:, 2) .^ 2) ...
%     sqrt(branchPowerOrigin(:, 3) .^ 2 + branchPowerOrigin(:, 4) .^ 2)];
% branchPowerNow = result.branch(:, [PF, QF, PT, QT]);
% branchApparentPowerNow = [sqrt(branchPowerNow(:, 1) .^ 2 + branchPowerNow(:, 2) .^ 2) ...
%     sqrt(branchPowerNow(:, 3) .^ 2 + branchPowerNow(:, 4) .^ 2)];
% powerViolationFlag = branchApparentPowerNow > 1.5 * branchApparentPowerOrigin;
% powerViolationBranch = [result.branch(:, [F_BUS, T_BUS]), powerViolationFlag];
% temp = [];
% for j = 1:20
%     if any(powerViolationBranch(j, 3:4) ~= 0)
%         temp = [temp; powerViolationBranch(j, :)];
%     end
% end
% flagPowerViolationBranch = temp;