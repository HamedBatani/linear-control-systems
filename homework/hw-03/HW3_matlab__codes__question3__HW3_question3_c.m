t  = linspace(0,20,5000);  dt = t(2)-t(1);
u  = ones(size(t));

h1 = exp(-t);              
h2 = exp(t);               
h3 = sin(t);              
h4 = t .* exp(-t);        
h5 = 1 ./ (t + 1);         
h6 = 1 ./ (t.^2 + 1);      

Hs = {h1,h2,h3,h4,h5,h6};
titles = { ...
    'Step response S1: 1/(s+1)', ...
    'Step response S2: 1/(s-1)', ...
    'Step response S3: 1/(s^2+1)', ...
    'Step response S4: 1/(s+1)^2', ...
    'Step response S5: h(t)=1/(t+1)', ...
    'Step response S6: h(t)=1/(t^2+1)'};

figure;
for k = 1:6
    y = conv(Hs{k}, u) * dt;
    y = y(1:length(t));
    subplot(3,2,k);
    plot(t, y, 'LineWidth', 1.2);
    grid on;
    title(titles{k});
    xlabel('t'); ylabel('y(t)');
end
