% Reads GNSS-SDR Acquisition dump .mat file using the provided
%  function and plots acquisition grid of acquisition statistic of PRN sat
% Antonio Ramos, 2017. antonio.ramos(at)cttc.es
% -------------------------------------------------------------------------
%
% Copyright (C) 2010-2019  (see AUTHORS file for a list of contributors)
%
% GNSS-SDR is a software defined Global Navigation
%           Satellite Systems receiver
%
% This file is part of GNSS-SDR.
% 
% SPDX-License-Identifier: GPL-3.0-or-later
%
% -------------------------------------------------------------------------
%

%% Configuration

path = 'C:\Users\Kannab\gnss\data\direct30\acq_dump*';
f = dir(path);

for i=1:length(f)
    filename = [f(i).folder, '\', f(i).name];
    load(filename);
    [n_fft, n_dop_bins] = size(acq_grid);
    [d_max, f_max] = find(acq_grid == max(max(acq_grid)));
    freq = (0 : n_dop_bins - 1) * double(doppler_step) - double(doppler_max);
    delay = (0 : n_fft - 1) / n_fft * n_chips;


    %% Plot data
    %--- Acquisition grid (3D)
    figure(1)
    if(lite_view == false)
        surf(freq, delay, acq_grid, 'FaceColor', 'interp', 'LineStyle', 'none')
        ylim([min(delay) max(delay)])
    else
        delay_interp = (0 : n_samples_per_chip * n_chips - 1) / n_samples_per_chip;
        grid_interp = spline(delay, acq_grid', delay_interp)';
        surf(freq, delay_interp, grid_interp, 'FaceColor', 'interp', 'LineStyle', 'none')
        ylim([min(delay_interp) max(delay_interp)])
    end
    xlabel('Doppler shift (Hz)')
    xlim([min(freq) max(freq)])
    ylabel('Code delay (chips)')
    zlabel('Test Statistics')
    
    [pathstr,name,ext] = fileparts(filename);
    saveas(gcf,[pathstr,  '\', name, '_3D', '.png'])
    %--- Acquisition grid (2D)
    figure(2)
    subplot(2,1,1)
    plot(freq, acq_grid(d_max, :))
    xlim([min(freq) max(freq)])
    xlabel('Doppler shift (Hz)')
    ylabel('Test statistics')
    title(['Fixed code delay to ' num2str((d_max - 1) / n_fft * n_chips) ' chips'])
    subplot(2,1,2)
    normalization = (d_samples_per_code^4) * input_power;
    plot(delay, acq_grid(:, f_max)./normalization)
    xlim([min(delay) max(delay)])
    xlabel('Code delay (chips)')
    ylabel('Test statistics')
    title(['Doppler wipe-off = ' num2str((f_max - 1) * doppler_step - doppler_max) ' Hz'])
    saveas(gcf,[pathstr,  '\', name, '_2D', '.png'])
end
