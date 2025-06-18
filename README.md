# FSAE Cooling Digital Twin

**Predictive thermal simulation and fan control optimization for Formula SAE electric vehicle systems**  
Author: Arjun Yeleshwarapu, University of California, Riverside – Highlander Racing

---

## Overview

This MATLAB-based digital twin simulates and optimizes the cooling system of a Formula SAE EV. It uses real telemetry data—vehicle speed, inverter temperature, fan PWM—to evaluate thermal behavior and control strategies.

The tool enables radiator sizing, fan layout, and control logic decisions without requiring wind tunnel testing or physical prototyping. Results showed a peak inverter temperature reduction of 11°C using optimized ramp-based fan curves, with no increase in energy usage compared to bang-bang control.

---

## Features

- Thermal simulation using lumped capacitance model
- Active/passive airflow modeling based on speed and fan PWM
- Fan control strategy comparison: bang-bang vs. linear ramp
- Cost function for tuning: penalizes overheating and excess energy draw
- MATLAB optimization using `fmincon`
- Energy analysis with estimated battery consumption
- Modular inputs for radiator size, fan count, control parameters

---

## File Structure

```
cooling-digital-twin/
├── simulate.m               # Main inverter thermal simulation
├── fan_curve_cost.m         # Cost function used in optimization
├── optimize_fan_curve.m     # Optimization script using endurance log data
├── test_data/               # CSV logs (speed, temp, pwm)
├── plots/                   # Generated result plots
├── docs/                    # Paper and technical writeup
└── README.md
```

---

## How to Use

1. Place test log data (CSV format) in the `test_data/` folder. It should include:
   - Time (s)
   - Vehicle speed (m/s)
   - Inverter temperature (°C)

2. Run `optimize_fan_curve.m` to generate optimized CFM-to-PWM fan mappings.

3. Review simulation outputs:
   - Temperature profile
   - Fan power consumption
   - PWM duty cycle trends
   - Energy draw in Wh and percent of battery capacity

---

## Example Results

| Control Strategy | Peak Temp (°C) | Avg Temp (°C) | Fan Energy (Wh) | Battery Use (%) |
|------------------|----------------|----------------|------------------|------------------|
| Bang-bang        | 78.7           | 70.8           | 77.2             | 6.21             |
| Ramp-optimized   | 67.7           | 63.5           | 77.7             | 6.25             |

---

## Future Work

- Model Predictive Control (MPC) integration
- Coolant-side flow modeling and pump duty cycle optimization
- Dynamic heat transfer coefficient computation using Reynolds/Nusselt correlations
- Head loss modeling through radiator and hose network
- Real-time simulation with live CAN telemetry input
- GUI-based parameter tuning interface
- Hardware-in-the-loop testbench for firmware validation

---

## References

- [Full Paper PDF](./docs/FSAE_Cooling_Digital_Twin.pdf)
- [GitHub Repository](https://github.com/ayele002/fsae-cooling-twin)
- Key papers:
  - [Digital Twins in Automotive Design (Piromalis et al., 2022)](https://doi.org/10.3390/asi5040065)
  - [Thermal Management in EVs (Zhao et al., 2023)](https://www.sciencedirect.com/science/article/pii/S2352152X23000774)
  - [Simulation Systems in Manufacturing (Sharma et al., 2024)](https://www.sciencedirect.com/science/article/pii/S2214157X24006385)

---

## Acknowledgments

This project was developed for the Highlander Racing Formula SAE EV team at UCR. Special thanks to the CS subteam for providing CAN log access and data acquisition tools.
