function fig = plot_results(plot_info, varargin)

    if nargin == 0
        n_experiments = 1;
    elseif nargin == 1
        n_experiments = varargin{1};
    else
        msg = "Invalid number of arguments to function";
        error(msg);
    end
    
    if ~plot_info.force_lim
        plot_info.x_min = min(plot_info.x);
        plot_info.x_max = max(plot_info.x);
        plot_info.y_min_left = min(plot_info.y_left);
        plot_info.y_max_left = max(plot_info.y_left);

        if isfield(plot_info, 'y_right')
            plot_info.y_min_right = min(plot_info.y_right);
            plot_info.y_max_right = max(plot_info.y_right);

        end
    end

    x_range = linspace(plot_info.x_min, plot_info.x_max, 100);
        
    for i = 1:n_experiments
        
        if isfield(plot_info, 'label')
            fig_label = plot_info.label;
        else
            fig_label = sprintf(plot_info.label_format, plot_info.label_args(i));
        end
        
        fig(i) = figure("Name", fig_label, "Position", [i*20 i*20, 600 500], 'NumberTitle', 'off');
        
        hold on;
        
        scatter(plot_info.x(i,:), plot_info.y_left(i,:));

        xlabel(plot_info.x_label);
        xlim([plot_info.x_min plot_info.x_max]);

        ylabel(plot_info.y_label_left);
        ylim([plot_info.y_min_left plot_info.y_max_left]);

        if isfield(plot_info, 'y_right')
            yyaxis right;
            
            plot(plot_info.x, plot_info.y_right);
            ylabel(plot_info.y_label_right);
            ylim([plot_info.y_min_right plot_info.y_max_right]);
        end
           
        hold off
        
        if isfield(plot_info, 'title')
            title(plot_info.title);
        else
            title(sprintf(plot_info.title_format, plot_info.title_args(i)));
        end
        
    end
end

