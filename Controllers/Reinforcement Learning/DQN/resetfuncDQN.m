function [obs, loggedSignals] = resetfuncDQN()
    J        = 11.4 * (1 + rand * 87);
    theta    = (rand * 2 - 1) * 3.0;   % widened to ±3 rad
    thetaDot = (rand * 2 - 1) * 0.5;
    thetaRef = 1.0;                     % changed to 0 for detumbling
    loggedSignals.disturbance = (rand * 2 - 1) * 0.3;
    error = thetaRef - theta;
    obs   = [error; thetaDot];
    loggedSignals.theta    = theta;
    loggedSignals.thetaDot = thetaDot;
    loggedSignals.thetaRef = thetaRef;
    loggedSignals.J        = J;
end