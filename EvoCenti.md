# Paper Replication Guide: Iterated Symmetric Centipede: Learning and Evolutionary Games

## 1. Overview
This README provides a comprehensive breakdown of the paper "Iterated Symmetric Centipede: Learning and Evolutionary Games" by I. Lazaridis and Athanasios Kehagias (March 2026). The purpose of this document is to serve as a functional specification for an AI copilot to replicate the study's methodology while substituting or adding new game-theoretic strategies.

The paper studies the **Iterated Symmetric Centipede (ISC)** game. 
* **Base Game:** The classic Centipede game is first converted into a One-shot Symmetric Centipede (OSC) by randomizing who moves first to remove player asymmetry.
* **Iterated Game:** The ISC consists of playing $T$ rounds of the OSC. Because it is iterated, players retain memory of previous rounds, allowing for history-dependent strategies (similar to the Iterated Prisoner's Dilemma).

## 2. Strategies Currently Analyzed
The core of the paper investigates the interaction between three specific strategies:
1.  **$\sigma_{All-M}$ (All-Cooperate):** Play to the very last stage ($M$) in every OSC game.
2.  **$\sigma_{All-1}$ (All-Defect):** Terminate the game immediately at stage 1 in every OSC game.
3.  **$\sigma_{G}$ (Grim Trigger):** Start by playing to stage $M$. Continue doing so as long as the opponent also plays to stage $M$. If the opponent ever terminates early (plays $m < M$), permanently switch to playing stage 1 ($\sigma_{All-1}$) for all subsequent rounds.

*Replication Note for Copilot:* To replicate this paper with different strategies (e.g., Tit-for-Tat, Pavlov, Always-m), you will need to replace this strategy matrix and recalculate the corresponding $3 	imes 3$ (or $N 	imes N$) payoff matrix $C$.

## 3. Section Breakdown
To fully replicate the paper, a copilot must execute the following analytical steps:
* **Section 2 (Preliminaries):** Construct the game tree for a classic Centipede of length $M$ with payoff parameters $p$. Convert this tree into the normal form bimatrix One-Round Symmetric Centipede (OSC) matrix $A$.
* **Section 3 (Iterated Symmetric Centipede):** Construct the ISC bimatrix game $D = (C, C^T)$ for $T$ rounds based on the chosen memory strategies.
* **Section 4 (Nash Equilibria):** Analytically derive the pure and mixed Nash Equilibria (NE) of the ISC using standard game-theoretic inequalities and partial derivatives of the expected payoffs.
* **Section 5 (Replicator Dynamics):** Model a large, infinite population using standard replicator dynamics differential equations ($rac{dx_m}{dt} = x_m((Cx)_m - x^T Cx)$). Find the rest points (roots of the system) and determine their asymptotic stability by calculating the eigenvalues of the Jacobian matrix.
* **Section 6 (Evolutionary Stable Strategies - ESS):** Check the stability conditions of the Nash Equilibria to determine which strategies are true ESS.
* **Section 7 (Markovian Analysis):** Model a finite, small population (size $N$) using Markov Chains and a Pairwise Proportional Imitation (PPI) revision protocol. Calculate state transition probabilities (using matrix $R$), identify transient vs. absorbing states, and trace basins of attraction.

## 4. Descriptions of Diagrams and Figures
If the copilot is generating a replicated paper, it should produce equivalent plots for the new strategies. Here is exactly what the original diagrams depict:

* **Figure 1: A Centipede Game (Game Tree)**
    * *Type:* Extensive-form game tree diagram.
    * *Description:* Illustrates a classic Centipede game with $M=4$. It shows alternating decision nodes (circles for Player 1, squares for Player 2). At each node, an arrow points "down" to a terminal diamond leaf (indicating early stopping) with specific payoff pairs, and an arrow points "right" to continue the game. The payoffs demonstrate the increasing total pie but the immediate advantage of defecting.

* **Figure 2: Phase portrait of the ISC Replicator Dynamics for $p = 3/4$**
    * *Type:* 2D Simplex (Triangle) Phase Portrait.
    * *Description:* Represents the continuous-time replicator dynamics for a large population with the three core strategies. The three corners of the triangle represent populations consisting of 100% of a single strategy. The interior contains vector arrows (a directional field) showing the flow of population proportions over time. It visually demonstrates basins of attraction pulling toward stable rest points (like the set of mixtures between Grim and All-M) and pushing away from unstable rest points (like pure All-Defect).

* **Figure 3: Phase portrait of (5.1) for $p = 3/5$**
    * *Type:* 2D Simplex (Triangle) Phase Portrait.
    * *Description:* Identical in structure to Figure 2, but plotted for a different payoff parameter ($p=3/5$). The vector field changes significantly, showing different stability regimes (e.g., pure All-Defect might become a stable attractor under different parameters).

* **Figure 4: State transition graph for $p = 3/4$**
    * *Type:* Discrete state transition grid (Markov Chain visualization).
    * *Description:* Represents the finite population Markov model ($N=10$). It is plotted on a 2D Cartesian grid where the X and Y axes represent the number of individuals playing two of the strategies (the third is implied since the total is $N$). Nodes represent discrete population states. Directed arrows connect nodes, representing non-zero transition probabilities under Pairwise Proportional Imitation (e.g., south, southeast, west, east transitions). Absorbing states are shown where flows terminate.

* **Figure 5: State transition graph for $p = 3/5$**
    * *Type:* Discrete state transition grid.
    * *Description:* The same Markov state grid as Figure 4, but calculated with $p=3/5$. The arrows change directions based on the shifted expected payoffs, illustrating how the eventual absorbing states of the finite population shift based on game parameters.

    Here are the recommended values to use for your simulation:$M$ (Number of OSC stages): Set $M = 4$. This directly matches the classic Centipede game tree illustrated in Figure 1 of the paper.  $T$ (Number of ISC rounds): Let's use $T = 50$. The game needs enough iterations for history-dependent strategies (like the Grim Trigger, $\sigma_{G}$) to meaningfully penalize early termination and interact with the All-Cooperate ($\sigma_{All-M}$) and All-Defect ($\sigma_{All-1}$) strategies.  $p$ (Terminator payoff share): I highly recommend running two separate batches to capture the structural phase shifts described by the authors:  Run 1: $p = 0.75$ ($3/4$). This will allow you to replicate the specific phase portrait from Figure 2 and the Markov state transition graph from Figure 4.  Run 2: $p = 0.60$ ($3/5$). This parameter shift alters the stability regimes, allowing you to replicate the vector fields from Figure 3 and the altered state transitions from Figure 5.  Initial Population FrequenciesTo properly explore the basins of attraction and the stability of the Nash Equilibria, let's test these three starting conditions ($x_{All-M}, x_{All-1}, x_G$) for both runs:  The Barycenter ($0.33, 0.33, 0.34$): An evenly mixed population to see where the natural flow of the directional field pulls the system.  High Defection ($0.10, 0.80, 0.10$): A population dominated by $\sigma_{All-1}$. This will test whether the Grim Trigger and All-M coalition can invade, or if pure All-Defect acts as an unstable/stable rest point depending on your $p$ value.  High Cooperation ($0.45, 0.10, 0.45$): A population split mostly between All-M and Grim. This helps observe the set of mixtures between Grim and All-M, which act as stable rest points in the continuous-time replicator dynamics.  