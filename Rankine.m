
function [s, T, v, P, N, w] = Rankine(T1, T3, P2)

step = 100;

%% Process Calculations

% 1-2 Isentropic Pump
P1 = XSteam('psat_T', T1); 
s1 = XSteam('sL_T', T1); 
v1 = XSteam('vL_T', T1); 

s2 = s1;
T2 = XSteam('T_ps',P2, s2); 
v2 = XSteam('v_pT', P2, T2); 

s12 = linspace(s1,s2,step);
T12 = linspace(T1,T2,step);
v12 = linspace(v1,v2,step);
P12 = linspace(P1,P2,step);

% 2-3 Isobaric Boiler
P3 = P2;

s2s = XSteam('sL_p',P3);
s3s = XSteam('sV_p',P3);
T2s = XSteam('T_ps',P3,s2s);
T3s = T2s;

s22s = linspace(s2,s2s,step);
T22s = linspace(T2,T2s,step);

s2s3s = linspace(s2s,s3s,step);
T2s3s = linspace(T2s,T3s,step);

s3 = XSteam('s_pT',P3,T3);
v3 = XSteam('v_pT', P3, T3);
s3s3 = linspace(s3s,s3,step);
T3s3 = linspace(T3s,T3,step);

s23 = [s22s, s2s3s, s3s3];
T23 = [T22s, T2s3s, T3s3];
v23 = linspace(v2,v3,step);
P23 = linspace(P2,P3,step);

% 3-4 Isentropic Turbine
s4 = s3;
P4 = P1;
T4 = T1;

s4g = XSteam('sV_p', P4);
s4f = XSteam('sL_p',P4);
s4fg = s4g - s4f;
 
h4g = XSteam('hV_p',P4);
h4f = XSteam('hL_p',P4);

v4 = XSteam('v_ps',P4,s4); 

if s4 <= s4g % Checks to see if Point 4 is within the vapor dome
    xt = (s4 - s4f) / s4fg; % calculates the new quality at this point
    h4 = (1-xt)*h4f + (xt*h4g); % calculates the new enthalpy 
else
    xt = 1; % Quality is max 1
    h4 = xt*h4g; % calculates the new enthalpy
end

P34 = linspace(P3,P4,step);

v34 = zeros(1,step);
for i = 1:length(P34)
    v34(i) = XSteam('v_ps',P34(i),s3);
end    

s34 = linspace(s3,s4,step);
T34 = linspace(T3,T4,step);

% 4-1 Isobaric Condenser
s41 = linspace(s4,s1,step);
T41 = linspace(T4,T1,step);
v41 = linspace(v4,v1,step);
P41 = linspace(P4,P1,step);

%% Efficiency and Work

h1 = XSteam('hL_T',T1);
h2 = XSteam('h_pt',P2,T2);
h3 = XSteam('h_pt',P3,T3);

wp = h2 - h1; 
wt = h3 - h4;
qin = h3 - h2;

w = wt - wp; % [kJ/kg]
N = w/qin; % []

%% Condensing Curve Vectors

s = [s12, s23, s34, s41]; % [kJ/kgK]
T = [T12, T23, T34, T41]; % [degC]

v = [v12, v23, v34, v41]; % [m^3/kg]
P = [P12, P23, P34, P41]; % [bar]

end


