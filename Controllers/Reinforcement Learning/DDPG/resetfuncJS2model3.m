function [initialObs, loggedSignals] = resetfuncJS2model3()

    % Initial true state
    theta0     = (rand*2 - 1)*pi;
    thetaDot0  = (rand*2 - 1)*0.5;

    % Reference
    thetaRef = (rand*2 - 1)*pi;

    % Store environment state
    loggedSignals.theta     = theta0;
    loggedSignals.thetaDot  = thetaDot0;
    loggedSignals.thetaRef  = thetaRef;

    % Observation = [error; velocity]
    error0 = thetaRef - theta0;

    initialObs = [
        error0;
        thetaDot0
    ];
end

