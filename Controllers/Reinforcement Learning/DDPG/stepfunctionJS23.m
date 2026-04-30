
function [nextObs, reward, isDone, loggedSignals] = stepfunctionJS23(action, loggedSignals)

    % Parameters
    Ts = 0.1;
    J  = 11.4;

    % Read true state
    theta    = loggedSignals.theta;
    thetaDot = loggedSignals.thetaDot;
    thetaRef = loggedSignals.thetaRef;

    % Action = torque
    torque = action;

    % Dynamics (Euler)
    thetaDotNext = thetaDot + Ts * (torque / J);
    thetaNext    = theta + Ts * thetaDot;

    % Error
    errorNext = thetaRef - thetaNext;
   

    % Observation = [error; velocity]
    nextObs = [
        errorNext;
        thetaDotNext
    ];

    q_eps = 0.15;    % good attitude threshold (rad)      = qε
    w_eps = 0.15;    % good rate threshold (rad/s)        = ωε
    q_l   = 0.5;     % bad attitude threshold (rad)       = q₁
    w_l   = 0.5;     % bad rate threshold (rad/s)         = ω₁ 

    % Reward (tracking + smoothness)
    base_r = - ( ...
        errorNext^2 + ...
        0.1 * thetaDotNext^2 + ...
        0.001 * torque^2 );

    if abs(errorNext) <= q_eps && abs(thetaDotNext) <= w_eps
       c = 500;
       isDone = true;   % episode complete, goal achieved

    elseif abs(errorNext) <= q_eps
        c = 50;
        isDone = false;  % keep going, need rate to settle too

    elseif abs(errorNext) >= 2*q_l || abs(thetaDotNext) >= 2*w_l
        c = -50;
        isDone = true;   % episode failed, reset

    elseif abs(errorNext) >= q_l || abs(thetaDotNext) >= w_l
        c  = -5;
        isDone = false;  % still recoverable, don't reset yet
    else
        c = 0;
        isDone = false;
    end
    reward = base_r + c; 

    % Update environment memory
    loggedSignals.theta    = thetaNext;
    loggedSignals.thetaDot = thetaDotNext;
end

