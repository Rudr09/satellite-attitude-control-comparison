clc;
clear;
close all;

% Simulation parameters
Sim_time = 50;
dt = 0.01;

% Controller parameters
Kp = 20;
Ki = 0.12;
Kd = 39.7;
J = 11.4;

% system frequency response analysis
s = tf('s');
G_ac = 1;%exp(-tau_d*s)/(tau*s+1); 
G_c = Kp + Ki/s + Kd*s/(0.05*s+1); % controller definition
G_p = tf(1,[11.4 0 0]); % plant or system definition
G_ol = G_c*G_ac*G_p; % Open-loop system 
G_cl = feedback(G_ol,1); % Closed loop system

figure,bode(G_ol)
set(findall(gcf,'type','line'),'linewidth',1.5); % increases the linewidth for Bode plot

% Open and simulate the system
open('Sim_relay_deadzone');
sim('Sim_relay_deadzone');

%fetching data
time = ans.tout;
r = ans.r;
y = ans.y;
e = ans.e;
u_c = ans.u_c;
u_ac = ans.u_ac;


% plot setpoint and output
figure,
subplot(311)
plot(time, ones(size(time)), 'g--', 'LineWidth', 2)
hold on
plot(time, y, 'b', 'LineWidth', 1.5)
hold off
ylabel('System Output (rad)')
legend('Reference (r = 1 rad)', 'Attitude \theta (rad)', 'Location', 'northeast')
title('PID + Dead Zone: Case 1 - Nominal Step Response (\theta_{ref} = 1 rad)')
grid on
ylim([-0.2 1.5])

% plot control signals
subplot(312)
plot(time, u_c, 'b', 'LineWidth', 1.5)
xlabel('Time (s)')
ylabel('Control Signal (N·m)')
legend('u_c (PID Output)', 'Location', 'northeast')
grid on

% plot ON/OFF actuator output (after relay)
subplot(313)
stairs(time, u_ac, 'r', 'LineWidth', 1.5)
xlabel('Time (s)')
ylabel('Actuator Output (ON/OFF)')
legend('u_{ac} (Relay + Dead Zone Output)', 'Location', 'northeast')
ylim([-1.2 1.2])
yticks([-1 0 1])
grid on

% integral of error
ine_e = sum(e);

% Integral of the square error
ISE = sum((e).^2);

% Integral of the time multiplied by absolute error
ITAE = sum(time.*abs(e));

% IACE
CE = sum(abs(u_c));

% IACER
CRE = sum(abs(diff(u_c)/dt));