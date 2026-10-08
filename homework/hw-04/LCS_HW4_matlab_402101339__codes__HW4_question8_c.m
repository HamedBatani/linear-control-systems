clear; clc; close all;

s = tf('s');

% define G(s)
G = 1 / ( s*(s+2)*(s+3) );
% G = (s^2) / ((s^2 - 1)^2);

[RL_pts, CRL_pts, Other_pts, candidates] = breakaway_classify(G);

disp('All candidate points:'); disp(candidates)
disp('On Root Locus (K>0):'); disp(RL_pts)
disp('On Complementary RL (K<0):'); disp(CRL_pts)
disp('Not on RL or complementary:'); disp(Other_pts)

% root locus verification
figure; rlocus(G); grid on;

function [RL_pts, CRL_pts, Other_pts, candidates] = breakaway_classify(G)
    G = tf(G);
    [num, den] = tfdata(G,'v');

    syms s
    a = poly2sym(num,s);
    b = poly2sym(den,s);

    eq = a*diff(b,s) - b*diff(a,s);
    candidates = roots(sym2poly(eq));

    tol = 1e-7;
    z = zero(G); p = pole(G);
    zR = real(z(abs(imag(z)) < tol));
    pR = real(p(abs(imag(p)) < tol));

    RL_pts = []; CRL_pts = []; Other_pts = [];

    for i = 1:numel(candidates)
        c = candidates(i);

        if abs(imag(c)) > tol
            Other_pts(end+1,1) = c; 
            continue
        end

        x = real(c);
        nRight = sum(zR >= x - tol) + sum(pR >= x - tol);

        if mod(nRight,2) == 1
            RL_pts(end+1,1) = x; 
        else
            CRL_pts(end+1,1) = x; 
        end
    end

    isBad = abs(imag(candidates)) > tol;
    isBadReal = ~isBad & ~ismembertol(real(candidates), [RL_pts; CRL_pts], 1e-6);
    Other_pts = [Other_pts; candidates(isBadReal)];
end
