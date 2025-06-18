function run_full_pwm_baseline()
    %% === Config ===
    data = readtable('cooling_log_endurance.csv');
    idle_time = 300;
    rad_type = '3x120';
    num_rads = 2;
    [rad_w, rad_h] = get_rad_dimensions(rad_type);
    rad_area_m2 = (rad_w * rad_h * 1e-6) * num_rads;
    [t_full, v_full, qin_full, temp_actual_full, initial_temp, ~] = prepare_lap_data(data, idle_time);

    %% === Limit sim duration ===
    t_limit = 1800;
    mask = t_full <= t_limit;
    t_full = t_full(mask);
    v_full = v_full(mask);
    qin_full = qin_full(mask);
    temp_actual_full = temp_actual_full(mask);

    %% === Define Bang-Bang PWM Logic ===
    persistent fan_on
    fan_on = false;
    pwm_logic = @(T) hysteresis_pwm(T);
    function pwm = hysteresis_pwm(T)
        if T >= 70
            fan_on = true;
        elseif T <= 68
            fan_on = false;
        end
        pwm = double(fan_on) * 100;
    end

    %% === Simulate ===
    fan_params = [80, 200]; % CFM at 50% and 100% PWM
    fan_count = 6; % 3 fans per rad x 2 rads
    [sim_temp, pwm, power] = simulate_custom_pwm(t_full, v_full, qin_full, initial_temp, fan_params, rad_area_m2, pwm_logic, fan_count);

    %% === Metrics ===
    dt = mean(diff(t_full));
    energy_wh = sum(power) * dt / 3600;
    peak_actual = max(temp_actual_full); avg_actual = mean(temp_actual_full);
    peak_sim = max(sim_temp); avg_sim = mean(sim_temp);
    idle_end_time = t_full(find(v_full > 0, 1));

        %% === Temperature Plot (Left 2/3 + Right Panel) ===
    fig1 = figure('Color', 'w', 'Units', 'inches', 'Position', [1 1 6 3]);
    axes('Position', [0.1 0.15 0.6 0.75]);
    plot(t_full, temp_actual_full, 'r-', 'LineWidth', 2); hold on;
    plot(t_full, sim_temp, 'b--', 'LineWidth', 2);
    xline(idle_end_time, '--k', 'Idle Ends', 'FontSize', 9, 'Interpreter', 'latex');

    xlabel('Time (s)', 'FontSize', 11, 'FontWeight', 'bold');
    ylabel('Inverter Temp (^\circC)', 'FontSize', 11, 'FontWeight', 'bold', 'Interpreter', 'tex');
    title({'Bang-Bang Fan Logic w/ Hysteresis', sprintf('Energy Used: %.2f Wh', energy_wh)}, ...
        'FontSize', 12, 'FontWeight', 'bold');

    xlim([0 1800]);
    ylim([30 max([temp_actual_full; sim_temp]) + 10]);
    grid on; box on;
    set(gca, 'FontSize', 9, 'LineWidth', 1.2, 'TickDir', 'out');

   annotation('textbox', [0.73 0.15 0.25 0.75], ...
    'String', {
        '\bfLegend:', ...
        '\color{red}Actual', ...
        '\color{blue}Simulated', ...
        '\color{black}', ...
        '', ...
        '\bfPeak Temp (^\circC):', ...
        sprintf('\\color{red}Actual: %.1f', peak_actual), ...
        sprintf('\\color{blue}Sim: %.1f', peak_sim), ...
        '\color{black}', ...
        '', ...
        '\bfAvg Temp (^\circC):', ...
        sprintf('\\color{red}Actual: %.1f', avg_actual), ...
        sprintf('\\color{blue}Sim: %.1f', avg_sim)
    }, ...
    'FontSize', 9, ...
    'Interpreter', 'tex', ...
    'EdgeColor', 'none');

    exportgraphics(fig1, 'fig_bangbang_temp_summary.pdf', 'ContentType', 'vector');

    %% === PWM Plot (Left 2/3 + Right Panel) ===
    fig2 = figure('Color', 'w', 'Units', 'inches', 'Position', [1 1 6 3]);
    axes('Position', [0.1 0.15 0.6 0.75]);
    plot(t_full, pwm, 'Color', [0.5 0 0.5], 'LineWidth', 2); hold on;
    xline(idle_end_time, '--k', 'Idle Ends', 'FontSize', 9, 'Interpreter', 'latex');

    xlabel('Time (s)', 'FontSize', 11, 'FontWeight', 'bold');
    ylabel('Fan PWM (%)', 'FontSize', 11, 'FontWeight', 'bold');
    title('PWM Over Time', 'FontSize', 12, 'FontWeight', 'bold');

    xlim([0 1800]); ylim([0 105]);
    grid on; box on;
    set(gca, 'FontSize', 9, 'LineWidth', 1.2, 'TickDir', 'out');

    annotation('textbox', [0.73 0.15 0.25 0.75], ...
        'String', {
            '\bfPWM Summary:', ...
            sprintf('Max PWM: %.1f%%', max(pwm)), ...
            sprintf('Avg PWM: %.1f%%', mean(pwm)), ...
            '', ...
            sprintf('Energy: %.2f Wh', energy_wh)
        }, ...
        'FontSize', 9, ...
        'Interpreter', 'tex', ...
        'EdgeColor', 'none');

    exportgraphics(fig2, 'fig_bangbang_pwm_summary.pdf', 'ContentType', 'vector');
end