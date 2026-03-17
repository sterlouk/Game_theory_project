# Iterated Symmetric Centipede (ISC) — MATLAB Implementation

**Based on:** Lazaridis & Kehagias, *Iterated Symmetric Centipede: Learning and Evolutionary Games* (2026)

---

## 1. Project Overview

This project implements an evolutionary game theoretic analysis of the **Iterated Symmetric Centipede (ISC)** game. The ISC consists of T repeated plays of the One-Shot Symmetric Centipede (OSC), where the first-moving player is selected at random each round.

The key modification from the original paper is the replacement of the **All-M** strategy with **All-M/2**, which cooperates at the midpoint level rather than the maximum. This single change has significant downstream consequences for the payoff matrix, absorbing states, and equilibrium structure.

---

## 2. Strategies

Three ISC strategies are studied:

| Index | Symbol        | Name      | Description                                                                 |
|-------|---------------|-----------|-----------------------------------------------------------------------------|
| 1     | σ_All-M/2     | All-M/2   | Always play ρ_{M/2} — cooperates at mid-level                              |
| 2     | σ_All-1       | All-1     | Always play ρ₁ — always defects                                             |
| 3     | σ_G           | Grim      | Play ρ_M in round 1; if opponent ever plays ρ_m with m < M, switch to ρ₁ forever |

**Note on Grim trigger:** The trigger condition is m < M (not m < M/2). Therefore:
- Grim triggers against All-M/2 (plays ρ_{M/2}, and M/2 < M) ✓
- Grim triggers against All-1 (plays ρ₁, and 1 < M) ✓
- Grim does **not** trigger against another Grim (plays ρ_M, and M < M is false) ✗

This means two Grims cooperate at the highest level ρ_M every round, giving C(3,3) = T·M.

---

## 3. The OSC A-Matrix

The OSC payoff matrix A (to the row player) satisfies:

```
A(i,i)   = i
A(i,j)   = (2i+1)·p       if i < j
A(i,j)   = (2j+1)·(1-p)   if i > j
```

Entries used in our game (k = M/2):

| Entry   | Formula          | Value (M=4, p=3/4) |
|---------|------------------|--------------------|
| A(1,1)  | 1                | 1                  |
| A(1,k)  | 3p               | 2.25               |
| A(k,1)  | 3(1-p)           | 0.75               |
| A(k,k)  | k = M/2          | 2                  |
| A(k,M)  | (M+1)·p          | 3.75               |
| A(M,k)  | (M+1)·(1-p)      | 1.25               |
| A(M,M)  | M                | 4                  |

---

## 4. The ISC Payoff Matrix C

C(i,j) = payoff to strategy i playing against strategy j over T rounds of OSC.

### Symbolic form

```
C = | (M/2)·T          3(1-p)·T               (M+1)p + (T-1)·3(1-p) |
    | 3p·T             T                       3p + (T-1)             |
    | (M+1)(1-p)+(T-1)·3p   3(1-p)+(T-1)     T·M                    |
```

### Derivation of each entry

| Cell   | Matchup             | Round 1       | Trigger? | Rounds 2..T     | Formula                      |
|--------|---------------------|---------------|----------|-----------------|------------------------------|
| C(1,1) | All-M/2 vs All-M/2  | A(k,k)        | —        | A(k,k)          | T·k = T·M/2                  |
| C(1,2) | All-M/2 vs All-1    | A(k,1)        | —        | A(k,1)          | T·3(1-p)                     |
| C(1,3) | All-M/2 vs Grim     | A(k,M)        | Yes (k<M)| A(k,1)          | (M+1)p + (T-1)·3(1-p)       |
| C(2,1) | All-1 vs All-M/2    | A(1,k)        | —        | A(1,k)          | T·3p                         |
| C(2,2) | All-1 vs All-1      | A(1,1)        | —        | A(1,1)          | T                             |
| C(2,3) | All-1 vs Grim       | A(1,k)        | Yes (1<M)| A(1,1)          | 3p + (T-1)                   |
| C(3,1) | Grim vs All-M/2     | A(M,k)        | Yes (k<M)| A(1,k)          | (M+1)(1-p) + (T-1)·3p       |
| C(3,2) | Grim vs All-1       | A(M,1)=A(k,1) | Yes (1<M)| A(1,1)          | 3(1-p) + (T-1)               |
| C(3,3) | Grim vs Grim        | A(M,M)        | No       | A(M,M)          | T·M                          |

### Numerical values (M=4, T=10)

|          | vs All-M/2 | vs All-1 | vs Grim  |
|----------|-----------|---------|---------|
| All-M/2  | 20        | 7.5     | 10.5    |
| All-1    | 22.5      | 10      | 11.25   |
| Grim     | 21.5      | 9.75    | 40      |

**p = 3/4**

|          | vs All-M/2 | vs All-1 | vs Grim  |
|----------|-----------|---------|---------|
| All-M/2  | 20        | 12      | 13.8    |
| All-1    | 18        | 10      | 10.8    |
| Grim     | 18.2      | 10.2    | 40      |

**p = 3/5**

### Why Grim dominates

The diagonal entries (payoff in a homogeneous population) are:
- All-M/2 vs All-M/2: T·(M/2) = **20**
- All-1 vs All-1: T = **10**
- Grim vs Grim: T·M = **40**

Grim achieves twice the payoff of All-M/2 in self-play because it cooperates at the maximum level ρ_M (never triggering against other Grims), while All-M/2 only reaches ρ_{M/2}.

---

## 5. Replicator Dynamics

The population frequencies x = (x₁, x₂, x₃) evolve according to:

```
dx_m/dt = x_m · ( (C·x)_m − x'·C·x )
```

### Rest points (adapted from Prop. 5.1)

- **Always admissible:** (0,1,0) and the entire line {(x₁, 0, 1−x₁) : x₁ ∈ [0,1]}
- **Admissible when p ≥ 2/3:** two additional mixed rest points (see paper)

### Stability of (0,1,0) (Prop. 5.2)

Eigenvalues of J at (0,1,0): [−T, −(3p−2), −T(3p−2)]

- **p > 2/3 (e.g. p=3/4):** all negative → asymptotically **stable**
- **p < 2/3 (e.g. p=3/5):** second and third positive → **unstable**

### Stable equilibrium set (Prop. 5.5)

The set {(x₁, 0, 1−x₁) : x₁ ∈ [0,1]} is a stable non-isolated equilibrium set.
All trajectories converge to this set (no defectors survive long term).

---

## 6. Markov Chain Analysis

### Population state space

States s = (s₁, s₂, s₃) with s₁+s₂+s₃ = N. Total: (N+1)(N+2)/2 states.
Plotted as (s₁, s₂) in the 2D simplex.

### PPI revision protocol (Def. 7.3)

Selected m₁-user switches to m₂ with probability:

```
ρ_{m1,m2}(s) = x_{m2} · [q_{m2}(s) − q_{m1}(s)]₊  /  Σ_m x_m · [q_m(s) − q_{m1}(s)]₊
```

where q_m(s) = (s_m−1)·C(m,m) + Σ_{n≠m} s_n·C(m,n) is the per-player payoff.

Transition probability: P(s → s') = (s_{m1}/N) · ρ_{m1,m2}(s)

### Absorbing states

**Original paper (All-M):** entire s₂=0 face is absorbing, because All-M and Grim earn the same payoff (T·M) when facing each other.

**Our modification (All-M/2):** C(1,1) = T·(M/2) ≠ C(3,3) = T·M, so Grim earns strictly more than All-M/2 on the s₂=0 face. All-M/2 players switch to Grim. The **only truly absorbing states** are the three pure states:
- (N, 0, 0) — pure All-M/2
- (0, N, 0) — pure All-1
- (0, 0, N) — pure Grim

Blue dots in the state transition graph = absorbing (pure) states.
Red dots = transient states.

---

## 7. File Descriptions

### Functions (4 files)

| File                       | Signature                            | Description                                                  |
|----------------------------|--------------------------------------|--------------------------------------------------------------|
| `xRepDyn.m`                | `x = xRepDyn(x0,p,M,T,Tf)`           | Solves replicator ODE with ode45. Returns (npts×3) frequency matrix. |
| `PhasePlot.m`              | `PhasePlot(p,M,T)`                   | Draws normalised quiver field of replicator dynamics on 2-simplex. |
| `PStateTransitionGraph.m`  | `P = PStateTransitionGraph(p,M,T,N)` | Builds PPI transition matrix P and draws the state graph. Blue=absorbing (pure), red=transient. |
| `sMarkDyn.m`               | `s = sMarkDyn(s0,p,M,T,N,P,Tm)`      | Simulates one Markov trajectory. Returns (Tm+1 × 3) state sequence. |

All functions contain local subfunctions `buildC`, and `PStateTransitionGraph`/`sMarkDyn` also contain `listStates` and `perPlayerPayoff`. No external helper files are needed.

### Scripts (3 files)

| File         | Output                                             |
|--------------|----------------------------------------------------|
| `xRep001.m`  | Two phase portrait figures: p=3/4 and p=3/5        |
| `xMark001.m` | Two state transition graph figures: p=3/4 and p=3/5 |
| `xPrintC.m`  | One figure displaying the symbolic C matrix         |

### LaTeX (1 file)

| File          | Description                              |
|---------------|------------------------------------------|
| `printC.tex`  | Standalone LaTeX file with symbolic C matrix. Compile with `pdflatex printC.tex`. |

---

## 8. How to Run

Place all 8 files in the same folder and set it as MATLAB's working directory:

```matlab
cd 'path/to/folder'
```

Then run each script independently:

```matlab
xPrintC      % symbolic C matrix figure
xRep001      % phase portraits (p=3/4 and p=3/5)
xMark001     % state transition graphs (p=3/4 and p=3/5)
```

The functions `xRepDyn`, `PhasePlot`, `PStateTransitionGraph`, `sMarkDyn` can also be called directly:

```matlab
% Example: replicator trajectory from random initial condition
x0 = rand(3,1); x0 = x0/sum(x0);
x = xRepDyn(x0, 3/4, 4, 10, 1);
plot(x')

% Example: Markov chain trajectory
P = PStateTransitionGraph(3/4, 4, 10, 10);
s = sMarkDyn([3 4 3], 3/4, 4, 10, 10, P, 100);
plot(s)
```

---

## 9. Parameters

| Parameter | Value | Description                              |
|-----------|-------|------------------------------------------|
| M         | 4     | Number of centipede stages (must be even)|
| T         | 10    | Number of ISC rounds                     |
| p         | 3/4, 3/5 | Terminator payoff share (p ∈ (1/2, 1]) |
| N         | 10    | Population size (Markov chain)           |
| Tf        | 1     | Final simulation time (replicator)       |
| Tm        | 100   | Number of Markov steps                   |
| k         | M/2=2 | Cooperation level of All-M/2            |

**Critical threshold:** p = 2/3 determines stability of (0,1,0):
- p > 2/3 (e.g. p=3/4): All-1 is a stable equilibrium; Grim set also stable
- p < 2/3 (e.g. p=3/5): All-1 is unstable; only Grim set is stable

---

## 10. Key Differences from Original Paper

| Aspect                     | Original paper (All-M)              | This project (All-M/2)                         |
|----------------------------|-------------------------------------|------------------------------------------------|
| Cooperator strategy        | Always play ρ_M                     | Always play ρ_{M/2}                            |
| C(1,1) = C(1,3) = C(3,1)  | T·M (all equal)                     | C(1,1)=T·k, C(1,3)≠C(3,1)≠T·k                |
| C(3,3)                     | T·M                                 | T·M (same — Grim vs Grim never triggers)       |
| Grim trigger vs cooperator | Never (M not < M)                   | Always (M/2 < M)                               |
| s₂=0 face absorbing?       | Yes (entire face)                   | No — All-M/2 switches to Grim on this face     |
| True absorbing states      | (0,N,0) + entire s₂=0 face         | Only the 3 pure states (N,0,0),(0,N,0),(0,0,N) |
| Grim self-play payoff      | T·M = 40                            | T·M = 40 (unchanged)                           |
| All-M/2 self-play payoff   | T·M = 40                            | T·(M/2) = 20                                   |

---

## 11. References

I. Lazaridis and A. Kehagias, *Iterated Symmetric Centipede: Learning and Evolutionary Games*, March 2026.
