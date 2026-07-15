# Scripts to reproduce the article's figures

All R code used to build the figures of the article lives in this folder. It contains **two kinds of files** that serve different purposes; they are intentionally kept separate.

All scripts assume the working directory is the **root of the project** (one level above this folder), so that the relative paths to `figures/datasets/` resolve correctly. The pre-computed datasets used by the figure-rendering scripts are stored in `figures/datasets/`.

## Figure-rendering scripts (`fig-*.R`)

These files are the source of truth for the figures shown in the article. They are pulled into `published-202605-bangard-adverse.qmd` so that the same code that renders the figure in the paper can also be replayed on its own:

```r
# from the project root
source("scripts/fig-comparison_score.R")   # Figure 2
source("scripts/fig-distri_simu.R")        # Figure 3
source("scripts/fig-cluster_simu.R")       # Figure 4
source("scripts/fig-qqplot_FAERS.R")       # Figure 5
source("scripts/fig-cluster_FAERS.R")      # Figure 7
```

Each script loads the pre-computed `*.RData` file in `figures/datasets/` that holds the inputs needed to redraw the figure, so they run in seconds and require no heavy computation.

## Reproducibility templates (other files in this folder)

The remaining files are example templates intended to be adapted to the reader's own data, in order to reproduce the article's results from scratch (i.e. starting from raw patient data rather than from the pre-computed `*.RData`). They embed the heavy computational steps that are not re-run on every Quarto build of the paper. They are not part of the document include chain, (modifying them does not change the article) but they document end-to-end how the inputs to the figure-rendering scripts above were obtained.

### Figure 2 — Computation of the score for each metric

The script `score_comparison_AUROC.R` shows how to compute the `Metrics_computation_size2_1M_count` table used by `fig-comparison_score.R`. The first call (`computeMetrics(...)`) is resource-intensive: a pre-computed version of the result is shipped as `figures/datasets/PRC_without_computation.RData`, and the in-paper figure uses this cached version. Users may skip the first line of the script if they only want to redraw the plots. The line is kept for transparency.

### Figures 3 and 5 — Comparison of estimated and true risk distributions

The script `MCMC_training_and_plot.R` shows how to obtain the estimated and true distributions plotted on the left/right panels of Figures 3 and 5. It uses the `FAERS_myopathy` dataset shipped with the `emcAdr` package. To keep the runtime manageable, the example estimates the distribution for cocktails of size 1 (the paper estimates sizes 2 and 3, with longer MCMC chains: around 5 million steps for size 2).

### Figures 4 and 7 — Identification and clustering of high-risk drug cocktails

Reproducing the genetic-algorithm results that feed Figures 4 and 7 is a four-step pipeline:

1. **Generate the per-experiment R scripts**

   ```bash
   ./scripts/create_fich.sh "100,250,500,1000,5000,7500"
   ```

   The argument is a comma-separated list of values for the number of genetic-algorithm epochs. One sub-folder is created per value, containing an R script and an sbatch wrapper.

2. **Launch the simulations**

   ```bash
   ./scripts/launch_simu.sh
   ```

   This dispatches every generated script through `sbatch`. The scripts assume a Slurm cluster, if you use a different scheduler, edit line 22 of `launch_simu.sh` accordingly.

3. **Aggregate the `.txt` outputs**

   Once all simulations have finished, `regroup_txt_results.R` aggregates the per-run `.txt` files into a single `solutions.csv`.

4. **Cluster and plot**

   `genetic_algorithm_clustering_and_plot.R` computes empirical p-values, clusters the significant cocktails via UMAP + DBSCAN, and produces the corresponding figures. A pre-computed `solutions` file is shipped at `figures/datasets/solutions_simu_no_p_value.csv` so the clustering step can be reproduced without rerunning the genetic algorithm. To replay everything from the new `solutions.csv` produced by step 3, replace the file names on lines 14 and 16 of the script with `solutions.csv`.
