library(emcAdr)
library(dplyr)
library(dbscan)
library(ggplot2)
library(umap)

load("figures/datasets/plot_genetic_FAERS.RData")

distribution_list <- list(drugs_distribution_myopathy,
                          aprox_distribution_size2_5Mstep,
                          aprox_distribution_size3_Myopathy_13Mstep,
                          aprox_distribution_size4_20Mstep,
                          aprox_distribution_size5_25Mstep,
                          aprox_distribution_size6_30Mstep)

file.copy("./figures/datasets/solutions_myopathy.csv",
          "./figures/datasets/tmp_copy_solutions_myopathy.csv")

p_value_csv_file(distribution_list,
                 "figures/datasets/tmp_copy_solutions_myopathy.csv")


df_results_genetic_algorithm <- read.csv("figures/datasets/tmp_copy_solutions_myopathy.csv", sep=";")

file.remove("./figures/datasets/tmp_copy_solutions_myopathy.csv")

threshold <- .05

df_results_genetic_algorithm_signif <- df_results_genetic_algorithm %>%
  filter(!is.na(p_value), p_value <= threshold, n.patient.taking.C > 4)

df_results_genetic_algorithm_signif$cocktail_index <-
  string_list_to_int_cocktails(ATC_name = ATC_Tree_UpperBound_2024$Name,
                               lines = df_results_genetic_algorithm_signif$Cocktail)


# Compute the dissimilarity for the clust
dissimilarity <- get_dissimilarity_from_cocktail_list(df_results_genetic_algorithm_signif$cocktail_index,
                                                      ATC_Tree_UpperBound_2024)

# Set the UMAP config
umap_config <- umap.defaults
umap_config$random_state <- 42
umap_config$input <- "dist"
umap_config$min_dist <- .01
umap_config$n_neighbors <- 8

umap_results <- umap(do.call(rbind, as.matrix(dissimilarity)), config = umap_config)

df_results_genetic_algorithm_signif$X <- umap_results$layout[,1]
df_results_genetic_algorithm_signif$Y <- umap_results$layout[,2]

# Set up the dbscan config
dbscan_results <- dbscan(umap_results$layout, eps= 1.2)
df_results_genetic_algorithm_signif$cluster <- dbscan_results$cluster

# Plot final results
ggplot(df_results_genetic_algorithm_signif, aes(
  x = X,
  y = Y,
  color = factor(cluster)
)) +
  geom_point(size = .8) +
  labs(
    title = "Clustered Points with DBSCAN used on UMAP projection",
    x = "UMAP1",
    y = "UMAP2",
    color = "DBSCAN Cluster"
  ) +
  guides(size = "none") +
  theme_minimal() +
  theme(
    plot.title = element_text(size = 12, hjust = 0.5),
    axis.text = element_text(size = 9),
    axis.title = element_text(size = 10),
    legend.text = element_text(size = 8),
    legend.key.height= unit(0.35, 'cm')
  )
