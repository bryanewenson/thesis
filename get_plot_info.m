function plot_info = get_plot_info(plot_type_keyval, results, dataset, V_name, M_name)

    switch plot_type_keyval
        case 1
           %Plot the Error_Consistency over Average Effect Size

            plot_info.label_format = "Effect Size - SSP %0.1f%%";
            plot_info.label_args = 100 .* ssp_set;
            plot_info.title_format = sprintf("ECA wrt Average Effect Size of Underlying Features\n%%0.1f%%%% Subsampled From %s Dataset, Using %s %s", dataset, V_name, M_name);
            plot_info.title_args = 100 .* ssp_set;

            for i = 1:n_experiments
                plot_info.x(i,:) = results(i).D_mean;
                plot_info.y(i,:) = results(i).EC_avg;
            end
            plot_info.x_label = "Average Effect Size of Underlying 5 Features";
            plot_info.y_label = "Average Error Consistency";

        case 2
            %Plot the Error Consistency over Sample Size Portion

            plot_info.label = sprintf("Sample Size Portions - %s", M_name);
            plot_info.title = sprintf("ECA wrt Sample Size Portion Using %s %s on %s Dataset", V_name, M_name, dataset);

            plot_info.x(1,:) = results(1).ssp;
            plot_info.y(1,:) = results(1).EC_avg;
  
            plot_info.x_label = "Sample Size Portion";
            plot_info.y_label = "Average Error Consistency";

    end

end
