%% Part 3(c): Disturbance Scaling Implementation
% This script implements the disturbance rejection strategy using
% a proportional gain Kd in the disturbance injection path.
% Based on the provided text logic.

clear; clc; close all;

%% 1. System Definition (Based on the Report Text)
s = tf('s');

% Characteristic Equation (Denominator)
% Derived from system parameters (M=300, m=50, etc.)
den = (s^4 + 23.33*s^3 + 3367*s^2 + 10000*s + 150000);

% Plant Transfer Function G(s) = y(s)/u(s)
% Note: The text uses -16.67*s^2 in the numerator for acceleration
G = (-16.67*s^2) / den;

% Disturbance Transfer Function H(s) = y(s)/yr(s)
H = (10000*s^2 + 100000*s) / den;

%% 2. Controller Definition (From Part b)
% The text uses an augmented plant approach (-1/s^2) and a Lead compensator.
% K(s) = -1/s^2 * K_lead(s)

K_lead = 1.6332548e6 * (s + 16.8397) / (s + 764.1389);
K = -K_lead / s^2;

%% 3. Disturbance Gain Tuning (Part c)
% Ideally Kd = -H(0)/G(0), but for Type 0 output (acceleration),
% the text suggests tuning for small steady-state offset.
% Selected value from the report:
Kd = 0.10; 

%% 4. Simulation Setup
t = 0 : 0.001 : 2; % Simulate for 2 seconds (as per text plots)

% Reference Signal r(t) - Unit Step (from Part a)
r = ones(size(t));

% Road Disturbance Signal yr(t)
yr = 0.1 + 0.05*sin(10*t) + 0.02*cos(20*t);

%% 5. Closed-Loop Formulation
% Loop Gain
L = G * K;

% Reference Tracking Transfer Function: y(s)/r(s)
% Tr = GK / (1 + GK)
Tr = feedback(L, 1);

% Disturbance Rejection Transfer Function: y(s)/yr(s)
% With injection gain Kd: Tyr = (Kd * H) / (1 + GK)
% Note: feedback(SYS1, SYS2) calculates SYS1/(1+SYS1*SYS2).
% Here we manually construct it or use proper feedback syntax.
Tyr = (Kd * H) / (1 + L);

%% 6. Calculate Response
% Superposition principle: y_total = y_ref + y_dist
y_ref_response = lsim(Tr, r, t);
y_dist_response = lsim(Tyr, yr, t);

y_total = y_ref_response + y_dist_response;

%% 7. Visualization (Matching Report Style)

% Figure 1: Combined Response
figure('Name', 'Part 3(c) Response', 'Color', 'w');
plot(t, r, 'k--', 'LineWidth', 1.5); hold on;
plot(t, y_total, 'b', 'LineWidth', 1.5);
grid on;
title(['Part (c): Closed-Loop Response with K_d = ', num2str(Kd)], 'FontSize', 12);
xlabel('Time (s)', 'FontSize', 11);
ylabel('Output (Acceleration)', 'FontSize', 11);
legend('Reference r(t)', 'Output y(t)', 'Location', 'best');
xlim([0, 2]);

% Figure 2: Disturbance Contribution Only
figure('Name', 'Disturbance Effect', 'Color', 'w');
plot(t, yr, 'r', 'LineWidth', 1); hold on;
plot(t, y_dist_response, 'b', 'LineWidth', 1.5);
grid on;
title('Disturbance Signal vs. Its Effect on Output', 'FontSize', 12);
xlabel('Time (s)'); 
legend('Road Profile y_r(t)', 'Effect on Output (Scaled)', 'Location', 'best');

% Figure 3: Pole-Zero Map
figure('Name', 'Pole-Zero Map', 'Color', 'w');
pzmap(Tr);
title('Closed-Loop Pole-Zero Map', 'FontSize', 12);
grid on;
% Validate that poles are stable
disp('Closed-Loop Poles:');
disp(pole(Tr));