clear; clc; close all;
T = 1.5;

% freq. grid
w = logspace(-2, 2, 2000);  


% exact delay for comparison
G_exact = tf(1, 1, 'InputDelay', T);

n_list = 1:5;
G_approx = cell(numel(n_list), 1);

for idx = 1:numel(n_list)
    n = n_list(idx);


    coeff_num_asc = zeros(1, n+1); 
    coeff_den_asc = zeros(1, n+1);

    for k = 0:n
        coeff_num_asc(k+1) = ((-T/2)^k) / factorial(k);
        coeff_den_asc(k+1) = ((+T/2)^k) / factorial(k);
    end

    
    num = fliplr(coeff_num_asc);
    den = fliplr(coeff_den_asc);

    % transfer function approximation 
    G_approx{idx} = tf(num, den);
end

%plot
figure('Name', 'bode Comparison: exact Delay vs Split-taylor approximations');


h = bodeplot(G_exact, w);
hold on;


for idx = 1:numel(n_list)
    bodeplot(G_approx{idx}, w);
end
grid on;

labels = cell(1, 1 + numel(n_list));
labels{1} = sprintf('exact: e^{-sT},  T = %.2f', T);
for idx = 1:numel(n_list)
    labels{1+idx} = sprintf('split-Taylor order n = %d', n_list(idx));
end
legend(labels, 'Location', 'southwest');

% here we print the approximations in command window
disp('Split-Taylor Approximations (n = 1..5) ');
for idx = 1:numel(n_list)
    n = n_list(idx);
    fprintf('\nOrder n = %d:\n', n);
    G_approx{idx}
end



% part B
% Time vector for step response
t_end = 10;                 
t = linspace(0, t_end, 4000);

figure('name','step responses: exact delay vs split-Taylor approximations');
hold on; grid on;

% Exact delayed step 
step(G_exact, t);

for idx = 1:numel(n_list)
    step(G_approx{idx}, t);
end

% Legend
labels_step = cell(1, 1 + numel(n_list));
labels_step{1} = sprintf('Exact delay e^{-sT}, T = %.2f', T);
for idx = 1:numel(n_list)
    labels_step{1+idx} = sprintf('Split-Taylor n = %d', n_list(idx));
end
legend(labels_step, 'Location','southeast');
xlabel('time (s)');
ylabel('output');
title('step response comparison');


disp(' ');
disp(' Part (b) Stability / Poles / Initial behavior notes (Split-Taylor) ');

for idx = 1:numel(n_list)
    n = n_list(idx);
    Gi = G_approx{idx};

    % Stability check (continuous-time)
    st = isstable(Gi);
    p = pole(Gi);

    fprintf('\nSplit-Taylor order n = %d:\n', n);
    fprintf('  isstable = %d\n', st);
    fprintf('  Poles:\n');
    disp(p.');

 
    y = step(Gi, t);
    fprintf('  approx y(0+) from simulation = %.6g\n', y(1));
end

disp(' ');
disp('comment (what you should observe on the plot):');
disp(['1) the exact delay has no response before t = T (output ~0 until 1.5 s).']);
disp(['2) rational approximations typically show "pre-response" (non-causal anticipation):']);
disp(['   output may start moving before t=T, which is unphysical but common in approximations.']);
disp(['3) depending on the denominator roots, some orders can introduce unstable poles:']);
disp(['   if isstable=0 for any order, its step response will diverge.']);
disp(['4) even when stable, higher orders may show overshoot/undershoot near t=T due to phase/magnitude mismatch.']);


%part c

m = 2; n = 2;

p = zeros(1, m+1);   
q = zeros(1, n+1);   

for i = 0:m
    p(i+1) = ((-1)^i) * factorial(m+n-i) * factorial(m) / ...
             ( factorial(m+n) * factorial(i) * factorial(m-i) );
end
for i = 0:n
    q(i+1) = ( factorial(m+n-i) * factorial(n) ) / ...
             ( factorial(m+n) * factorial(i) * factorial(n-i) );
end

disp(' ');
disp(' Part (c) Pade R_{2,2}(Ts) coefficients ');
fprintf('p0..p2 = '); disp(p);
fprintf('q0..q2 = '); disp(q);

num_R22 = [p(3)*T^2, p(2)*T, p(1)];   
den_R22 = [q(3)*T^2, q(2)*T, q(1)];   
G_R22 = tf(num_R22, den_R22);

disp('Pade R_{2,2}(Ts) transfer function with T=1.5:');
G_R22

% here we Compare maclaurin series coefficients up to order 4
a_exact = [1, -1, 1/factorial(2), -1/factorial(3), 1/factorial(4)];


c = zeros(1,5);  

c(1) = p(1)/q(1);
c(2) = (p(2) - q(2)*c(1))/q(1);
c(3) = (p(3) - q(2)*c(2) - q(3)*c(1))/q(1);
c(4) = (0 - q(2)*c(3) - q(3)*c(2))/q(1);
c(5) = (0 - q(2)*c(4) - q(3)*c(3))/q(1);

disp(' ');
disp('Part (c) Series coefficients about x=Ts=0 ');
fprintf('exact e^{-x} Taylor up to x^4:  '); disp(a_exact);
fprintf('Pade R_{2,2} series up to x^4: '); disp(c);

tol = 1e-12;
same_up_to_4 = all(abs(c - a_exact) < tol);
fprintf('Are the SERIES coefficients identical up to order 4?  %d  (1=yes, 0=no)\n', same_up_to_4);

disp('note: pade coefficients (p_i, q_i) are not the same as Taylor coefficients of e^{-x};');
disp('      what matches is the maclaurin SERIES of the R_{2,2} rational function up to order x^4 (m+n).');



%part d
orders_pade = 1:4;
G_pade = cell(numel(orders_pade), 1);

for k = 1:numel(orders_pade)
    N = orders_pade(k);

   
    [numP, denP] = pade(T, N);
    G_pade{k} = tf(numP, denP);
end

figure('name','bode Comparison: exact delay vs balanced Pade Approximations');
h2 = bodeplot(G_exact, w);
hold on;

for k = 1:numel(orders_pade)
    bodeplot(G_pade{k}, w);
end
grid on;

labels_pade = cell(1, 1 + numel(orders_pade));
labels_pade{1} = sprintf('Exact: e^{-sT}, T = %.2f', T);
for k = 1:numel(orders_pade)
    labels_pade{1+k} = sprintf('Pad%c R_{%d,%d}', char(233), orders_pade(k), orders_pade(k)); % "Pade"
end
legend(labels_pade, 'Location','southwest');

% here we print stability of Pade approximations too
disp(' ');
disp(' part d Stability check (Pade balanced) ');
for k = 1:numel(orders_pade)
    N = orders_pade(k);
    st = isstable(G_pade{k});
    fprintf('R_{%d,%d}: isstable = %d\n', N, N, st);
end
