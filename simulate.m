function [sim_temp, pwm_array, power_array] = simulate(temp_ref, t, v, qin, T0, params, use_fans, rad_area_m2)
%% === Constants ===
fan_count = 6;
fan_current = 3; % amps
fan_voltage = 12;
fan_power_per = fan_current * fan_voltage;  % 36 W
total_fan_power = fan_count * fan_power_per;

ambient = 35;                   % ambient temperature (°C)
alpha = 0.2;                    % simulation damping factor
rad_eff = cosd(45);             % radiator angle efficiency factor
cfm_to_m3s = 0.0004719474;      % convert CFM to m^3/s
rho = 1.2;                      % air density (kg/m^3)
Cp_air = 1005;                  % specific heat of air (J/kg°C)
Cp_cool = 4184;                  % specific heat of coolant (J/kg°C)
mass = 1.03;                     % coolant mass (kg)
cooling_factor = 0.7;           % overall system efficiency

%% === Fan Logic ===
fan_curve = @(pwm) interp1([0 50 100], [0 params(1) params(2)], pwm, 'linear', 'extrap');
pwm_logic = @(T) min(100, max(0, (T - 45) * 3.5));

%% === Init Arrays ===
n = length(t);
sim_temp = zeros(n, 1); sim_temp(1) = T0;
pwm_array = zeros(n, 1);
power_array = zeros(n, 1);

%% === Simulation Loop ===
for i = 2:n
    dt = max(t(i) - t(i-1), 0.01);
    T = sim_temp(i-1);
    q_in = qin(i);

    % fan control
    pwm = pwm_logic(T);
    if ~use_fans
        pwm = 0;
    end

    % flow rates
    fan_cfm = fan_curve(pwm) * fan_count;
    passive_cfm = 0.8 * v(i) * 60;  % crude passive airflow model
    total_cfm = fan_cfm + passive_cfm;
    flow_m3s = total_cfm * cfm_to_m3s;

    % cooling
    q_out = cooling_factor * flow_m3s * rho * Cp_air * (T - ambient) * rad_eff * rad_area_m2;
    dT = (q_in - q_out) * dt / (mass * Cp_cool);
    sim_temp(i) = max(T + alpha * dT, ambient);

    % outputs
    pwm_array(i) = pwm;
    power_array(i) = (pwm / 100) * total_fan_power;
end
end
