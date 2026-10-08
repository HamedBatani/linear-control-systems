% G(s)
s = tf('s');
G = (1 - s) / ((s + 1) * (2*s + 1));

% 1.
t = 0:0.01:10;
u = zeros(size(t));
u(1) = 1;  
[y_lsim, t_lsim] = lsim(G, u, t);

figure;
plot(t_lsim, y_lsim, 'LineWidth', 2);
title('impulse Response using lsim');
xlabel('Time (s)');
ylabel('response');
grid on;

% 2
syms s t_sym;
G_s = (1 - s) / ((s + 1)*(2*s + 1));
impulse_response = ilaplace(G_s, s, t_sym);

fplot(impulse_response, [0, 10], 'LineWidth', 2);
title('Impulse Response using ilaplace');
xlabel('Time (s)');
ylabel('Response');
grid on;

% 3.
[Ac, Bc, Cc, Dc] = ssdata(G);
eAt = zeros(length(t), length(Ac));  

for i = 1:length(t)
    eAt(i,:) = expm(Ac * t(i)) * Bc;  
end

impulse_state_space = Cc * eAt';

figure;
plot(t, impulse_state_space, 'LineWidth', 2);
title('Impulse response from state-Space representation');
xlabel('Time (s)');
ylabel('Response');
grid on;

% 4. 
figure;
impulse(G);
title('Impulse Response using Impulse Function');
xlabel('Time (s)');
ylabel('Response');
grid on;

% 5.
figure;
subplot(3, 2, 1);
plot(t_lsim, y_lsim, 'LineWidth', 2);
title('Impulse Response using lsim');
xlabel('Time (s)');
ylabel('Response');
grid on;

subplot(3, 2, 2);
fplot(impulse_response, [0, 10], 'LineWidth', 2);
title('Impulse Response using ilaplace');
xlabel('Time (s)');
ylabel('Response');
grid on;

subplot(3, 2, 3);
plot(t, impulse_state_space, 'LineWidth', 2);
title('Impulse response from state-Space');
xlabel('Time (s)');
ylabel('Response');
grid on;

subplot(3, 2, 4);
impulse(G);
title('Impulse Response using impulse Function');
xlabel('Time (s)');
ylabel('Response');
grid on;

% 6. 
disp('Impulse response from ilaplace:');
disp(impulse_response);
disp('Impulse response from e^{At}:');
disp(impulse_state_space);

