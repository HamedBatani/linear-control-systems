
clear; clc; close all;

S = load('Data.mat');   
disp('Variables found in MAT file:');
disp(fieldnames(S));

candU = {'u','U','input','Input','uin','Uin'};
candY = {'y','Y','output','Output','yout','Yout'};
candT = {'t','T','time','Time'};
candTs = {'Ts','ts','DT','dt'};

u = [];
y = [];
t = [];
Ts = [];

% pick u
for k = 1:numel(candU)
    if isfield(S, candU{k})
        u = S.(candU{k});
        break;
    end
end

% pick y
for k = 1:numel(candY)
    if isfield(S, candY{k})
        y = S.(candY{k});
        break;
    end
end

for k = 1:numel(candT)
    if isfield(S, candT{k})
        t = S.(candT{k});
        break;
    end
end

for k = 1:numel(candTs)
    if isfield(S, candTs{k})
        Ts = S.(candTs{k});
        break;
    end
end

if isempty(u) || isempty(y)
    fn = fieldnames(S);
    vecs = {};
    for i = 1:numel(fn)
        v = S.(fn{i});
        if isnumeric(v) && isvector(v) && numel(v) > 10
            vecs{end+1} = fn{i}; %#ok<AGROW>
        end
    end
    disp('Numeric vector candidates (could be u/y):');
    disp(vecs);

    if isempty(u) && numel(vecs) >= 1, u = S.(vecs{1}); end
    if isempty(y) && numel(vecs) >= 2, y = S.(vecs{2}); end
end

if isempty(u) || isempty(y)
    error('Could not identify input/output variables. Check the printed variable list.');
end

u = u(:);
y = y(:);

if ~isempty(Ts)
    Ts_use = Ts;
elseif ~isempty(t) && numel(t) > 1
    t = t(:);
    Ts_use = mean(diff(t));
else
    Ts_use = 0.01;  
    warning('Ts not found. Using Ts = %g s (edit this if wrong).', Ts_use);
end


N = length(y);
t = (0:N-1)'*Ts_use;

A  = 1;        
f0 = 0.5;      

u = A*sin(2*pi*f0*t);     


data2 = iddata(y, u, Ts_use);
data2.Name = "Data2 (sine excitation)";

figure;
plot(y);
grid on;
title('Data2: Output response to sine input');
