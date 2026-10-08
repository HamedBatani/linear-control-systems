clear; clc; close all;

s = tf('s');

% define g
G = 1 / ( s*(s+2)*(s+3) );

% k > 0
figure;
rlocus(G);
grid on;
title('Root Locus (K > 0)');

% use -G so that k > 0 corresponds to K < 0 of original system
figure;
rlocus(-G);
grid on;
title('Complementary Root Locus (K < 0)');
