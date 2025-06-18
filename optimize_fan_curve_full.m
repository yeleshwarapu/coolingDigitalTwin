function optimize_fan_curve_full
    idle_time = 300;  % ← only define it once here

    %% === Radiator Config ===
    rad_type = '3x120';
    num_rads = 2;
    [rad_w, rad_h] = get_rad_dimensions(rad_type);
    rad_area_m2 = (rad_w * rad_h * 1e-6) * num_rads;

    %% === Load Lap Data ===
    data = readtable('cooling_log_endurance.csv');
    [t_full, v_full, qin_full, temp_actual_full, initial_temp, idle_time] = prepare_lap_data(data, idle_time);

     %% === Fan Curve Optimization ===
    guess = [80, 200];         % initial guess: CFM at 50% and 100%
    lb = [50, 180];            % lower bounds
    ub = [140, 224];           % upper bounds
    cost_fn = @(p) fan_curve_cost(p, t_full, v_full, qin_full, initial_temp, rad_area_m2);
    options = optimoptions('fmincon', 'Display', 'iter', 'MaxFunctionEvaluations', 200);
    [opt_params, ~] = fmincon(cost_fn, guess, [], [], [], [], lb, ub, [], options);


    %% === Simulate with Optimal Params ===
    [temp_active, pwm_out, power_out] = simulate(temp_actual_full, t_full, v_full, qin_full, initial_temp, opt_params, true, rad_area_m2);
    [temp_passive, ~, ~] = simulate(temp_actual_full, t_full, v_full, qin_full, initial_temp, opt_params, false, rad_area_m2);
    dt = mean(diff(t_full));
    energy_wh = sum(power_out) * dt / 3600;

    %% === Plot Results ===
    plot_results(t_full, temp_actual_full, temp_active, temp_passive, pwm_out, energy_wh, opt_params, v_full, idle_time);
end
