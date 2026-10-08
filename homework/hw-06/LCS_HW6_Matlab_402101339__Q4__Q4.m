clear; clc; close all;

% first we define plant Gp(s) = G1(s)G2(s)
s = tf('s');
G1 = (3.373/(s+8)) * (1/(s^2 - 18.9));

wn = 33.9;
G2_noDelay = (wn^2) / (s^2 + 40.68*s + wn^2);

% Time delay
Tdelay = 0.015;                 % seconds
N_pade = 4;                      % Pade order
[numD, denD] = pade(Tdelay, N_pade);
DelayApprox = tf(numD, denD);

G2 = series(DelayApprox, G2_noDelay);
Gp = series(G1, G2);

% now we define PID controller Gc(s)
Gc = 2.5177 * (1 + 1.5431/s + 0.075*s);

% Open-loop transfer L(s) = Gc(s)Gp(s)
L = series(Gc, Gp);

% Part (a) of Q4 

figure('Name','nyquist of L(s)');
nyquist(L); grid on;
title('nyquist diagram of Open-Loop L(s) = G_c(s) G_p(s)');
hold on;
plot(-1,0,'rx','MarkerSize',10,'LineWidth',2); 
legend('nyquist(L)','-1 point','Location','Best');

%  COUNTING RHP poles
pL = pole(L);
numRHP = sum(real(pL) > 0);
numOnImag = sum(abs(real(pL)) < 1e-9 & abs(imag(pL)) > 0); 
numAtOrigin = sum(abs(pL) < 1e-9); 

fprintf('Open-loop poles of L(s):\n');
disp(pL);
fprintf('Count: RHP poles = %d\n', numRHP);
fprintf('Count: poles at origin (jw-axis) = %d\n', numAtOrigin);


w = logspace(-4, 4, 6000);          % frequency grid ( excludes 0)
resp_pos = squeeze(freqresp(L, w)); 
% here we build a full nyquist curve (positive + mirrored negative )
resp_full = [resp_pos; conj(flipud(resp_pos(2:end-1)))];

z = resp_full + 1;                  % shift: encirclement of -1 becomes encirclement of 0
theta = unwrap(angle(z));
N_encirc = round((theta(end) - theta(1)) / (2*pi)); % winding

fprintf('Estimated Nyquist encirclements of -1 (N) = %d\n', N_encirc);

% Partb of Q4 

figure('Name','Bode Magnitude of L(s)');
bodemag(L); grid on;
title('bode mgnitude of Loop Gain |L(j\omega)|');

[GM, PM, Wcg, Wcp] = margin(L);

fprintf('\nmargin(L) results:\n');
fprintf('gain margin (GM) = %.4g (absolute), Phse margin (PM) = %.4g deg\n', GM, PM);
fprintf(['Wcg (phase crossover freq.4' ...
    '' ...
    '' ...
    '' ...
    '' ...
    '' ...
    '' ...
    '' ...
    '' ...
    '' ...
    '' ...
    ' for GM) = %.6g rad/s\n'], Wcg);
fprintf('Wcp (gain crossover freq. wc where |L|=1) = %.6g rad/s\n', Wcp);

if ~isnan(Wcp) && isfinite(Wcp) && Wcp > 0
    hold on;
    
    Ljwcp = squeeze(freqresp(L, Wcp));
    magAtWcp = abs(Ljwcp);
    fprintf('Check: |L(j*wc)| = %.6g (should be ~ 1)\n', magAtWcp);

    xline(Wcp, '--');
    text(Wcp, 1, sprintf('  wc = %.3g rad/s', Wcp), 'Rotation', 90);
end


% part c of Q4
wc = Wcp;

if isnan(wc) || ~isfinite(wc) || wc <= 0
    warning('Gain crossover frequency wc (Wcp) is not finite/valid. Part (c) cannot be computed as stated.');
else
    % region 1:
    w1_min = 1e-6;              
    w1_max = 0.1 * wc;

   
    if w1_max > w1_min
        w1 = logspace(log10(w1_min), log10(w1_max), 4000);
        L1 = squeeze(freqresp(L, w1));
        mag1 = abs(L1);

        [minMag_low, idxMin] = min(mag1);
        w_at_minMag_low = w1(idxMin);

        fprintf('\nPart (c) - low-frequency region (w <= 0.1 wc):\n');
        fprintf('wc = %.6g rad/s, 0.1 wc = %.6g rad/s\n', wc, w1_max);
        fprintf('min |L(jw)| over [%.2e, %.6g] = %.6g at w = %.6g rad/s\n', ...
                w1_min, w1_max, minMag_low, w_at_minMag_low);
    else
        warning('0.1*wc is too small or invalid; cannot build frequency grid for low-frequency region.');
    end

    % region 2: 
    w2_min = 10 * wc;
    w2_max = 1e4 * wc;          

    
    w2_max_cap = 1e6;           
    w2_max = min(w2_max, w2_max_cap);

    if w2_max > w2_min
        w2 = logspace(log10(w2_min), log10(w2_max), 4000);
        L2 = squeeze(freqresp(L, w2));
        mag2 = abs(L2);

        [maxMag_high, idxMax] = max(mag2);
        w_at_maxMag_high = w2(idxMax);

        fprintf('\nPart (c) - high-frequency region (w >= 10 wc):\n');
        fprintf('10 wc = %.6g rad/s, search upper bound = %.6g rad/s\n', w2_min, w2_max);
        fprintf('max |L(jw)| over [%.6g, %.6g] = %.6g at w = %.6g rad/s\n', ...
                w2_min, w2_max, maxMag_high, w_at_maxMag_high);
    else
        warning('search upper bound for high-frequency region is not greater than 10*wc; cannot compute max.');
    end

end
