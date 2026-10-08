clear; clc; close all;

s = tf('s');

% system parameters
Tdelay = 0.2;     
P      = 1;      

% frequency grid 
w_min = 1e-2;     
w_max = 1e2;     
Nw    = 3000;     
w = logspace(log10(w_min), log10(w_max), Nw);

% Time vector for ( we will use it in step responses ) 
t_start = 0;      
t_end   = 4.5;         
Nt      = 3000;  
t = linspace(t_start, t_end, Nt);

plot_every = 1;   

build_L = @(K) tf(K, [1 P], 'InputDelay', Tdelay);   
build_Tcl = @(L) feedback(L, 1);                    

% part b 
K = 5; 
L = build_L(K);

figure;
nyquist(L, w); grid on;
title(sprintf('part (b): nyquist of L(s) for K = %.2f (with delay)', K));


% part c 

K_list = 0:0.1:20;

figure; hold on; grid on;
title('part (c): Nyquist diagrams (manual) for K = 0:0.1:20');
xlabel('Re'); ylabel('Im');

w_plot = w;

for idx = 1:length(K_list)
    if mod(idx-1, plot_every) ~= 0
        continue;
    end

    K = K_list(idx);
    L = build_L(K);

    % frequency response:
    Ljw = squeeze(freqresp(L, w_plot));

    % Plot +jw branch
    plot(real(Ljw), imag(Ljw));

    % Plot -jw branch (mirror)
    plot(real(Ljw), -imag(Ljw));
end

% this mark the critical point -1 + j0
plot(-1, 0, 'kx', 'LineWidth', 2, 'MarkerSize', 10);

axis equal;
hold off;

% part e

phase_eq = @(w) (w*Tdelay + atan(w/P) - pi);

w_guess = pi/Tdelay;

w_star = fzero(phase_eq, w_guess);
Kcrit  = sqrt(P^2 + w_star^2);

fprintf('\nPart (e): Critical (touching) values\n');
fprintf('  w*   = %.6f rad/s\n', w_star);
fprintf('  Kcrit= %.6f\n', Kcrit);
Lcrit = build_L(Kcrit);
Ljw = squeeze(freqresp(Lcrit, w_star));
fprintf('  L(jw*) = %.6f %+.6fj\n', real(Ljw), imag(Ljw));

% Part (d)
figure;
nyquist(Lcrit, w); grid on;
title(sprintf('Part (d): Nyquist at Kcrit = %.4f (touches -1)', Kcrit));
hold on;
plot(-1,0,'kx','LineWidth',2,'MarkerSize',10);
hold off;
% part f
figure;
margin(Lcrit); grid on;
title(sprintf('part (f): bode/margin of L(s) at Kcrit = %.4f', Kcrit));

[GM, PM, Wcg, Wcp] = margin(Lcrit);
fprintf('\nPart (f): margins at Kcrit\n');
fprintf('  Phase margin PM = %.4f deg\n', PM);
fprintf('  Gain crossover Wcp (|L|=1) = %.6f rad/s\n', Wcp);
fprintf('  phase crossover Wcg (phase=-180) = %.6f rad/s\n', Wcg);

% part g
Tcl_crit = build_Tcl(Lcrit);

figure;
step(Tcl_crit, t); grid on;  
xlabel('time (s)'); ylabel('Output');
title(sprintf('Part (g): step response at Kcrit = %.4f (near instability)', Kcrit));

SI = stepinfo(Tcl_crit);
fprintf('\nPart (g): stepinfo at Kcrit (interpret cautiously near marginal stability)\n');
fprintf('  overshoot = %.2f %%\n', SI.Overshoot);
fprintf('  SettlingTime = %.4f s\n', SI.SettlingTime);
fprintf('  peakTime = %.4f s\n', SI.PeakTime);
