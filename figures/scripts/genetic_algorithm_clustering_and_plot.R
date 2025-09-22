library(emcAdr)
library(dplyr)
library(dbscan)
library(ggplot2)
library(umap)

load("../datasets/clustering_genetic_algorithm.RData")

distribution_list <- list(aprox_distribution_size2_5Mstep_2_3med_t800,
                          aprox_distribution_size3_60Mstep_2_3med_t800)


p_value_csv_file(distribution_list,
                 "../datasets/solutions_simu_no_p_value.csv")

df_results_genetic_algorithm <- read.csv("../datasets/solutions_simu_no_p_value.csv", sep=";")

threshold <- .05

df_results_genetic_algorithm_signif <- df_results_genetic_algorithm %>%
  filter(!is.na(p_value), p_value <= threshold, n.patient.taking.C > 4)

df_results_genetic_algorithm_signif$cocktail_index <- 
  string_list_to_int_cocktails(ATC_name = ATC_Tree_UpperBound_2014$Name,
                               lines = df_results_genetic_algorithm_signif$Cocktail)

# We add the true signals of the simulated datasets in order to plot all cocktails
# after
empty_rows <- data.frame(matrix(NA,nrow=4,ncol=ncol(df_results_genetic_algorithm_signif)))
names(empty_rows) <- names(df_results_genetic_algorithm_signif)
df_results_genetic_algorithm_signif <- rbind(df_results_genetic_algorithm_signif, empty_rows)
df_results_genetic_algorithm_signif$cocktail_index[[(nrow(df_results_genetic_algorithm_signif)-3)]] <- c(47,1393,2199)
df_results_genetic_algorithm_signif$cocktail_index[[(nrow(df_results_genetic_algorithm_signif)-2)]] <- c(888,659,2338)
df_results_genetic_algorithm_signif$cocktail_index[[(nrow(df_results_genetic_algorithm_signif)-1)]] <- c(2590, 2740)
df_results_genetic_algorithm_signif$cocktail_index[[(nrow(df_results_genetic_algorithm_signif))]] <- c(919,3760)
df_results_genetic_algorithm_signif$true_cocktail <- 0
df_results_genetic_algorithm_signif$true_cocktail[(nrow(df_results_genetic_algorithm_signif)-3):(nrow(df_results_genetic_algorithm_signif))] <- 1


# Compute the dissimilarity for the clust
dissimilarity <- get_dissimilarity_from_cocktail_list(df_results_genetic_algorithm_signif$cocktail_index,
                                                      ATC_Tree_UpperBound_2014)

# Set the UMAP config
umap_config <- umap.defaults
umap_config$random_state <- 42
umap_config$input <- "dist"
umap_config$min_dist <- .001
umap_config$n_neighbors <- 15

umap_results <- umap(do.call(rbind, as.matrix(dissimilarity)), config = umap_config)

df_results_genetic_algorithm_signif$X <- umap_results$layout[,1]
df_results_genetic_algorithm_signif$Y <- umap_results$layout[,2]

# Set up the dbscan config
dbscan_results <- dbscan(umap_results$layout, eps= 2)
df_results_genetic_algorithm_signif$cluster <- dbscan_results$cluster

# Plot final results
ggplot(df_results_genetic_algorithm_signif, aes(x = X, y = Y, 
                                                color = factor(cluster), 
                                                shape = factor(true_cocktail),
                                                size  = factor(true_cocktail))) +
  geom_point(alpha = 0.8, stroke = 1.2) +
  scale_shape_manual(values = c("0" = 16, "1" = 0)) +  
  scale_size_manual(values = c("0" = 1, "1" = 4)) + 
  labs(color = "DBSCAN Cluster", shape = "True Signal") +
  guides(size = "none") + 
  theme_minimal()

