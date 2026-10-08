clc;
clear;
close all;

M = 300;
m = 50;
k1 = 15000;
D = 1000;
k2 = 150000;

A = [0, 0, 1, 0;
     0, 0, 0, 1;
     -k1/M, k1/M, -D/M, D/M;
     k1/m, -(k1+k2)/m, D/m, -D/m];

B = [0;
     0;
     1/M;
     -1/m];

W = [0;
     0;
     0;
     k2/m];

C = [-k1/M, k1/M, -D/M, D/M];

Du = 1/M;
Dw = 0;

[numG, denG] = ss2tf(A, B, C, Du);
sys_G = tf(numG, denG);

[numH, denH] = ss2tf(A, W, C, Dw);
sys_H = tf(numH, denH);

disp('G(s):');
sys_G
disp('H(s):');
sys_H

t = 0:0.005:5;
yr = 0.1 + 0.05*sin(10*t) + 0.02*cos(20*t);
u = zeros(size(t));

sys_road_ss = ss(A, W, C, Dw);
[y_out, t_out, x_out] = lsim(sys_road_ss, yr, t);

figure;

subplot(3,1,1);
plot(t, yr, 'LineWidth', 1.5);
title('Road Disturbance Input y_r(t)');
xlabel('Time (s)');
ylabel('Amplitude (m)');
grid on;

subplot(3,1,2);
plot(t, y_out, 'LineWidth', 1.5);
title('Sprung Mass Vertical Acceleration');
xlabel('Time (s)');
ylabel('Acceleration (m/s^2)');
grid on;

subplot(3,1,3);
pzmap(sys_G);
title('Pole-Zero Map of G(s)');
grid on;
axis equal;