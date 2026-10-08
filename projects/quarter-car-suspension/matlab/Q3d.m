clear; clc; close all;
s = tf('s');

% models
den = (s^4 + 23.33*s^3 + 3367*s^2 + 10000*s + 150000);
G = (-16.67*s^2)/den;
H = (10000*s^2 + 100000*s)/den;

% K from part (b):  -1/s^2 with lead
Klead = 1.6332548e6*(s+16.8397)/(s+764.1389);
K = -Klead/s^2;

% time + signals
t  = 0:1e-3:2;

% R(t) from part (a) (EDIT if your R(t) is different)
r  = ones(size(t));

% disturbance yr(t)
yr = 0.1 + 0.05*sin(10*t) + 0.02*cos(20*t);

% two cases to compare
Kd1 = 1.0;   % Part (b) (no scaling)
Kd2 = 0.10;  % Part (c) (scaled disturbance)

L   = G*K;
Tr  = feedback(L,1);       % y/r
Ty1 = (Kd1*H)/(1+L);       % y/yr for case 1
Ty2 = (Kd2*H)/(1+L);       % y/yr for case 2

y1 = lsim(Tr,r,t) + lsim(Ty1,yr,t);
y2 = lsim(Tr,r,t) + lsim(Ty2,yr,t);

e1 = r - y1;
e2 = r - y2;

% plots (compare in same figures)
figure;
plot(t,r,'k--',t,y1,'LineWidth',1); hold on;
plot(t,y2,'LineWidth',1); grid on;
xlabel('Time (s)'); ylabel('Output');
title('Part (d): y(t) comparison (same K, different K_d)');
legend('r(t)','y(t), K_d=1','y(t), K_d=0.1','Location','best');

figure;
plot(t,e1,'LineWidth',1); hold on;
plot(t,e2,'LineWidth',1); grid on;
xlabel('Time (s)'); ylabel('e(t)=r(t)-y(t)');
title('Part (d): tracking error comparison');
legend('e(t), K_d=1','e(t), K_d=0.1','Location','best');

figure;
plot(t,yr,'LineWidth',1); grid on;
xlabel('Time (s)'); ylabel('y_r(t)');
title('Disturbance signal y_r(t)');

figure;
pzmap(Tr); grid on;
title('Closed-loop pole-zero map (poles unchanged by K_d)');

% compare Ts and OS in command window (based on the *resulting* y(t))
info1 = stepinfo(y1,t,'SettlingTimeThreshold',0.02);
info2 = stepinfo(y2,t,'SettlingTimeThreshold',0.02);

fprintf('\nCASE 1: K_d = %.2f\n',Kd1);
fprintf('Ts = %.6f s\n',info1.SettlingTime);
fprintf('OS = %.4f %%\n',info1.Overshoot);

fprintf('\nCASE 2: K_d = %.2f\n',Kd2);
fprintf('Ts = %.6f s\n',info2.SettlingTime);
fprintf('OS = %.4f %%\n',info2.Overshoot);