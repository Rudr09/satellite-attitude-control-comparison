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
G_ac = 1;
G_c = Kp + Ki/s + Kd*s/(0.05*s+1); % controller definition
G_p = tf(1,[11.4 0 0]); % plant or system definition
G_ol = G_c*G_ac*G_p; % Open-loop system 
G_cl = feedback(G_ol,1); % Closed loop system

figure,bode(G_ol)
set(findall(gcf,'type','line'),'linewidth',1.5); % increases the linewidth for Bode plot

% Open and simulate the system
open('sim_relay');
sim('sim_relay');

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
plot(time, zeros(size(time)), 'g--', 'LineWidth', 2)
hold on
plot(time, y, 'b', 'LineWidth', 1.5)
hold off
ylabel('System Output (rad)')
legend('Reference (r = 0 rad)', 'Attitude \theta (rad)', 'Location', 'northeast')
title('PID + Dead Zone: Case 5 - Detumbling')
grid on
ylim([-2.5 4])

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
legend('u_{ac} (Relay Output)', 'Location', 'northeast')
ylim([-1.2 1.2])
yticks([-1 0 1])
grid on
% After running your Simulink simulation:
% Assuming your output is stored as 'y' and time as 't'


% ── Reference value ───────────────────────────────────────
ref = r(end);   % takes final reference value automatically
                % works for Case 1 (ref=1) and Case 2 (ref=5)

% ── Settling Time (2% band) ───────────────────────────────
band        = 0.02 * abs(ref);
settled_idx = find(abs(y - ref) <= band, 1, 'first');

if ~isempty(settled_idx)
    settling_time = time(settled_idx);
    fprintf('Settling Time (2%%):  %.2f s\n', settling_time);
else
    settling_time = NaN;
    fprintf('Settling Time:       Did not settle\n');
end

% ── Overshoot ─────────────────────────────────────────────
if ref > 0
    overshoot_pct = (max(y) - ref) / ref * 100;
else
    overshoot_pct = (min(y) - ref) / abs(ref) * 100;
end
fprintf('Overshoot:           %.2f%%\n', overshoot_pct);

% ── Steady State Error ────────────────────────────────────
% Average of last 50 data points
ss_error = mean(abs(e(end-50:end)));
fprintf('Steady State Error:  %.4f rad\n', ss_error);

% ── Peak Control Signal ───────────────────────────────────
fprintf('Peak PID Output:     %.4f Nm\n', max(abs(u_c)));

% ── Switching Count (relay firings) ───────────────────────
% Count number of times relay output changes
switches = sum(abs(diff(u_ac)) > 0.5);
fprintf('Relay Switches:      %d times\n', switches);

% ── Peak Actuator Output ──────────────────────────────────
fprintf('Peak Actuator:       %.4f Nm\n', max(abs(u_ac)));