# Evolutionary Dynamics of the Iterated Symmetric Centipede

Course project for **Game Theory** (ECE, Aristotle University of Thessaloniki, 2026). It is an evolutionary game-theoretic study of the **Iterated Symmetric Centipede (ISC)**, building on Lazaridis & Kehagias, *Iterated Symmetric Centipede: Learning and Evolutionary Games* (2026).

The ISC is $T$ repeated rounds of a Centipede game of length $M$, with the first mover chosen at random each round. Strategies with memory (such as Grim Trigger) compete against simple ones (always cooperate to stage $k$, always defect at stage 1). The project asks which strategies survive under two kinds of evolution:

- **Replicator dynamics:** an infinite population, modelled as ODEs on the strategy simplex.
- **Markov chain dynamics:** a finite population of size $N$ that updates by pairwise proportional imitation.

📄 **Final report:** [`finalGT/finalGT.pdf`](finalGT/finalGT.pdf) · **Slides:** [`Presentation/presentation.pdf`](Presentation/presentation.pdf)

## Variations studied

| # | Variation | Folder |
|---|---|---|
| 1 | Replace All-$M$ with **All-$M/2$**; simulate the co-evolution with All-1 and Grim (replicator and Markov) | [`deliverable2/`](deliverable2/) |
| 2 | Analytical treatment of the same 3-strategy game: Nash equilibria, stability, ESS | [`deliverable3/`](deliverable3/) |
| 3 | **Five strategies:** All-$M$, All-1, Grim, Grim-Patient, Grim-Forgiver | [`deliverable4/`](deliverable4/) |
| 4 | **Two populations** playing only against each other | [`deliverable5/`](deliverable5/) |

**Main findings** (from the final report):
- A threshold $p^* = 2/3$ on the payoff parameter decides whether the all-defect state is stable.
- Grim and similar trigger strategies dominate in cooperative regimes.
- The five-strategy and two-population versions produce equilibrium structures that don't appear in the original three-strategy game.

## Repository layout

```
deliverable2/   Variation 1: MATLAB code, figures, report
deliverable3/   Variation 2: analytical report (+ code)
deliverable4/   Variation 3: 5-strategy simulations (pentagon phase plots, Markov chains)
deliverable5/   Variation 4: two-population model (code/ISC2pop, report)
finalGT/        Final combined report (LaTeX source + PDF)
Presentation/   Slides (LaTeX source + PDF)
EvoCenti.md     Structured summary of the source paper used to plan the work
```

## Running the code

Everything runs in **MATLAB**. Run each script from its own folder:

| Variation | Replicator dynamics | Markov dynamics |
|---|---|---|
| 1 | `deliverable2/xRep001.m` | `deliverable2/xMark001.m` |
| 3 | `deliverable4/Code/run_simulation_final.m` | `deliverable4/Code/run_markov_analysis.m` |
| 4 | `deliverable5/code/ISC2pop/xRep2pop001.m` | `deliverable5/code/ISC2pop/xMark2pop001.m` |

Parameters (number of stages $M$, rounds $T$, payoff parameter $p$, population size $N$) are set at the top of each script. To rebuild the reports, compile the `.tex` files with `pdflatex`.
