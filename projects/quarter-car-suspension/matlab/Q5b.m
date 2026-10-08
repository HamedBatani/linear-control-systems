%% Part 5(b): Parametric Uncertainty in Suspension Stiffness
clc; clear; close all;

%% 1. Nominal Parameters
M = 300; m = 50; D = 1000;
k1_nom = 15000;
k2_nom = 150000;

% Controller from previous section (Robust PID)
Kp = -2000; Ki = -5000; Kd = -800; Tf = 0.01;
s = tf('s');
K_pid = pid(Kp, Ki, Kd, Tf);

%% 2. Simulation Setup
t = 0:0.005:4;
r = ones(size(t)); % Step Reference
yr = 0.1 + 0.05*sin(10*t) + 0.02*cos(20*t); % Road Disturbance

% Define combinations for +/- 5% uncertainty (Corners)
uncertain_factors = [0.95, 1.0, 1.05];

%% 3. Pre-allocate arrays for plotting
y_all_k1 = []; % Store responses when ONLY k1 varies
y_all_k2 = []; % Store responses when ONLY k2 varies

%% 4. Simulate Uncertainty in k1 (k2 fixed at nominal)
for i = 1:length(uncertain_factors)
    k1_unc = k1_nom * uncertain_factors(i);
    k2_unc = k2_nom; % Fixed
    
    % Rebuild State Space
    A = [0 0 1 0; 0 0 0 1; -k1_unc/M k1_unc/M -D/M D/M; k1_unc/m -(k1_unc+k2_unc)/m D/m -D/m];
    B = [0; 0; 1/M; -1/m];
    W = [0; 0; 0; k2_unc/m];
    C = [-k1_unc/M k1_unc/M -D/M D/M];
    
    % Rebuild TFs
    [numG, denG] = ss2tf(A, B, C, 0); G_unc = tf(numG, denG);
    [numH, denH] = ss2tf(A, W, C, 0); H_unc = tf(numH, denH);
    
    % Closed Loop
    T_ref = feedback(K_pid*G_unc, 1);
    T_dist = feedback(H_unc, K_pid*G_unc);
    
    % Simulate
    y_total = lsim(T_ref, r, t) + lsim(T_dist, yr, t);
    y_all_k1 = [y_all_k1; y_total'];
end

%% 5. Simulate Uncertainty in k2 (k1 fixed at nominal)
for i = 1:length(uncertain_factors)
    k1_unc = k1_nom; % Fixed
    k2_unc = k2_nom * uncertain_factors(i);
    
    % Rebuild State Space
    A = [0 0 1 0; 0 0 0 1; -k1_unc/M k1_unc/M -D/M D/M; k1_unc/m -(k1_unc+k2_unc)/m D/m -D/m];
    B = [0; 0; 1/M; -1/m];
    W = [0; 0; 0; k2_unc/m];
    C = [-k1_unc/M k1_unc/M -D/M D/M];
    
    % Rebuild TFs
    [numG, denG] = ss2tf(A, B, C, 0); G_unc = tf(numG, denG);
    [numH, denH] = ss2tf(A, W, C, 0); H_unc = tf(numH, denH);
    
    % Closed Loop
    T_ref = feedback(K_pid*G_unc, 1);
    T_dist = feedback(H_unc, K_pid*G_unc);
    
    % Simulate
    y_total = lsim(T_ref, r, t) + lsim(T_dist, yr, t);
    y_all_k2 = [y_all_k2; y_total'];
end

%% 6. Plotting Results Side-by-Side
figure('Name', 'Uncertainty Impact Comparison', 'Position', [100, 100, 900, 450], 'Color', 'w');

% Subplot 1: Impact of k1
subplot(1, 2, 1);
plot(t, y_all_k1(1,:), 'r--', 'LineWidth', 1); hold on; % 0.95
plot(t, y_all_k1(3,:), 'b--', 'LineWidth', 1);          % 1.05
plot(t, y_all_k1(2,:), 'k', 'LineWidth', 2);            % Nominal
title('Impact of \pm5% Uncertainty in k_1 (Suspension)', 'FontSize', 11);
xlabel('Time (s)'); ylabel('Vertical Acceleration (m/s^2)');
legend('-5% k_1', '+5% k_1', 'Nominal', 'Location', 'best');
grid on; xlim([0, 3]);

% Subplot 2: Impact of k2
subplot(1, 2, 2);
plot(t, y_all_k2(1,:), 'r--', 'LineWidth', 1); hold on; % 0.95
plot(t, y_all_k2(3,:), 'b--', 'LineWidth', 1);          % 1.05
plot(t, y_all_k2(2,:), 'k', 'LineWidth', 2);            % Nominal
title('Impact of \pm5% Uncertainty in k_2 (Tire)', 'FontSize', 11);
xlabel('Time (s)'); 
legend('-5% k_2', '+5% k_2', 'Nominal', 'Location', 'best');
grid on; xlim([0, 3]);

% Main Title
sgtitle('Closed-Loop Robustness: k_1 vs k_2 Uncertainty Impact', 'FontSize', 14, 'FontWeight', 'bold');

% Save Figure
saveas(gcf, 'uncertainty_comparison.png');
disp('Simulation complete. Graph saved as uncertainty_comparison.png');