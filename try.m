clear all
close all
clc

% taking inputs
P1 = input('Enter the Pressure at the Turbine Inlet (in bar): ');
T1 = input('Enter the Temperature at the Turbine Inlet (in Degree Celsius): ');
P2 = input('Enter the Pressure at the Condenser (in bar): ');

% conditions at the turbine inlet
T1_sat = XSteam('Tsat_p', P1);
if T1 > T1_sat
    h1 = XSteam('h_pt', P1, T1);
    s1 = XSteam('s_pt', P1, T1);
elseif T1 == T1_sat
    h1 = XSteam('hV_p', P1);
    s1 = XSteam('sV_p', P1);
else
    disp('Enter a higher value of temperature');
    return;  % Stop execution if temperature is too low
end

% conditions at turbine outlet
s2 = s1;
s2_sat = XSteam('sV_p', P2);
if s2 < s2_sat
    s2_f = XSteam('sL_p', P2);
    s2_g = XSteam('sV_p', P2);

    % s2 = s_f + x(s_g - s_f)
    % x = vapour fraction
    x2 = (s2 - s2_f) / (s2_g - s2_f);
    h2_f = XSteam('hL_p', P2);
    h2_g = XSteam('hV_p', P2);
    h2 = h2_f + x2 * (h2_g - h2_f);
    T2 = XSteam('Tsat_p', P2);
else
    x2 = 1;
    h2 = XSteam('hV_p', P2);
    T2 = XSteam('Tsat_p', P2);
end

% conditions at condenser outlet/ pump inlet
P3 = P2;
T3 = XSteam('Tsat_p', P3);
h3 = XSteam('hL_p', P3);
s3 = XSteam('sL_p', P3);
v3 = XSteam('vL_p', P3);

% conditions at pump outlet
s4 = s3;
P4 = P1;
v4 = XSteam('v_ps', P4, s4);
Cp = XSteam('Cp_ps', P4, s4);
Cv = XSteam('Cv_ps', P4, s4);
g = Cp / Cv;  % gamma
T4 = T3 * ((P3 / P4) ^ ((1 - g) / g));
W_p = v3 * (P4 - P3) * 100;  % work done by pump
h4 = h3 + W_p;

% considering points 5 and 6 to complete the curve
T5 = XSteam('Tsat_p', P4);
s5 = XSteam('sL_p', P4);
T6 = T5;
s6 = XSteam('sV_T', T6);

% Work done, heat, and efficiency
% assuming mass flow rate = 1
W_t = h1 - h2;  % work done by turbine
W_net = W_t - W_p;  % net work done
Q_in = h1 - h4;  % heat added
Q_out = h2 - h3;  % heat rejected
eta = W_net / Q_in;  % efficiency
SSC = 3600 / W_net;  % specific steam consumption (SSC)
BWR = W_p / W_t;

% plotting
t = linspace(0, 600, 1000);

% for plotting saturation curves
s_l = zeros(1, length(t));
s_v = zeros(1, length(t));
h_l = zeros(1, length(t));
h_v = zeros(1, length(t));

for i = 1:length(t)
    s_l(i) = XSteam('sL_T', t(i));
    s_v(i) = XSteam('sV_T', t(i));
    h_l(i) = XSteam('hL_T', t(i));
    h_v(i) = XSteam('hV_T', t(i));
end

% plotting T-S curve
figure(1)
hold on
plot(s_l, t, '-', 'color', 'b')
plot(s_v, t, '-', 'color', 'r')
plot([s1, s2], [T1, T2], 'linewidth', 2, 'color', 'b')
plot([s2, s3], [T2, T3], 'linewidth', 2, 'color', 'r')
plot([s3, s4], [T3, T4], 'linewidth', 2, 'color', 'y')
plot([s4, s5], [T4, T5], 'linewidth', 2, 'color', 'k')
plot([s5, s6], [T5, T6], 'linewidth', 2, 'color', 'k')
plot([s6, s1], [T6, T1], 'linewidth', 2, 'color', 'k')
text(s1, T1, '1')
text(s2, T2, '2')
text(s3, T3, '3')
text(s4, T4, '4')
text(s5, T5, '5')
text(s6, T6, '6')
xlabel('Entropy [kJ/kg-K]')
ylabel('Temperature [\circC]')
title('Entropy vs Temperature curve')
grid on
hold off

% plotting h-s curve
figure(2)
hold on
plot([s1, s2], [h1, h2], 'linewidth', 2, 'color', 'b')
plot([s2, s3], [h2, h3], 'linewidth', 2, 'color', 'r')
plot([s3, s4], [h3, h4], 'linewidth', 2, 'color', 'y')
plot([s4, s1], [h4, h1], 'linewidth', 2, 'color', 'k')
plot(s_l, h_l, '--', 'color', 'b')
plot(s_v, h_v, '--', 'color', 'r')
text(s1, h1, '1')
text(s2, h2, '2')
text(s3, h3, '3')
text(s4, h4, '4')
xlabel('Entropy [kJ/kg-K]')
ylabel('Enthalpy [kJ/kg]')
title('Entropy vs Enthalpy curve')
grid on
hold off

% getting the output screen
disp('RESULTS: ')
disp('At state point 1: ')
fprintf('P1 = %.2f bar \n', P1)
fprintf(['T1 = %.2f' char(176) 'C \n'], T1)
fprintf('h1 = %.2f kJ/kg \n', h1)
fprintf('s1 = %.2f kJ/kg-K \n', s1)
disp(' ')
disp('At state point 2: ')
fprintf('P2 = %.2f bar \n', P2)
fprintf(['T2 = %.2f' char(176) 'C \n'], T2)
fprintf('h2 = %.2f kJ/kg \n', h2)
fprintf('s2 = %.2f kJ/kg-K \n', s2)
disp(' ')
disp('At state point 3: ')
fprintf('P3 = %.2f bar \n', P3)
fprintf(['T3 = %.2f' char(176) 'C \n'], T3)
fprintf('h3 = %.2f kJ/kg \n', h3)
fprintf('s3 = %.2f kJ/kg-K \n', s3)
disp(' ')
disp('At state point 4: ')
fprintf('P4 = %.2f bar \n', P4)
fprintf(['T4 = %.2f' char(176) 'C \n'], T4)
fprintf('h4 = %.2f kJ/kg \n', h4)
fprintf('s4 = %.2f kJ/kg-K \n', s4)
disp(' ')

fprintf('Work done by turbine = %.2f kJ/kg \n', W_t)
fprintf('Work done by pump = %.2f kJ/kg \n', W_p)
fprintf('Net work output = %.2f kJ/kg \n', W_net)
fprintf('Thermal efficiency = %.2f \n', eta)
fprintf('Back-work ratio = %f \n', BWR)
fprintf('Specific Steam Conductivity = %.2f kg/kWh \n', SSC)
