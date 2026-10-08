clear; clc; close all;

load('Data.mat');   

y = x;             
N = length(y);

Ts = 1;            %sample rate
t  = (0:N-1)' * Ts; %time vector

u = ones(N,1);      

% Plot
figure;

subplot(2,1,1);
plot(t, u, 'LineWidth', 1.5);
grid on;
xlabel('Time');
ylabel('u(t)');
title('Step Input u(t)');

subplot(2,1,2);
plot(t, y, 'LineWidth', 1.5);
grid on;
xlabel('Time');
ylabel('y(t)');
title('Output Response y(t)');

data = iddata(y, u, 1);   
