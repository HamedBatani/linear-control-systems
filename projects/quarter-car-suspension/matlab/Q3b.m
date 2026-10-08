clear; clc; close all;
s = tf('s');

% plant and disturbance
den = (s^4 + 23.33*s^3 + 3367*s^2 + 10000*s + 150000);
G = (-16.67*s^2)/den;
H = (10000*s^2 + 100000*s)/den;

% final controller from part (3b):  -1/s^2  +  lead
Klead = 1.6332548e6*(s+16.8397)/(s+764.1389);
K = -Klead/s^2;

t  = 0:1e-3:2;

% reference R(t) from part (a)  (edit if different)
r  = ones(size(t));

% disturbance yr(t)
yr = 0.1 + 0.05*sin(10*t) + 0.02*cos(20*t);

L   = G*K;
Tr  = feedback(L,1);      % y/r
Tyr = H/(1+L);            % y/yr

y = lsim(Tr,r,t) + lsim(Tyr,yr,t);

figure;
plot(t,r,'--',t,y,'LineWidth',1);
grid on;
xlabel('Time (s)'); ylabel('Output');
legend('R(t)','y(t)');
title('Closed-loop output y(t) with reference and disturbance');

figure;
plot(t,yr,'LineWidth',1);
grid on;
xlabel('Time (s)'); ylabel('y_r(t)');
title('Injected disturbance signal y_r(t)');

figure;
pzmap(Tr);
grid on;
title('Pole-Zero Map of the Closed-Loop System');