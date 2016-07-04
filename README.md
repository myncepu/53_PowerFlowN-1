以支路1-2为例
对支路1-2断开前后的电网进行潮流计算，判断电压和线路功率是否越线
iBranch = 1;
filename = 'my_case14.m';
[bOff, fV, V, fP, P] = SecurityCertification(filename, iBranch)
% 修改电网参数，使得线路功率不越限
MPC = loadcase(filename);
MPC.gen(2, [PG, QG]) = MPC.gen(1, [PG, QG]); % 调整发电机2输出功率
[bOff, fV, V, fP, P] = SecurityCertification(MPC, iBranch)
