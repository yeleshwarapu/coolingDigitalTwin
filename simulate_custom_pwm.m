function [sim_temp, pwm_array, power_array] = simulate_custom_pwm(t, v, qin, T0, params, rad_area_m2, pwm_logic, fan_count)
    if nargin < 8
        fan_count = 6;
    end

    %% === Constants ===
    fan_current = 3;
    fan_voltage = 12;
    fan_power_per = fan_current * fan_voltage;
    total_fan_power = fan_count * fan_power_per;

    ambient = 35;
    alpha = 0.2;
    rad_eff = cosd(45);
    cfm_to_m3s = 0.0004719474;
    rho = 1.2;
    Cp_air = 1005;
    Cp_cool = 4184;
    mass = 1.2;
    cooling_factor = 0.7;

    fan_curve = @(pwm) interp1([0 50 100], [0 params(1) params(2)], pwm, 'linear', 'extrap');

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

        pwm = pwm_logic(T);
        fan_cfm = fan_curve(pwm) * fan_count;
        passive_cfm = 0.4 * v(i) * 60;
        total_cfm = fan_cfm + passive_cfm;
        flow_m3s = total_cfm * cfm_to_m3s;

        q_out = cooling_factor * flow_m3s * rho * Cp_air * (T - ambient) * rad_eff * rad_area_m2;
        dT = (q_in - q_out) * dt / (mass * Cp_cool);
        sim_temp(i) = max(T + alpha * dT, ambient);

        pwm_array(i) = pwm;
        power_array(i) = (pwm / 100) * total_fan_power;
    end
end