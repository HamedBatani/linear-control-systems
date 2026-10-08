clear; clc; close all;

s = tf('s');

t_start = 0;
t_end   = 18;
n_pts   = 3000;
t = linspace(t_start, t_end, n_pts);

% plant
g = 10 / ((s+1)*(s^2 + 2*s + 4));

% build system
build_system = @(k) deal( ...
    k*(s+2)/(s+1), ...
    (k*(s+2)/(s+1))*g, ...
    feedback((k*(s+2)/(s+1))*g, 1) ...
);

% steady error
compute_ess = @(l) 1/(1 + dcgain(l));

% peak gain
compute_mp_db = @(t) 20*log10(getPeakGain(t));

% zeta estimate
estimate_zeta_from_mp = @(mp) ...
    fzero(@(z) (1./(2*z*sqrt(1-z^2)) - mp), [1e-3, 0.7]);

% part b
k = 20;
[gc, l, tcl] = build_system(k);

figure;
step(tcl, t);
grid on;
xlabel('time (s)');
ylabel('output');
title('step response for k = 20');

ess = compute_ess(l);
si  = stepinfo(tcl);

fprintf('part (b): k = %.2f\n', k);
fprintf('  ess = %.6f (%.2f%%)\n', ess, 100*ess);
fprintf('  overshoot = %.2f%%\n', si.Overshoot);
fprintf('  settling time = %.4f s\n', si.SettlingTime);

% part c
figure;
nichols(l);
grid on;
title('nichols chart for k = 20');

mp_db  = compute_mp_db(tcl);
mp_lin = 10^(mp_db/20);
zeta_est = estimate_zeta_from_mp(mp_lin);

[~, pm] = margin(l);

fprintf('\npart (c): nichols data\n');
fprintf('  mp = %.3f db\n', mp_db);
fprintf('  phase margin = %.2f deg\n', pm);
fprintf('  zeta = %.3f\n', zeta_est);

% part d
mp_target_db = 2.67;

mp_db_of_k = @(ktest) ...
    20*log10(getPeakGain(feedback((ktest*(s+2)/(s+1))*g,1)));

objective = @(ktest) (mp_db_of_k(ktest) - mp_target_db)^2;

k_new = fminsearch(objective, 10);

[gc_new, l_new, t_new] = build_system(k_new);
ess_new = compute_ess(l_new);

fprintf('\npart (d): gain tuning\n');
fprintf('  new k = %.4f\n', k_new);
fprintf('  ess = %.4f (%.2f%%)\n', ess_new, 100*ess_new);

% part e
figure;
step(t_new, t);
grid on;
xlabel('time (s)');
ylabel('output');
title(sprintf('step response for k = %.2f', k_new));

% part f
k_list = [4.44, 10, 20];

overshoot = zeros(size(k_list));
settlingt = zeros(size(k_list));
peakt     = zeros(size(k_list));
ess_list  = zeros(size(k_list));

for i = 1:length(k_list)
    k = k_list(i);
    [~, l, tcl] = build_system(k);

    si = stepinfo(tcl);
    overshoot(i) = si.Overshoot;
    settlingt(i) = si.SettlingTime;
    peakt(i)     = si.PeakTime;
    ess_list(i)  = compute_ess(l);
end

results = table(k_list(:), overshoot(:), settlingt(:), peakt(:), ess_list(:), ...
    'variablenames', {'k','overshoot_pct','settlingtime_s','peaktime_s','ess'});

fprintf('\npart (f): comparison\n');
disp(results);

% part h
figure; hold on; grid on;
for i = 1:length(k_list)
    k = k_list(i);
    [~, ~, tcl] = build_system(k);
    step(tcl, t);
end
xlabel('time (s)');
ylabel('output');
title('step responses');
legend('k = 4.44','k = 10','k = 20','location','best');
hold off;

