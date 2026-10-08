clear; clc; close all;

s = tf('s');

% Define G(s) 

G = (s^2 + 2*s + 2) / ( s*(s^2 + 0.25) );

candidates = breakaway_candidates(G);
disp(candidates)

%  root locus for verification 
figure; rlocus(G); grid on;

function candidates = breakaway_candidates(G)
    G = tf(G);
    [num, den] = tfdata(G,'v');

    syms s
    a = poly2sym(num,s);
    b = poly2sym(den,s);

    eq = a*diff(b,s) - b*diff(a,s);

    candidates = roots(sym2poly(eq));
end
