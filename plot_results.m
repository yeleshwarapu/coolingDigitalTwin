function plot_results_split(t, temp_actual, temp_active, temp_passive, pwm, energy_wh, params, v, idle_time)
    %% === Find Idle End Time ===
    if ~isempty(v) && any(v > 0)
        idle_end_time = t(find(v > 0, 1));
    else
        idle_end_time = t(1) + idle_time;
    end

    %% === Compute Stats ===
    peak_actual   = max(temp_actual);    avg_actual   = mean(temp_actual);
    peak_active   = max(temp_active);    avg_active   = mean(temp_active);
    peak_passive  = max(temp_passive);   avg_passive  = mean(temp_passive);
    peak_pwm      = max(pwm);            avg_pwm      = mean(pwm);

    %% === Temperature Plot (Left 2/3 + Right Panel) ===
    fig1 = figure('Units','inches','Position',[1, 1, 6, 3], 'Color','w');

    ax1 = axes('Position',[0.1 0.15 0.6 0.75]); % left panel
    hold on;
    plot(t, temp_actual,  'r-',  'LineWidth', 2);
    plot(t, temp_active,  'b--', 'LineWidth', 2);
    plot(t, temp_passive, 'k--', 'LineWidth', 2);
    xline(idle_end_time, '--k', 'Idle Ends', 'FontSize', 9, 'Interpreter','latex');

    xlabel('Time (s)', 'FontSize', 11, 'FontWeight','bold');
    ylabel('Inverter Temp (\circC)', 'FontSize', 11, 'FontWeight','bold', 'Interpreter','tex');
    title({'Fan Curve Optimization', sprintf('Energy Used: %.2f Wh', energy_wh)}, ...
        'FontSize', 12, 'FontWeight','bold');

    xlim([0 t(end)]);
    ylim([30 max([temp_actual; temp_active; temp_passive]) + 10]);
    grid on; box on;
    set(gca, 'FontSize', 9, 'LineWidth', 1.2, 'TickDir','out');

    annotation('textbox', [0.73 0.15 0.25 0.75], ...
        'String', {
            '\bfLegend:', ...
            '\color{red}Actual', ...
            '\color{blue}Simulated (Active)', ...
            '\color{black}Simulated (Passive)', ...
            '', ...
            '\bfPeak Temp (\circC):', ...
            sprintf('\\color{red}%.1f', peak_actual), ...
            sprintf('\\color{blue}%.1f', peak_active), ...
            sprintf('\\color{black}%.1f', peak_passive), ...
            '', ...
            '\bfAvg Temp (\circC):', ...
            sprintf('\\color{red}%.1f', avg_actual), ...
            sprintf('\\color{blue}%.1f', avg_active), ...
            sprintf('\\color{black}%.1f', avg_passive)
        }, ...
        'FontSize',9, ...
        'Interpreter','tex', ...
        'EdgeColor','none');

    exportgraphics(fig1, 'fig_temp_with_sidepanel.pdf', 'ContentType', 'vector');

    %% === PWM Plot (Left 2/3 + Right Panel) ===
    fig2 = figure('Units','inches','Position',[1, 1, 6, 3], 'Color','w');

    ax2 = axes('Position',[0.1 0.15 0.6 0.75]); % left panel
    hold on;
    plot(t, pwm, 'Color', [0.5 0 0.5], 'LineWidth', 2);
    xline(idle_end_time, '--k', 'Idle Ends', 'FontSize', 9, 'Interpreter','latex');

    xlabel('Time (s)', 'FontSize', 11, 'FontWeight','bold');
    ylabel('Fan PWM (%)', 'FontSize', 11, 'FontWeight','bold');
    title('PWM Over Time', 'FontSize', 12, 'FontWeight','bold');

    xlim([0 t(end)]);
    ylim([0 105]);
    grid on; box on;
    set(gca, 'FontSize', 9, 'LineWidth', 1.2, 'TickDir','out');

    annotation('textbox', [0.73 0.15 0.25 0.75], ...
        'String', {
            '\bfPWM Summary:', ...
            sprintf('Max PWM: %.1f%%', peak_pwm), ...
            sprintf('Avg PWM: %.1f%%', avg_pwm), ...
            '', ...
            sprintf('Energy: %.2f Wh', energy_wh)
        }, ...
        'FontSize',9, ...
        'Interpreter','tex', ...
        'EdgeColor','none');

    exportgraphics(fig2, 'fig_pwm_with_sidepanel.pdf', 'ContentType', 'vector');

    %% === Console Printout ===
    fprintf('\n✅ Fan Curve Result:\n');
    fprintf('  50%% PWM = %.1f CFM\n', params(1));
    fprintf(' 100%% PWM = %.1f CFM\n', params(2));
    fprintf('🔋 Energy Used = %.2f Wh\n', energy_wh);
    fprintf('🌡️  Peak Temp = %.1f°C | Avg Temp = %.1f°C\n\n', peak_active, avg_active);
end
