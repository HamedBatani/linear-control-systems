%  k= 110 
num1 = 1210000;  
den1 = [1 240 120^2 121000];  
sys1 = tf(num1, den1); 

% k = 2000
num2 = 22000000;  
den2 = [1 240 120^2 2200000]; 
sys2 = tf(num2, den2); 

% Approximated k = 110
num1_approx = 100;  
den1_approx = [1 10];  
sys1_approx = tf(num1_approx, den1_approx);

% approximated for k = 2000
num2_approx = 10^5;  
den2_approx = [1 20 10^4];  
sys2_approx = tf(num2_approx, den2_approx);  

% step response k = 110
figure;
subplot(2,1,1);
step(sys1, 'r', sys1_approx, 'b');
title('step response for k = 110 original (Red) vs approximation (Blue)');
legend('original System', 'first-Order Approximation');
grid on;

% step response for k = 2000
subplot(2,1,2);
step(sys2, 'r', sys2_approx, 'b');
title('Step response for k = 2000 original (Red) vs approximation (Blue)');
legend('Original System', 'Second-order approximation');
grid on;


info1 = stepinfo(sys1);  
info2 = stepinfo(sys2);  

% plot
fprintf('case 1 (First-order approximation):\n');
fprintf('Percent Overshoot (PO): %.2f%%\n', info1.Overshoot);
fprintf('peak Time (Tp): %.4f s\n', info1.PeakTime);
fprintf('Rise Time (Tr): %.4f s\n', info1.RiseTime);

fprintf('Case 2 (Second-Order Approximation):\n');
fprintf('percent Overshoot (PO): %.2f%%\n', info2.Overshoot);
fprintf('Peak Time (Tp): %.4f s\n', info2.PeakTime);
fprintf('rise Time (Tr): %.4f s\n', info2.RiseTime);

