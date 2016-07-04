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
% IEEE14 ����20��֧·������һ��֧·
% n-1 ��ȫУ��, ���ζϿ�ÿ����·�����㳱��
mpopt = mpoption('verbose', 0, 'out.all', 0); % �������㲻������
rOrigin = runpf('my_case14.m', mpopt); % ԭ��������������

MPC = loadcase(filename);
branchOff = MPC.branch(iBranch, [F_BUS, T_BUS]);
MPC.branch(iBranch, :) = []; % �Ͽ�֧·iBranch

savecase('my_case14_SC.m', MPC);
rNow = runpf('my_case14_SC.m', mpopt); % �µ�����������
flagVoltageViolation = any(abs(rNow.bus(:, VM) - 1) > 0.5); % �ж϶Ͽ�֧·�������ѹ�Ƿ�Խ��
voltageViolation = [];
for k = 1:size(MPC.bus)
    if abs(rNow.bus(k, VM) - 1) > 0.5
        voltageViolation = [voltageViolation; rNow.bus(k, [BUS_I, VM])];
    end
end
branchPowerOrigin = rOrigin.branch(:, [PF, QF, PT, QT]);
branchPowerOrigin(iBranch, :) = [];
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
        powerViolation = [powerViolation; powerViolationBranch(j, 1:2), ...
            branchApparentPowerOrigin(j, :), branchApparentPowerNow(j, :)];
    end
end