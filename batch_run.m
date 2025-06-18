angles = [30, 45];                     % radiator angles (degrees)
ambients = [30, 35, 40];               % ambient temps (°C)
idle_times = [60, 300];                % idle durations (sec)

results = [];  % to store data

for a = 1:length(angles)
    for t = 1:length(ambients)
        for i = 1:length(idle_times)
            rad_angle = angles(a);
            ambient_temp = ambients(t);
            idle_time = idle_times(i);

            fprintf('\n🌀 Running: %d° angle, %d°C ambient, %ds idle\n', ...
                    rad_angle, ambient_temp, idle_time);

            try
                [energy_wh, max_temp, avg_pwm] = ...
                    optimize_fan_curve_full(rad_angle, ambient_temp, idle_time);
                
                results = [results; rad_angle, ambient_temp, idle_time, ...
                           energy_wh, max_temp, avg_pwm];
            catch ME
                fprintf('⚠️ Error: %s\n', ME.message);
                results = [results; rad_angle, ambient_temp, idle_time, NaN, NaN, NaN];
            end
        end
    end
end

% display table
result_table = array2table(results, ...
    'VariableNames', {'RadAngle', 'AmbientTemp', 'IdleTime', ...
                      'Energy_Wh', 'MaxTemp_C', 'AvgPWM'});
disp(result_table);
