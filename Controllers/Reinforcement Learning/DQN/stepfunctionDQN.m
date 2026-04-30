function [nextObs, reward, isDone, loggedSignals] = stepfunctionDQN(action, loggedSignals)

    Ts       = 0.1;
    J        = loggedSignals.J;

    theta    = loggedSignals.theta;
    thetaDot = loggedSignals.thetaDot;
    thetaRef = loggedSignals.thetaRef;

    torque = action;

    % Dynamics
    d            = loggedSignals.disturbance;
    thetaDotNext = thetaDot + Ts * ((torque + d) / J);
    thetaNext    = theta    + Ts * thetaDot;

    % Error
    errorNext = thetaRef - thetaNext;

    % Observation
    nextObs = [errorNext; thetaDotNext];

    % Thresholds
    q_eps = 0.1;
    w_eps = 0.1;
    q_l   = 0.5;
    w_l   = 0.5;

    % Base reward
    base_r = -(errorNext^2 + ...
               0.1 * thetaDotNext^2 + ...
               0.001 * torque^2);

    % Conditional reward — FIXED isDone
    if abs(errorNext) <= q_eps && abs(thetaDotNext) <= w_eps
        c      = 500;
        isDone = true;    % success ✓
    elseif abs(errorNext) <= q_eps
        c      = 50;
        isDone = false;
    elseif abs(thetaNext) > 4*pi  % truly catastrophic
        c      = -50;
        isDone = true;    % only reset on full rotation ✓
    elseif abs(errorNext) >= q_l || abs(thetaDotNext) >= w_l
        c      = -5;
        isDone = false;   % recoverable, keep going ✓
    else
        c      = 0;
        isDone = false;
    end

    reward = base_r + c;

    loggedSignals.theta    = thetaNext;
    loggedSignals.thetaDot = thetaDotNext;
end
