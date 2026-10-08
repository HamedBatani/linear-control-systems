

clc; clear; close all;

% parameters
m  = 10;
c  = 1.2;
k1 = 4000;
k3 = 1e5;
F0 = 100;

freqs_Hz = [1, 10, 100];
omegas   = 2*pi*freqs_Hz;

% Time span + initial conditions
tspan = [0, 10];
x0    = [0; 0];


% ODE
results = struct();

for i = 1:length(omegas)
    
    omega = omegas(i);
    freq  = freqs_Hz(i);
    
    odefun = @(t, x) smd_nonlinear(t, x, omega, m, c, k1, k3, F0);
    
    % (V) Call ode45 and store results
    [t, X] = ode45(odefun, tspan, x0);
    
    x1 = X(:, 1);
    
    results(i).t        = t;
    results(i).X        = X;
    results(i).x1       = x1;
    results(i).freq_Hz  = freq;
    results(i).omega    = omega;
    results(i).max_amp  = max(abs(x1));
    
    fprintf('f = %3.0f Hz, omega = %7.2f rad/s: max |x(t)| = %.5f m\n', ...
            freq, omega, results(i).max_amp);
end

% Plot displacement responses
figure;
for i = 1:length(results)
    subplot(length(results), 1, i);
    plot(results(i).t, results(i).x1, 'LineWidth', 1.2);
    grid on;
    title(sprintf('x(t) for f = %g Hz', results(i).freq_Hz));
    xlabel('t (s)');
    ylabel('x(t) (m)');
end
sgtitle('Nonlinear SMD Response for Different Excitation Frequencies');

% Compare maximum amplitudes
figure;
amps = [results.max_amp];
bar(freqs_Hz, amps);
grid on;
xlabel('Excitation frequency (Hz)');
ylabel('Max |x(t)| (m)');
title('Effect of Excitation Frequency on Max Displacement');

% Local ODE 
function dxdt = smd_nonlinear(t, x, omega, m, c, k1, k3, F0)
    x1 = x(1);
    x2 = x(2);

    dx1dt = x2;
    dx2dt = -(c/m)*x2 - (k1/m)*x1 - (k3/m)*x1^3 + (F0/m)*sin(omega * t);

    dxdt = [dx1dt;
            dx2dt];
end
