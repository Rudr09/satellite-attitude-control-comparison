clc;
clear;
close all;

J  = 1;     % inertia
Ts = 0.05;  % sample time

A = [1 Ts;
     0  1];

B = [0;
     Ts/J];
obsInfo = rlNumericSpec([2 1], ...
    'LowerLimit', [-20 -50]', ...
    'UpperLimit', [ 20  50]');
obsInfo.Name = "obs";
actInfo = rlFiniteSetSpec([-5 0 5]); % Off, Full Left, Full Right
actInfo.Name = "torque";

r = 1; %reference angle
env = rlFunctionEnv(obsInfo, actInfo, @stepfunction, @resetfunction);
validateEnvironment(env)

% NEW DQN Network Architecture
dnn = [
    featureInputLayer(2, 'Name', 'state')
    fullyConnectedLayer(64)
    reluLayer
    fullyConnectedLayer(64)
    reluLayer
    fullyConnectedLayer(numel(actInfo.Elements), 'Name', 'output') % Outputs 3 values
];

% Create the Q-function (The DQN "Critic")
% Note we use rlVectorQValueFunction now
critic = rlVectorQValueFunction(dnn, obsInfo, actInfo);

% Define Agent Options once
agentOpts = rlDQNAgentOptions(...
    'SampleTime', Ts, ...
    'DiscountFactor', 0.99, ...
    'TargetUpdateMethod', 'smoothing', ...
    'TargetSmoothFactor', 1e-3, ...
    'ExperienceBufferLength', 1e5);

% Exploration logic swap:
agentOpts.EpsilonGreedyExploration.Epsilon = 1.0;
agentOpts.EpsilonGreedyExploration.EpsilonDecay = 1.5e-5; % Similar to your VarianceDecay
agentOpts.EpsilonGreedyExploration.EpsilonMin = 0.05;

% Define the Agent
agent = rlDQNAgent(critic, agentOpts);
trainOpts = rlTrainingOptions( ...
    'MaxEpisodes', 1000, ...
    'MaxStepsPerEpisode', 300, ...
    'StopTrainingCriteria', "AverageReward", ...
    'StopTrainingValue', -0.01);

trainingStats = train(agent, env, trainOpts);
save("trainedAgent.mat", "agent");