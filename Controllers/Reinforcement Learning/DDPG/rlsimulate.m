clc;
clear;
close all;
load('trainedAgent.mat');

% Parameters
Ts        = 0.1;
J         = 11.4;
max_steps = 500;
Ref       = 1;

% Initial conditions
theta    = 0.0;
thetaDot = 0.0;

% Storage
history_theta    = zeros(1, max_steps);
history_thetaDot = zeros(1, max_steps);
history_torque   = zeros(1, max_steps);
history_error    = zeros(1, max_steps);
history_time     = (0:max_steps-1) * Ts;

% Simulation loop
for k = 1:max_steps

    % Observation (matches stepfunction exactly)
    error = Ref - theta;
    obs   = [error; thetaDot];

    % Get action from trained agent
    % Get action from trained agent
    action = getAction(agent, obs);
    if iscell(action)
        torque = double(action{1});
    else
        torque = double(action);
    end

    % Store BEFORE update (current state)
    history_theta(k)    = theta;
    history_thetaDot(k) = thetaDot;
    history_torque(k)   = torque;
    history_error(k)    = error;

    % Dynamics — USE OLD thetaDot for theta update
    thetaDotNew = thetaDot + Ts * (torque / J);  % new rate
    thetaNew    = theta    + Ts * thetaDot;       % OLD rate ✓
    
    % Update states
    theta    = thetaNew;
    thetaDot = thetaDotNew;
end

% ── Calculate Performance Metrics ────────────────────────
% Settling time (within 2% of reference)
band        = 0.02 * Ref;   % 2% band = 0.02 rad
settled_idx = find(abs(history_theta - Ref) <= band, 1, 'first');
if ~isempty(settled_idx)
    settling_time = history_time(settled_idx);
    fprintf('Settling Time (2%%):  %.2f s\n', settling_time);
else
    settling_time = NaN;
    fprintf('Settling Time: Did not settle within simulation\n');
end

% Overshoot
overshoot_pct = (max(history_theta) - Ref) / Ref * 100;
fprintf('Overshoot:           %.2f%%\n', overshoot_pct);

% Steady state error (average of last 50 steps)
ss_error = mean(abs(history_error(end-50:end)));
fprintf('Steady State Error:  %.4f rad\n', ss_error);

% Peak torque
fprintf('Peak Torque:         %.4f Nm\n', max(abs(history_torque)));

% ── Plotting ─────────────────────────────────────────────
figure('Name', 'DDPG Continuous Case 5 - Detumbling', ...
       'Position', [100 100 800 700]);

% Plot 1: Attitude Tracking
subplot(3,1,1);
plot(history_time, Ref*ones(1,max_steps), 'r--', ...
     'LineWidth', 2, 'DisplayName', 'Reference (0 rad)');
hold on;
plot(history_time, history_theta, 'b', ...
     'LineWidth', 2, 'DisplayName', 'Satellite Angle \theta');

% Add settling time marker
if ~isnan(settling_time)
    xline(settling_time, 'g--', 'LineWidth', 1.5, ...
          'DisplayName', sprintf('Settling Time = %.1fs', settling_time));
end

% Add 2% band
yline(Ref + band, 'k:', 'LineWidth', 1, 'DisplayName', '+2% band');
yline(Ref - band, 'k:', 'LineWidth', 1, 'DisplayName', '-2% band');

title('DDPG Continuous (Case 5: Detumbling)');
ylabel('Angle (rad)');
legend('Location', 'southeast');
grid on;

% Plot 2: Tracking Error
subplot(3,1,2);
plot(history_time, history_error, 'r', 'LineWidth', 1.5);
yline(0, 'k--', 'LineWidth', 1);
title('Tracking Error  e = \theta_{ref} - \theta');
ylabel('Error (rad)');
grid on;

% Plot 3: Control Effort
subplot(3,1,3);
plot(history_time, history_torque, 'm', 'LineWidth', 1.5);
yline(0, 'k--', 'LineWidth', 1);
title('Control Effort (Torque)');
ylabel('Torque (Nm)');
xlabel('Time (s)');
grid on;


