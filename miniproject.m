% Rankine Cycle Simulator
clear all
close all
clc

% Printing Introduction
fprintf('RANKINE CYCLE SIMULATOR \n')
fprintf('\n1-2 is isentropic expansion in the Turbine \n')
fprintf('2-3 is Constant Pressure Heat Rejection by the Condenser \n')
fprintf('3-4 is isentropic Compression in pump \n')
fprintf('4-1 is Constant Pressure Heat Addition by the Boiler \n')

% User Inputs
P1 = input('Enter the Pressure at the Turbine Inlet (in kPa): ');
T1 = input('Enter the Temperature at the Turbine Inlet (in Degree Celsius): ');
P2 = input('Enter the Pressure at the Turbine Outlet (in kPa): ');

% Check if P1 is less than P2
if P1 < P2
    error('Input values are not consistent with the Rankine cycle. P1 must be greater than or equal to P2.')
end

% Convert pressures to kPa
P1 = P1 * 100; 
P2 = P2 * 100;


% State point 1
H1 = XSteam('h_pt', P1, T1);  % Enthalpy
S1 = XSteam('s_pt', P1, T1);  % Entropy
Hf1 = XSteam('hL_p', P1);      % Enthalpy of saturated liquid
Hg1 = XSteam('hV_p', P1);      % Enthalpy of saturated vapor
Ts1 = XSteam('Tsat_p', P1);    % Saturation Temperature
Sf1 = XSteam('sL_p', P1);      % Entropy of saturated liquid
Sg1 = XSteam('sV_p', P1);      % Entropy of saturated vapor

% State point 2
S2 = S1;
Sf2 = XSteam('sL_p', P2);
Sg2 = XSteam('sV_p', P2);
x = (S2 - Sf2) / (Sg2 - Sf2);     % Dryness fraction
Hf2 = XSteam('hL_p', P2);
Hg2 = XSteam('hV_p', P2);
H2 = Hf2 + x * (Hg2 - Hf2);
T2 = XSteam('T_ph', P2, H2);
Ts2 = XSteam('Tsat_p', P2);   

% State point 3
H3 = Hf2;
S3 = Sf2;
T3 = T2;
P3 = P2;

% State point 4
P4 = P1;
S4 = S3;
H4 = XSteam('h_ps', P4, S4);
T4 = XSteam('T_ps', P4, S4);

t = linspace(0, 374, 500);    % temp space for plotting saturation curves

% Plot T-S Diagram
figure(1)
hold on
% Plot Saturation Curve
for i = 1 : length(t)
   plot(XSteam('sL_T', t(i)), t(i), '.', 'color', 'b')
   plot(XSteam('sV_T', t(i)), t(i), '.', 'color', 'b')
end
% Plot Cycle
plot([S1 S2], [T1 T2], 'linewidth', 2, 'color', 'r')
if x > 1
    T3 = Ts2;
    plot([S2 Sg2 S3 S4], [T2 Ts2 T3 T4], 'linewidth', 2, 'color', 'r')
    T2 = Ts2;
else
    plot([S2 S3 S4], [T2 T3 T4], 'linewidth', 2, 'color', 'r')
end
l = linspace(T1, T2, 1000);
for i = 1 : length(l)
    plot(XSteam('s_pT', P1, l(i)), l(i), '.', 'color', 'r')
end
plot([Sf1 Sg1], [Ts1 Ts1], 'linewidth', 2, 'color', 'r')
xlabel('Entropy [kJ/Kg-K]')
ylabel('Temperature [K]')
title('T-S Diagram')

% Plot H-S Diagram
figure(2)
hold on
% Plot Saturation Curve
for i = 1 : length(t)
    plot(XSteam('sL_T', t(i)), XSteam('hL_T', t(i)), '.', 'color', 'b')
    plot(XSteam('sV_T', t(i)), XSteam('hV_T', t(i)), '.', 'color', 'b')
end
% Plot Cycle
plot([S1 S2 S3 S4 S1], [H1 H2 H3 H4 H1], 'linewidth', 2, 'color', 'r')
xlabel('Entropy [kJ/Kg-K]')
ylabel('Enthalpy [kJ/Kg]')
title('H-S Diagram')

% Calculations

% Turbine Work
Wt = H1 - H2;

% Pump Work
Wp = H4 - H3;

% Heat Addition
Qin = H1 - H4;

% Heat Rejection
Qout = H2 - H3;

% Net Work
Wnet = Wt - Wp;

% Efficiency
Ntherm = (Wnet / Qin) * 100;

% Specific Steam Consumption
SSC = 3600 / Wnet;

% Back Work Ratio
BWR = Wp / Wt;

% Print Results
fprintf('\n\nResults\n')
fprintf('At State Point 1:\n')
fprintf('P1 is : %.2f kPa\n', P1)
fprintf('T1 is : %.2f Deg Celsius\n', T1)
fprintf('H1 is : %.2f kJ/Kg\n', H1)
fprintf('S1 is : %.2f kJ/Kg-K\n', S1)

fprintf('\nAt State Point 2:\n')
fprintf('P2 is : %.2f kPa\n', P2)
fprintf('T2 is : %.2f Deg Celsius\n', T2)
fprintf('H2 is : %.2f kJ/Kg\n', H2)
fprintf('S2 is : %.2f kJ/Kg-K\n', S2)

fprintf('\nAt State Point 3:\n')
fprintf('P3 is : %.2f kPa\n', P3)
fprintf('T3 is : %.2f Deg Celsius\n', T3)
fprintf('H3 is : %.2f kJ/Kg\n', H3)
fprintf('S3 is : %.2f kJ/Kg-K\n', S3)

fprintf('\nAt State Point 4:\n')
fprintf('P4 is : %.2f kPa\n', P4)
fprintf('T4 is : %.2f Deg Celsius\n', T4)
fprintf('H4 is : %.2f kJ/Kg\n', H4)
fprintf('S4 is : %.2f kJ/Kg-K\n', S4)

fprintf('\nWt is : %.2f kJ/Kg\n', Wt)
fprintf('Wp is : %.2f kJ/Kg\n', Wp)
fprintf('Wnet is : %.2f kJ/Kg\n', Wnet)
fprintf('Thermal Efficiency is : %.2f percent\n', Ntherm)
fprintf('S.S.C. is : %.2f Kg/KWh\n', SSC) 
fprintf('Back Work Ratio is : %.3f \n', BWR)

