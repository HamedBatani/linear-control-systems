clear; clc; close all; 
s = tf('s');

% plant models
den = (s^4 + 23.33*s^3 + 3367*s^2 + 10000*s + 150000);
G = (-16.67*s^2)/den;
H = (10000*s^2 + 100000*s)/den;

% controller k(s) from q3
Klead = 1.6332548e6*(s+16.8397)/(s+764.1389);
K = -Klead/s^2;

% time, reference, disturbance
t  = 0:1e-3:2;
r  = ones(size(t));
yr = 0.1 + 0.05*sin(10*t) + 0.02*cos(20*t);

% disturbance estimator q(s)=h^{-1}(s)f(s)
lambda = 0.02;
F = 1/(lambda*s + 1)^2;
Q = minreal((1/H)*F);

% cancellation filter kd(s) = -h(s)/g(s)
Kd_tf = minreal(-H/G);

% named interconnection blocks
G.InputName='u';  G.OutputName='yG';
H.InputName='yr'; H.OutputName='yH';
SumY = sumblk('y = yG + yH');
SumE = sumblk('e = r - y');
Kblk = K; Kblk.InputName='e'; Kblk.OutputName='u_fb';
SumEhat = sumblk('ehat = y - yG');
Q.InputName='ehat'; Q.OutputName='yhat';
Kd_tf.InputName='yhat'; Kd_tf.OutputName='u_ff_hat';
Kd_tf2 = Kd_tf; Kd_tf2.InputName='yr'; Kd_tf2.OutputName='u_ff_true';

SumU_A = sumblk('u = u_fb');
SumU_B = sumblk('u = u_fb + u_ff_hat');
SumU_C = sumblk('u = u_fb + u_ff_true');

sysA = connect(G,H,SumY,SumE,Kblk,SumU_A,SumEhat,Q, {'r','yr'}, {'y','u','yhat'});
sysB = connect(G,H,SumY,SumE,Kblk,SumU_B,SumEhat,Q,Kd_tf, {'r','yr'}, {'y','u','yhat'});
sysC = connect(G,H,SumY,SumE,Kblk,SumU_C,Kd_tf2, {'r','yr'}, {'y','u'});

in = [r(:) yr(:)];
outA = lsim(sysA,in,t);
outB = lsim(sysB,in,t);
outC = lsim(sysC,in,t);

yA = outA(:,1); uA = outA(:,2); yhatA = outA(:,3);
yB = outB(:,1); uB = outB(:,2); yhatB = outB(:,3);
yC = outC(:,1); uC = outC(:,2);

fprintf('max|yB-yA| = %.6f\n', max(abs(yB-yA)));
fprintf('max|yC-yA| = %.6f\n', max(abs(yC-yA)));

eA = r(:) - yA; 
eB = r(:) - yB; 
eC = r(:) - yC;

idx = t >= 0.5;
fprintf('\nRMS(e) for t>=0.5s:\n');
fprintf('Baseline: %.6f\n', rms(eA(idx)));
fprintf('Estimated cancellation: %.6f\n', rms(eB(idx)));
fprintf('Ideal cancellation: %.6f\n', rms(eC(idx)));

figure;
plot(t,r,'k--','LineWidth',1); hold on;
plot(t,yA,'LineWidth',1); plot(t,yB,'LineWidth',1); plot(t,yC,'LineWidth',1);
grid on; xlabel('time (s)'); ylabel('y(t)');
title('q4: baseline vs estimated cancellation vs ideal','Interpreter','latex');
legend({'$r(t)$','baseline','estimated','ideal'},'Interpreter','latex','Location','best');

figure;
plot(t,yr,'LineWidth',1); hold on;
plot(t,yhatB,'LineWidth',1);
grid on; xlabel('time (s)'); ylabel('disturbance');
title('q4: $y_r(t)$ vs $\hat{y}_r(t)$','Interpreter','latex');
legend({'$y_r(t)$','$\hat{y}_r(t)$'},'Interpreter','latex','Location','best');

figure;
plot(t,uA,'LineWidth',1); hold on;
plot(t,uB,'LineWidth',1); plot(t,uC,'LineWidth',1);
grid on; xlabel('time (s)'); ylabel('u(t)');
title('q4: control effort','Interpreter','latex');
legend({'baseline','estimated','ideal'},'Interpreter','latex','Location','best');