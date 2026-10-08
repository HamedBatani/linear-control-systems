%% Part 5(c): Combined Noise and Uncertainty Analysis
clc; clear; close all;

%% 1. Nominal vs Uncertain Parameters
M = 300; m = 50; D = 1000;
k1_nom = 15000; k2_nom = 150000;

% Worst-case parameters (Based on Part 5b analysis)
k1_unc = 0.95 * k1_nom; % -5% stiffness (makes body bouncier)
k2_unc = 1.05 * k2_nom; % +5% tire stiffness

% PID Controller (From previous parts)
Kp = -2000; Ki = -5000; Kd = -800; Tf = 0.01;
s = tf('s');
K_pid = pid(Kp, Ki, Kd, Tf);

%% 2. State-Space and TFs (Nominal)
A_nom = [0 0 1 0; 0 0 0 1; -k1_nom/M k1_nom/M -D/M D/M; k1_nom/m -(k1_nom+k2_nom)/m D/m -D/m];
B_nom = [0; 0; 1/M; -1/m];
W_nom = [0; 0; 0; k2_nom/m];
C_nom = [-k1_nom/M k1_nom/M -D/M D/M];

[nG_nom, dG_nom] = ss2tf(A_nom, B_nom, C_nom, 0); G_nom = tf(nG_nom, dG_nom);
[nH_nom, dH_nom] = ss2tf(A_nom, W_nom, C_nom, 0); H_nom = tf(nH_nom, dH_nom);

T_ref_nom = feedback(K_pid*G_nom, 1);
T_dist_nom = feedback(H_nom, K_pid*G_nom);

%% 3. State-Space and TFs (Uncertain)
A_unc = [0 0 1 0; 0 0 0 1; -k1_unc/M k1_unc/M -D/M D/M; k1_unc/m -(k1_unc+k2_unc)/m D/m -D/m];
B_unc = [0; 0; 1/M; -1/m];
W_unc = [0; 0; 0; k2_unc/m];
C_unc = [-k1_unc/M k1_unc/M -D/M D/M];

[nG_unc, dG_unc] = ss2tf(A_unc, B_unc, C_unc, 0); G_unc = tf(nG_unc, dG_unc);
[nH_unc, dH_unc] = ss2tf(A_unc, W_unc, C_unc, 0); H_unc = tf(nH_unc, dH_unc);

T_ref_unc = feedback(K_pid*G_unc, 1);
T_dist_unc = feedback(H_unc, K_pid*G_unc);

%% 4. Simulation Setup
t = 0:0.002:5;
r = ones(size(t)); % Reference
yr = 0.1 + 0.05*sin(10*t) + 0.02*cos(20*t); % Road Disturbance

% Noise (-40 dB)
noise_var = 10^(-40/10);
sigma = sqrt(noise_var);
rng(100); % Reproducibility
n = sigma * randn(size(t)); % White noise

%% 5. Simulate Responses
% Nominal Response (No noise, nominal parameters)
y_nom = lsim(T_ref_nom, r, t) + lsim(T_dist_nom, yr, t);

% Worst-Case Response (Noise + Uncertain parameters)
% y = T_ref * r + T_dist * yr - T_ref * n  (because e = r - y_m = r - y - n)
y_worst = lsim(T_ref_unc, r, t) + lsim(T_dist_unc, yr, t) - lsim(T_ref_unc, n, t);

%% 6. Plotting
figure('Name', 'Combined Robustness', 'Position', [100, 100, 850, 450], 'Color', 'w');
plot(t, y_nom, 'b', 'LineWidth', 2); hold on;
plot(t, y_worst, 'r', 'LineWidth', 1);
yline(1, 'k--', 'LineWidth', 1.5); % Target
title('System Robustness: Nominal vs. Combined Uncertainty & Noise', 'FontSize', 12);
xlabel('Time (s)', 'FontSize', 11);
ylabel('Vertical Acceleration (m/s^2)', 'FontSize', 11);
legend('Nominal (Ideal)', 'Worst-Case (k_1, k_2 varied + 40dB Noise)', 'Target Reference', 'Location', 'best');
grid on;

% Save Figure
saveas(gcf, 'combined_robustness.png');
disp('Simulation complete. Graph saved as combined_robustness.png');