clc;


% Low-pass filter-
af = 0.2;                
F  = tf(1, [af 1]);      


N  = length(data3.y);
Ts = data3.Ts;
t  = (0:N-1)' * Ts;

u3 = data3.u;
y3 = data3.y;


u3_f = lsim(F, u3, t);
y3_f = lsim(F, y3, t);

data3_f = iddata(y3_f, u3_f, Ts);
data3_f.Name = 'Data3 (low-pass filtered)';

-
G3_f = tfest(data3_f, 1, 0);


disp('Identified model from filtered Data3:');
G3_f
