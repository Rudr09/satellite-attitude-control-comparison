clc;
clear;
close all;

clc; clear; close all;
load('trainedDQNAgent.mat');

% ── Parameters ───────────────────────────────────────────
Ts        = 0.1;
J         = 11.4;
max_steps = 500;

% ── SELECT CASE HERE ─────────────────────────────────────
caseNum = 1;   % Change to 1, 2, 3, 4, or 5

switch caseNum
    case 1  % Step Response
        theta    = 0;
        thetaDot = 0;
        Ref      = 1.0;
        d        = 0;
        J        = 11.4;
        caseTitle = 'Case 1: Step Response';

    case 2  % Large Initial Angle
        theta    = 5.0;
        thetaDot = 0;
        Ref      = 1.0;
        d        = 0;
        J        = 11.4;
        caseTitle = 'Case 2: Large Initial Angle';

    case 3  % External Disturbance
        theta    = 0;
        thetaDot = 0;
        Ref      = 1.0;
        d        = 0.5;    % match PID and DDPG
        J        = 11.4;
        caseTitle = 'Case 3: External Disturbance (d=0.5 Nm)';

    case 4  % Inertia Variation
        theta    = 0;
        thetaDot = 0;
        Ref      = 1.0;
        d        = 0;
        J        = 1000;   % different from training
        max_steps = 1500;  % 150 seconds for slow dynamics
        caseTitle = 'Case 4: Inertia Variation (J=1000)';

    case 5  % Detumbling
        theta    = 3;
        thetaDot = 0.3;
        Ref      = 0;
        d        = 0;
        J        = 11.4;
        caseTitle = 'Case 5: Detumbling';
end

% ── Storage ───────────────────────────────────────────────
history_theta    = zeros(1, max_steps);
history_thetaDot = zeros(1, max_steps);
history_torque   = zeros(1, max_steps);
history_error    = zeros(1, max_steps);
history_time     = (0:max_steps-1) * Ts;

% ── Simulation Loop ───────────────────────────────────────
for k = 1:max_steps

    error = Ref - theta;
    obs   = [error; thetaDot];

    action = getAction(agent, obs);
    if iscell(action)
        torque = double(action{1});
    else
        torque = double(action);
    end

    history_theta(k)    = theta;
    history_thetaDot(k) = thetaDot;
    history_torque(k)   = torque;
    history_error(k)    = error;

    % Dynamics with disturbance
    thetaDotNew = thetaDot + Ts * ((torque + d) / J);
    thetaNew    = theta    + Ts * thetaDot;

    theta    = thetaNew;
    thetaDot = thetaDotNew;
end

% ── Performance Metrics ───────────────────────────────────
% Settling time
if Ref ~= 0
    band = 0.02 * Ref;
else
    band = 0.05;   % fixed band for detumbling
end

settled_idx = find(abs(history_theta - Ref) <= band, 1, 'first');
if ~isempty(settled_idx)
    settling_time = history_time(settled_idx);
    fprintf('Settling Time (2%%):  %.2f s\n', settling_time);
else
    settling_time = NaN;
    fprintf('Settling Time: Did not settle within simulation\n');
end

% Overshoot (only meaningful for Cases 1 and 3)
if caseNum == 1 || caseNum == 3
    overshoot_pct = (max(history_theta) - Ref) / Ref * 100;
    fprintf('Overshoot:           %.2f%%\n', overshoot_pct);
else
    overshoot_pct = NaN;
    fprintf('Overshoot:           N/A for this case\n');
end

% Steady state error
ss_error = mean(abs(history_error(end-50:end)));
fprintf('Steady State Error:  %.4f rad\n', ss_error);

% Peak torque
fprintf('Peak Torque:         %.4f Nm\n', max(abs(history_torque)));

% ── Plotting ─────────────────────────────────────────────
figure('Name', ['DQN On-Off ' caseTitle], ...
       'Position', [100 100 800 700]);

% Plot 1: Attitude Tracking
subplot(3,1,1);
plot(history_time, Ref*ones(1,max_steps), 'r--', ...
     'LineWidth', 2, 'DisplayName', sprintf('Reference (%.0f rad)', Ref));
hold on;
plot(history_time, history_theta, 'b', ...
     'LineWidth', 2, 'DisplayName', 'Satellite Angle \theta');
if ~isnan(settling_time)
    xline(settling_time, 'g--', 'LineWidth', 1.5, ...
          'DisplayName', sprintf('Settling Time = %.1fs', settling_time));
end
yline(Ref + band, 'k:', 'LineWidth', 1, 'DisplayName', '+2% band');
yline(Ref - band, 'k:', 'LineWidth', 1, 'DisplayName', '-2% band');
title(['DQN On-Off (' caseTitle ')']);
ylabel('Angle (rad)');
legend('Location', 'southeast');
grid on;

% Plot 2: Tracking Error or Angular Rate (Case 5)
subplot(3,1,2);
if caseNum == 5
    plot(history_time, history_thetaDot, 'b', 'LineWidth', 1.5);
    yline(0, 'k--', 'LineWidth', 1);
    title('Angular Rate \theta dot');
    ylabel('Rate (rad/s)');
else
    plot(history_time, history_error, 'r', 'LineWidth', 1.5);
    yline(0, 'k--', 'LineWidth', 1);
    title('Tracking Error  e = \theta_{ref} - \theta');
    ylabel('Error (rad)');
end
grid on;

% Plot 3: Control Effort (stairs for discrete)
subplot(3,1,3);
stairs(history_time, history_torque, 'm', 'LineWidth', 1.5);
yline(0, 'k--', 'LineWidth', 1);
title('Control Effort (Discrete Torque ±1 Nm)');
ylabel('Torque (Nm)');
xlabel('Time (s)');
grid on;