
% Script to run the 5-strategy Markov chain simulation

% --- Parameters ---
M = 4;
T = 50;
N = 10; % Population size
p_values = [0.75, 0.60];

% Add the current directory to the path
addpath(fileparts(mfilename('fullpath')));

% --- Run Simulations ---
for i = 1:length(p_values)
    p = p_values(i);
    
    % Compute payoff matrix
    C = computeC(M, T, p);
    
    % Build the Markov transition matrix P
    % P(i,j) is the probability of transitioning from state i to state j
    fprintf('Building Markov transition matrix for p = %.2f...\n', p);
    P = buildMarkovP5(N, C);
    
    % Find absorbing states
    % An absorbing state is one where the diagonal element is 1
    absorbing_indices = find(diag(P) == 1);
    
    if isempty(absorbing_indices)
        fprintf('No pure absorbing states found for p = %.2f.\n', p);
    else
        fprintf('Absorbing states for p = %.2f:\n', p);
        
        % Enumerate all possible states to map indices back to populations
        all_states = enumStates(N, 5);
        
        % Display the absorbing states
        absorbing_states = all_states(absorbing_indices, :);
        disp('Population counts (All-M, All-1, Grim, Grim-P, Grim-F):');
        disp(absorbing_states);
    end
    fprintf('--------------------------------------------------\n');
end

disp('Markov analysis complete.');
