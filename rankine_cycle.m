% Simple Rankine Cycle
% The pressure in the condenser.
P1 = 0.1;
P4 = P1;

% The maximal temperature in the cycle.
T3 = 400;

%The pressure in the boiler.
P3 = 20;
P2 = P3;

% Computation of the work of the pump.
% Converting Pressure to KPa.
v1 = XSteam('vL_p', P1);
wp = -100 * v1 * (P2 - P1);

% Computation of Qin
h1 = XSteam('hL_p', P1);
h2 = h1 - wp;
h3 = XSteam('h_pT', P3, T3);
qin = h3 - h2;

% Computation of the work of the turbine
s3 = XSteam('s_pT', P3, T3);
s4 = s3;
h4 = XSteam('h_pS', P4, s4);
wt = h3 - h4;

% Computation of the thermal efficiency
Eff = (wt - abs(wp)) / qin;

% Computation of the quality at the exit of the turbine
x4 = XSteam('x_ps', P4, s4);

% Calculate specific volume values
v2 = XSteam('v_pT', P2, T3); % Specific volume at state 2
v3 = XSteam('v_pT', P3, T3); % Specific volume at state 3
v4 = XSteam('vL_p', P4);

% Plot p-v (Pressure vs. Specific Volume)
figure;
v_values = [v1, v2, v3, v4, v1];
P_values = [P1, P2, P3, P4, P1];
plot(v_values, P_values, 'o-', 'LineWidth', 2);
title('Rankine Cycle - p-v Diagram');
xlabel('Specific Volume (v)');
ylabel('Pressure (P)');
grid on;
