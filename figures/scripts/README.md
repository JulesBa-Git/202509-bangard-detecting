# Scripts to Reproduce Figures from the Article

This repository contains the scripts used to reproduce the figures presented in the article. Below we describe how to run them.

## Figure 2: Computation of the Score for Each Metric

The script for comparing different metrics is available at:\
`scripts/score_comparison_AUROC.R`

The scores are **pre-computed** because the calculations are resource-intensive. Users may skip the first line of the script if they only wish to generate the plots. This line is included for transparency, so readers can see how the scores were originally obtained.

## Figures 3 and 5: Comparison of Estimated and True Distributions

The computations are performed in:\
`figures/MCMC_training_and_plot.R`

In this script, we use the `FAERS_myopathy` dataset (described in Section 2.5.2 of the article). To reduce computation time, we estimate the distribution for cocktails of size 1.

## Figures 4 and 7: Identification of High-Risk Drug Cocktails

The genetic algorithm must first be launched. To replicate the article’s settings, we provide two helper scripts:

1.  **`scripts/create_fich.sh`**\
    This script generates multiple R scripts that can be run in parallel with different parameters. Run it from the terminal as a regular bash script.\
    The parameter is a list of the number of epochs for the genetic algorithm, enclosed in quotes and separated by commas.

    **Example (used to obtain the article results):**

    ``` bash
    ./create_fich.sh "100,250,500,1000,5000,7500"
    ```

2.  **`scripts/launch_simu.sh`** After the folders and scripts are created, run the simulations with:

    ``` bash
    ./launch_simu.sh
    ```

**Note:** These scripts assume the use of the **Slurm** cluster manager (`sbatch` is used to submit jobs). If you are not using Slurm, edit line 22 of `launch_simu.sh` to adapt it to your system.

### Post-processing

Once the simulations have finished, `.txt` files are generated containing the results of the genetic algorithm runs. To aggregate them, run: `scripts/regroup_txt_results.R`

This produces a `solutions.csv` file, which gathers all results from the genetic algorithm runs. You can then cluster and plot the results using: `scripts/genetic_algorithm_clustering_and_plot.R`

**Note:** A pre-computed version of this file is provided as: `datasets/solutions_simu_no_p_value.csv` If you want to recompute the results yourself, replace the file names on lines 14 and 16 of the script with `solutions.csv`.
