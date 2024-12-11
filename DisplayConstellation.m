function DisplayConstellation(M, mod_type, ini_phase)
    if mod_type == "QAM"
        ss = qammod(0 : M-1, M, "Gray", "UnitAveragePower", true);
    elseif mod_type == "PSK"
        ss = pskmod(0 : M-1, M, ini_phase, "Gray");
    end
    
    if M == 2 && mod_type == "PSK"
        title_text = "\textbf{BPSK Signal Set}";
    elseif M == 4 && mod_type == "PSK"
        title_text = "\textbf{QPSK Signal Set}";
    else
        title_text = strcat("\textbf{", num2str(M), "-", mod_type, " Signal Set}");
    end
    
    x_min = min(real(ss)) - 0.2;
    x_max = max(real(ss)) + 0.2;
    y_min = min(imag(ss)) - 0.2;
    y_max = max(imag(ss)) + 0.2;
    
    plot(linspace(x_min, x_max, 1e5), zeros(1, 1e5), "k", "LineWidth", 2);
    hold on;
    plot(zeros(1, 1e5), linspace(y_min, y_max, 1e5), "k", "LineWidth", 2);
    hold on;
    scatter(real(ss), imag(ss), 250, "filled", "LineWidth", 2, ...
                                               "MarkerFaceColor", "#B33030");
    set(gca, "FontSize", 20);
    set(gca, "TickLabelInterpreter", "latex");
    title(title_text, "FontSize", 20, "Interpreter", "latex");
    xlabel("Real", "FontSize", 20, "Interpreter", "latex");
    ylabel("Imaginary", "FontSize", 20, "Interpreter", "latex");
    xlim([x_min, x_max]);
    ylim([y_min, y_max]);
    grid;
end