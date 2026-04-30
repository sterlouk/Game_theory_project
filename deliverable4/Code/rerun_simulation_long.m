
% Script to re-run the 5-strategy replicator dynamics simulation with a longer time span

% --- Parameters ---
M = 4;
T = 50;
p_values = [0.75, 0.60];
tspan = [0 2000]; % Significantly increased time span for convergence

% --- Initial Conditions ---
x0_mat = [
    1/5 1/5 1/5 1/5 1/5;      % Barycenter
    0.96 0.01 0.01 0.01 0.01; % Near All-M
    0.01 0.96 0.01 0.01 0.01; % Near All-1
    0.01 0.01 0.96 0.01 0.01; % Near Grim
    0.01 0.01 0.01 0.96 0.01; % Near Grim-Patient
    0.01 0.01 0.01 0.01 0.96; % Near Grim-Forgiver
    0.49 0.01 0.49 0.005 0.005;% High All-M and Grim
    0.1 0.8 0.025 0.025 0.05;  % High All-1
];

% Add the current directory to the path
addpath(fileparts(mfilename('fullpath')));

% --- Run Simulations ---
for i = 1:length(p_values)
    p = p_values(i);
    
    % Compute payoff matrix
    C = computeC(M, T, p);
    
    % Create and save phase portrait
    fig_title = sprintf('Replicator Dynamics (M=%d, T=%d, p=%.2f)', M, T, p);
    fig_handle = figure('Name', fig_title);
    
    phasePlot5(C, x0_mat, tspan, fig_title, fig_handle);
    
    % Save the figure
    fig_filename = sprintf('phase_portrait_p_%.2f_long_run.png', p);
    saveas(fig_handle, fig_filename);
    fprintf('Saved figure: %s\n', fig_filename);
end

disp('All simulations complete.');
