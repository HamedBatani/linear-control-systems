# Quarter-Car Suspension Control

I investigated a quarter-car suspension model as my Linear Control Systems course project. My work connects mechanical modeling, feedback controller design, disturbance estimation, and simulation-based analysis of noise and parameter variations.

## What I worked on

- I formulated a state-space model with sprung and unsprung masses, suspension damping and stiffness, road excitation, and an actuator force.
- I studied body-acceleration responses and pole-zero structure, and explored lead compensation and PID control.
- I investigated filtered disturbance reconstruction and feedforward cancellation, comparing tracking and road-disturbance responses.
- I simulated measurement noise and stiffness variations to examine the limitations of the design.

## Files and script map

| Files | Role |
| --- | --- |
| `report.pdf` | My theoretical derivations, design discussion, and reported results (Persian) |
| `matlab/Q2.m` | State-space model, transfer functions, and baseline responses |
| `matlab/Q3b.m`, `Q3c.m`, `Q3d.m` | Compensation and disturbance-response comparisons |
| `matlab/Q4.m` | Filtered disturbance reconstruction and cancellation architecture |
| `matlab/Q5a.m`, `Q5b.m`, `Q5c.m` | PID-based noise and parameter-variation experiments |
| `figures/` | Archived plots accompanying the project |
| `report-source/report.tex` | Available LaTeX source; archived source may require figure-path adjustments |

## Reproduction and status

Open the scripts in MATLAB with Control System Toolbox. Each script is a separate coursework experiment and should be inspected before execution; model definitions are not yet unified across the scripts. The accompanying results are archived submissions, not newly reproduced benchmarks.

I preserve the submitted code rather than silently replacing it. Before using the results as a validated control design, I need to reconcile model coefficients and acceleration feedthrough terms across scripts, correct the disturbance transfer-function construction in Q5b/Q5c, and distinguish input-disturbance scaling in Q3c from implemented controller rejection. These checks are documented to make the limitations explicit.

The original project-folder `document2.pdf` contained unrelated linear-algebra notes and is excluded. A verified project assignment statement is not available in this archive.
