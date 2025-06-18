function [t_full, v_full, qin_full, temp_actual_full, initial_temp, idle_time] = prepare_lap_data(data, idle_time)
    % === Extract lap log data ===
    t_lap = data.Time_s_;
    v_lap = data.Speed_m_s_;
    temp_actual = data.InverterTemp_C_;
    initial_temp = temp_actual(1);

    % === Idle phase simulation ===
    dt = mean(diff(t_lap));
    n_idle = round(idle_time / dt);
    t_idle = linspace(0, idle_time, n_idle)';
    v_idle = zeros(n_idle, 1);
    idle_heat_watts = 10;  % realistic inverter idle loss
    qin_idle = idle_heat_watts * ones(n_idle, 1);
    temp_idle = initial_temp * ones(n_idle, 1);

    % === Driving heat profile ===
    qin_lap = 1500 + 300 * sin(2 * pi * t_lap / max(t_lap));

    % === Merge idle and driving data ===
    t_full = [t_idle; t_lap + idle_time];
    v_full = [v_idle; v_lap];
    qin_full = [qin_idle; qin_lap];
    temp_actual_full = [temp_idle; temp_actual];
end
