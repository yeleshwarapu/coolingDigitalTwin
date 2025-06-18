function cost = fan_curve_cost(params, t, v, qin, T0, rad_area_m2)
    [temp, ~, power] = simulate([], t, v, qin, T0, params, true, rad_area_m2);

    dt = mean(diff(t));
    energy_wh = sum(power) * dt / 3600;

    % soft penalty above 65°C
    soft_limit = 65;
    soft_penalty_scale = 0.03;  % weight for going above 65°C
    temp_excess = temp(temp > soft_limit) - soft_limit;
    soft_penalty = sum(temp_excess.^2) * soft_penalty_scale;

    % hard cutoff if temp ever goes above 75°C
    if max(temp) > 75
        cost = 1e6 + max(temp);  % punish
    else
        cost = energy_wh + soft_penalty;
    end
end
