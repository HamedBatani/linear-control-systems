clc; clear; close all;

%% =====================================================
% 1. System Parameters (from theoretical report)
%% =====================================================
M = 300; 
m = 50; 
k1 = 15000; 
D = 1000; 
k2 = 150000;

s = tf('s');

%% =====================================================
% 2. Transfer Functions of Quarter-Car Model
%% =====================================================
den = M*m*s^4 + (M+m)*D*s^3 + ...
      (M*k2 + M*k1 + m*k1)*s^2 + D*k1*s + k1*k2;

% Control path: actuator force -> body acceleration
G = (-(m*s^2 + D*s + k1) * M*s^2) / den; 

% Disturbance path: road profile -> body acceleration
H = ((D*s + k1) * k2 * M*s^2) / den;

%% =====================================================
% 3. PID Controller with Derivative Filter
%% =====================================================
Kp = -2000; 
Ki = -5000; 
Kd = -800; 
Tf = 0.01;     % derivative noise filter

K = Kp + Ki/s + (Kd*s)/(Tf*s + 1);

%% =====================================================
% 4. Closed-Loop Transfer Functions
%% =====================================================
L = G*K;

% Effect of road disturbance
T_dist = H/(1 + L);

% Effect of measurement noise
T_noise = -L/(1 + L);

% Control effort transfer functions
U_dist = (-K*H)/(1 + L);
U_noise = -K/(1 + L);

%% =====================================================
% 5. Simulation Inputs
%% =====================================================
t = 0:0.001:5;

% Road disturbance profile
yr = 0.1 + 0.05*sin(10*t) + 0.02*cos(20*t);

% Measurement noise: white noise (-40 dB power)
noise_power = 10^(-40/10);
sigma = sqrt(noise_power);

rng(42); % reproducibility
n = sigma * randn(size(t));

%% =====================================================
% 6. Simulate Two Scenarios
%% =====================================================
% --- Ideal case (no measurement noise)
y_ideal = lsim(T_dist, yr, t);
u_ideal = lsim(U_dist, yr, t);

% --- Real case (with measurement noise)
y_noise = y_ideal + lsim(T_noise, n, t);
u_noise = u_ideal + lsim(U_noise, n, t);

%% =====================================================
% 7. Plot Results
%% =====================================================
figure('Color','w','Position',[100 100 1000 700])

% Body acceleration comparison
subplot(2,1,1)
plot(t, y_ideal,'b','LineWidth',2); hold on
plot(t, y_noise,'r','LineWidth',0.7)
grid on
title('Effect of Measurement Noise on Body Acceleration')
ylabel('Acceleration (m/s^2)')
legend('Ideal','With Noise (-40 dB)')

% Control effort comparison
subplot(2,1,2)
plot(t, u_ideal,'b','LineWidth',2); hold on
plot(t, u_noise,'r','LineWidth',0.7)
grid on
title('Effect of Measurement Noise on Control Effort')
xlabel('Time (s)')
ylabel('Control Force (N)')
legend('Ideal','With Noise')

%% =====================================================
% 8. Performance Metrics
%% =====================================================
fprintf('\n===== Performance Comparison =====\n')

rms_ideal = rms(y_ideal);
rms_noise = rms(y_noise);

fprintf('RMS Output (Ideal): %.6f\n', rms_ideal)
fprintf('RMS Output (Noisy): %.6f\n', rms_noise)

fprintf('Noise Amplification Ratio: %.2f\n', rms_noise/rms_ideal)