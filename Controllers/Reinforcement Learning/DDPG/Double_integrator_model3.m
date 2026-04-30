clc;
clear;
close all;

J  = 11.4;     % inertia
Ts = 0.1;  % sample time

A = [1 Ts;
     0  1];

B = [0;
     Ts/J];
obsInfo = rlNumericSpec([2 1], ...
    'LowerLimit', [-2*pi -5]', ...
    'UpperLimit', [ 2*pi  5]');
obsInfo.Name = "obs";

% obs = [theta; theta_dot]
actInfo = rlNumericSpec([1 1], ...
    'LowerLimit', -5, ...
    'UpperLimit',  5);
actInfo.Name = "torque";
r = 1;   % desired angle (rad)
env = rlFunctionEnv(obsInfo, actInfo, @stepfunctionJS23, @resetfuncJS2model3);
validateEnvironment(env)

% Actor Network
actorNet = [
    featureInputLayer(2)
    fullyConnectedLayer(64)
    reluLayer
    fullyConnectedLayer(64)
    reluLayer
    fullyConnectedLayer(64)
    reluLayer
    fullyConnectedLayer(1)
    tanhLayer
    scalingLayer('Scale',5)
];

actor = rlContinuousDeterministicActor(actorNet, obsInfo, actInfo);

% Critic Network
statePath = [
    featureInputLayer(2,'Name','state')

    fullyConnectedLayer(64)
    reluLayer

    fullyConnectedLayer(64)
    reluLayer

    fullyConnectedLayer(64,'Name','fc_s')
];

actionPath = [
    featureInputLayer(1,'Name','action')
    fullyConnectedLayer(64,'Name','fc_a')
];

commonPath = [
    additionLayer(2,'Name','add')   
    reluLayer('Name','relu')
    fullyConnectedLayer(1,'Name','q')
];

criticNet = layerGraph(statePath);
criticNet = addLayers(criticNet, actionPath);
criticNet = addLayers(criticNet, commonPath);

criticNet = connectLayers(criticNet,'fc_s','add/in1');
criticNet = connectLayers(criticNet,'fc_a','add/in2');
plot(criticNet)

critic = rlQValueFunction(criticNet, obsInfo, actInfo, ...
    'ObservationInputNames','state', ...
    'ActionInputNames','action');


% Create DDPG Agent
% Create DDPG Agent
agentOpts = rlDDPGAgentOptions;
agentOpts.SampleTime = Ts;
agentOpts.DiscountFactor = 0.99;
agentOpts.TargetSmoothFactor = 1e-3;
agentOpts.ExperienceBufferLength = 1e6; % Buffer size for experience replay
agentOpts.MiniBatchSize = 128;          % Mini-batch size for training
agentOpts.CriticOptimizerOptions.LearnRate = 1e-3;

agentOpts.NoiseOptions.Variance = 0.5;          % initial exploration
agentOpts.NoiseOptions.VarianceDecayRate = 1e-5; 
% --------------------------------------------------------
agentOpts.ActorOptimizerOptions.LearnRate = 1e-3; % Default is usually 1e-3

agent = rlDDPGAgent(actor, critic, agentOpts);
trainOpts = rlTrainingOptions(...
    'MaxEpisodes',                1500, ...
    'MaxStepsPerEpisode',          500, ...
    'ScoreAveragingWindowLength',   20, ...
    'StopTrainingCriteria',  'AverageReward', ...
    'StopTrainingValue',           350, ...
    'Verbose',                    true, ...
    'Plots',             'training-progress');

trainingStats = train(agent, env, trainOpts);
save("trainedAgent.mat", "agent");

