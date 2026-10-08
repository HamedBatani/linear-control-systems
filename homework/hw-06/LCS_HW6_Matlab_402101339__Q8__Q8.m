clear; clc; close all;

s = tf('s');

Tdelay = 0.2;     % T
P      = 1;       % P

% here we define Gain sweep (root-locus parameter)
K_list = 0:0.1:20;

% this is how many branches to include 
Nbranch = 25;    

% plot 
use_manual_axes = true;          % could be set false for auto 
x_lim = [-6,  2];                
y_lim = [-25, 25];               

% frequenc grid for Nyquist 
w_min = 1e-2;                    
w_max = 1e2;                     
Nw    = 4000;
w = logspace(log10(w_min), log10(w_max), Nw);

% time axis for step response (part g) 
t_start = 0;
t_end   = 5;                    
Nt      = 4000;
t = linspace(t_start, t_end, Nt);

k_branches = -Nbranch:Nbranch;

poles_for_K = @(K) arrayfun(@(k) ...
    double( -P + (1/Tdelay)*lambertw(k, -K*Tdelay*exp(P*Tdelay)) ), ...
    k_branches);

% part (b): For a known K, compute closed-loop pole
K_example = 5;  
p_ex = poles_for_K(K_example);

fprintf('Part (b): Example K = %.2f, showing a few poles (truncated branches):\n', K_example);
disp(p_ex(1:min(10,numel(p_ex))).');

% part (c)+(d): Sweep K and plot 
figure; hold on; grid on;
title(sprintf('Part (c,d): Approx. root-locus (|k|<=%d) for K = %.1f:%.1f:%.1f', ...
    Nbranch, K_list(1), K_list(2)-K_list(1), K_list(end)));
xlabel('Re(s)'); ylabel('Im(s)');

% Plot all poles for all K 
for Ki = 1:numel(K_list)
    K = K_list(Ki);
    p = poles_for_K(K);
    plot(real(p), imag(p), '.', 'MarkerSize', 6);
end

% Imag axis and real axis reference lines
xline(0, '--');
yline(0, '--');

if use_manual_axes
    xlim(x_lim);   
    ylim(y_lim);   
end
hold off;

% Part (e)
phase_eq = @(w) (w*Tdelay + atan(w/P) - pi);
w_guess  = pi/Tdelay;                 
w_star   = fzero(phase_eq, w_guess);
Kcrit    = sqrt(P^2 + w_star^2);

fprintf('\nPart (e): Critical gain (first onset of instability)\n');
fprintf('  w*    = %.6f rad/s\n', w_star);
fprintf('  Kcrit = %.6f\n', Kcrit);

% Cross-check 
p_crit = poles_for_K(Kcrit);
fprintf('  max(Re(poles)) at Kcrit (truncated) = %.6e\n', max(real(p_crit)));

% part (f): 
Lcrit = tf(Kcrit, [1 P], 'InputDelay', Tdelay);  
figure;
nyquist(Lcrit, w); grid on;
title(sprintf('Part (f): Nyquist of K*L(s) at Kcrit = %.4f', Kcrit));
hold on;
plot(-1, 0, 'kx', 'LineWidth', 2, 'MarkerSize', 10);
hold off;

% part (g): step response 
Tcl_crit = feedback(Lcrit, 1);

figure;
step(Tcl_crit, t); grid on;   
xlabel('Time (s)'); ylabel('Output');
title(sprintf('Part (g): step response at Kcrit = %.4f (near instability)', Kcrit));

SI = stepinfo(Tcl_crit);
fprintf('\nPart (g): stepinfo at Kcrit (interpret cautiously)\n');
fprintf('  Overshoot = %.2f %%\n', SI.Overshoot);
fprintf('  SettlingTime = %.4f s\n', SI.SettlingTime);
fprintf('  peakTime = %.4f s\n', SI.PeakTime);
