# Operational Analysis & Performance Modelling: Satellite Attitude Control Systems
An aerospace  engineering project comparing 4 controllers- PID+Relay, PID+Relay +Deadzone, DDPG and DQN for a single-axis satellite attitude control across 5 test

**Cases** : Baseline tracking, Large angle recovery, Steady disturbance, Inertia Variation and Detumbling

This Final Year Project (BEng Hons Aerospace Engineering, University of Hertfordshire) implements and benchmarks four attitude control approaches:

- **PID + Relay** (classical)
- **PID + Relay + Deadzone** (classical)
- **DDPG** (continuous deep reinforcement learning)
- **DQN** (discrete deep reinforcement learning)

All controllers target a satellite plant model with moment of inertia J = 11.4 kg·m² (Khosravi & Sarhadi, 2016).

**Repository Structure:**

The repository is organized by controller type, with each controller containing all necessary files (Simulink models, MATLAB code, and results plots).

 **Satellite Attitude Control Research**
│
├── Controllers/
│   ├── Classical/                          — Traditional fixed-gain controllers
│   │   ├── PID_Relay/                      — PID + Relay (discrete on-off thruster control)
│   │   │   ├── sim_relay.slx                  — Simulink model: rigid-body dynamics + PID relay control
│   │   │   └── relay_sim.m                    — MATLAB script: simulation execution & performance analysis
│   │   │
│   │   └── PID_Deadzone_Relay/             — PID + Deadzone + Relay (improved chattering mitigation)
│   │       ├── sim_relay_deadzone.slx         — Simulink model with deadzone to reduce actuator cycling
│   │       └── relay_deadzone_sim.m           — MATLAB script: simulation & metrics extraction
│   │
│   └── Reinforcement_Learning/             — Modern learning-based controllers
│       ├── DDPG/                           — Deep Deterministic Policy Gradient (continuous control)
│       │   ├── Double_integrator_model3.m     — Plant dynamics model (Euler equations, sensor noise, actuator constraints)
│       │   ├── stepfunctionJS23.m             — Environment step function (reward shaping, state transitions)
│       │   ├── resetfuncJS2model3.m           — Reset function (scenario initialization)
│       │   └── rlsimulate.m                   — Testing/evaluation script for trained DDPG agent
│       │
│       └──  DQN/                            — Deep Q-Network (discrete on-off thruster control)
│           ├── main_script_DQN.m              — Training script: DQN agent setup, learning loop, performance tracking
│           ├── stepfunctionDQN.m              — Environment step function (discrete action space: +1, -1, 0 Nm)
│           ├── resetfuncDQN.m                 — Reset function (scenario initialization & randomization)
│           └── simulate_DQN.m                 — Testing script: evaluate trained DQN across test scenarios
│
└── docs/                                   — Documentation & theory reference
    └── (Project documentation, design methodology, key findings)

**Root Level**

- docs/ — project_report.pdf

- README.md — This file

- .gitignore — Git ignore rules

**Installation & Setup**

**Requirements:**

MATLAB R2022b or later

Simulink

**Steps to run:**

For classical controllers, open both Simulink and the MATLAB code file and run the code with all the paramter inputs for the results

For DRL controllers, open all the four files (training script, reset function, step function and testing funcrion). Ensure they are contained in the same folder.

If the agent is to be retrained, update the training parameters with your choice of values and run the training script file.

If there is no re-training required, simply run the testing script file.

**Test Case Performance:**

Nominal step (θ₀=0.5 rad): All controllers succeed

Large angle (θ₀=5 rad): PID variants succeed; DDPG may diverge (Case 2 failure)

Disturbance (0.5 N·m): Classical + RL handled; Ki helps steady-state rejection

Inertia variation (J→1000): Classical controllers fail; RL more robust

Detumbling (ω₀=10 rad/s): Classical fails; RL approaches target asymptotically

**Known Limitations:**

RL Stochasticity: Results vary across runs due to random seeds and experience replay sampling

Mitigation: Fixed seed (rng(42)) and multiple training runs recommended

DDPG Case 2 divergence: Large angle recovery with stochastic agent and isDone boundary condition

Root cause: Training distribution mismatch; agent leaves exploration space

Scope exclusions: Double DQN, Dueling architecture, Transformers remain out of scope

**PID Gains:**

Kp = 20;    % Proportional gain

Ki = 0.12;  % Integral gain (steady-state disturbance rejection)

Kd = 39.7;  % Derivative gain (damping)

**DDPG Setup:**

% Actor/Critic network: 2 hidden layers, 128 neurons

% Replay buffer: 1e6 capacity

% Batch size: 64

% Noise decay: 1e-3

% StopTrainingValue: 400 

% actInfo bounds: [-5, 5] 

**DQN Setup:**

% Action space: [-1, 0, 1]

% Q-value network: 2 hidden layers, 64 neurons

% Epsilon-greedy: ε=1.0, decay=1e-3, min=0.05

% Domain randomisation: ±10% inertia variation

% Replay buffer: 1e5 capacity, batch size 32

**Verification & Validation Strategy**

This project demonstrates systematic V&V discipline for control systems:

**Verification Approach:**
- Defined mission-level requirements: settling time <5s, overshoot <5%, 
  robustness to 88× parameter variation
- Developed test matrix across 5 operational scenarios: nominal tracking, 
  large-angle recovery, disturbance rejection, inertia variation, detumbling
- For each controller (PID, DDPG, DQN), logged performance metrics across 
  all scenarios
- Compared results against defined requirements

**Key Results:**
- DQN: Achieved robustness to parameter variation (partial control under 88× 
  inertia) but slower nominal settling
- DDPG: Fastest nominal response but complete failure under inertia variation
- PID: Perfect disturbance rejection but requires tuning; steady-state chattering

**Insight:** Discrete action space (DQN) provides inherent robustness to 
parameter uncertainty—valuable for spacecraft in uncertain environments.

**References:**

Khosravi, A., & Sarhadi, P. (2016). Automatic control of satellite attitude using neural networks. Automatika, 57(4), 951–961.

Vedant et al. (2019). Deep deterministic policy gradient for autonomous satellite control.

Sa Marques & Sarhadi (2025). Reinforcement learning for space systems.

Pérez-Muñoz, et al. DQN vs actor-critic architectures for spacecraft attitude determination.

Author

Dharshini Subramani

BEng (Hons) Aerospace Engineering with Space Technology

University of Hertfordshire

Supervised by Dr. Pouria Sarhadi

License
This project is submitted as part of academic requirements for the University of Hertfordshire. Use for educational purposes only. Academic integrity and attribution of sources (Khosravi & Sarhadi, 2016) is mandatory.

Acknowledgements:
Dr. Pouria Sarhadi (supervisor)
Khosravi & Sarhadi (2016) for the foundational plant model

Defence Date: 17th April 2026
Report Submission: March 2026
Project Timeline: September 2025 – May 2026
