��֧·1-2Ϊ��
��֧·1-2�Ͽ�ǰ��ĵ������г������㣬�жϵ�ѹ����·�����Ƿ�Խ��
iBranch = 1;
filename = 'my_case14.m';
[bOff, fV, V, fP, P] = SecurityCertification(filename, iBranch)
% �޸ĵ���������ʹ����·���ʲ�Խ��
MPC = loadcase(filename);
MPC.gen(2, [PG, QG]) = MPC.gen(1, [PG, QG]); % ���������2�������
[bOff, fV, V, fP, P] = SecurityCertification(MPC, iBranch)
