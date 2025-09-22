library(emcAdr)
library(ggplot2)
library(cowplot)

load("../datasets/Figure2.RData")

# Here is how the `Metrics_computation_size2_1M_count`is computed, since it takes 
# time. We pre-computed it in order to use it directly for plots. 
Metrics_computation_size2_1M_count <- computeMetrics(total_population_dataset_2_3_1M_corigee,
                                                              ATC_Tree_UpperBound_2014,
                                                              simulPatient_2_3medic_realistic,
                                                              num_thread = 24) 


# Create the red/green plot showing the signal status for each score (Figure 2)##
# There are a lot of point, in order to facilitate the computation of the plot ##
# we can reduce the number of 0 since it does not impact the plot              ##
Metrics_computation_size2_1M_count$omega_025[Metrics_computation_size2_1M_count$omega_025 <= -2+09] <- -4
zero_score <- Metrics_computation_size2_1M_count[Metrics_computation_size2_1M_count$RR == 0, ]
non_zero_score <- Metrics_computation_size2_1M_count[Metrics_computation_size2_1M_count$RR != 0, ]
set.seed(42)

# We keep approximately 10% of zero score
zero_score_sample <- zero_score[sample(nrow(zero_score), size = 0.1 * nrow(zero_score)), ]
reduced_data <- rbind(non_zero_score, zero_score_sample)


ggplot(reduced_data, aes(x = phyper, y = as.factor(Label), color = as.factor(Label))) +
  geom_jitter(width = 0, height = 0.1, size = 2, alpha = 0.7) +
  scale_color_manual(values = c("red", "limegreen")) +
  labs(title = "phyper by Label", x = "phyper", y = "Label", color = "Label") +
  theme_minimal()
# In order to have each subfigure you have to replace x axis of the ggplot command 
# with the desired score  available score : ("RR", "phyper", "PRR", "CSS", "omega_025")


################# Now create the AUROC curves ##################################
custom_pr_curve <- function(data, truth_col, score_col) {
  data <- data[order(data[[score_col]], decreasing = TRUE), ]
  
  is_positive <- data[[truth_col]] == 1
  
  cum_true_positives <- cumsum(is_positive)
  cum_false_positives <- cumsum(!is_positive)
  
  total_positives <- sum(is_positive)
  
  precision <- cum_true_positives / (cum_true_positives + cum_false_positives)
  recall <- cum_true_positives / total_positives
  
  thresholds <- data[[score_col]]
  
  pr_data <- data.frame(
    threshold = thresholds,
    precision = precision,
    recall = recall
  )
  
  return(pr_data)
}

pr_curves <- list()
pr_curves$RR <- custom_pr_curve(Metrics_computation_size2_1M_count, "Label", "RR")
pr_curves$phyper <- custom_pr_curve(Metrics_computation_size2_1M_count, "Label", "phyper")
pr_curves$CSS <- custom_pr_curve(Metrics_computation_size2_1M_count, "Label", "CSS")
pr_curves$omega_025 <- custom_pr_curve(Metrics_computation_size2_1M_count, "Label", "omega_025")
pr_curves_list <- lapply(seq_along(pr_curves), function(i) {
  pr_curves[[i]] %>%
    mutate(Curve = paste(names(pr_curves)[i]))
})
combined_pr_data <- bind_rows(pr_curves_list)

### For the PRR since it has only a single threshold
true_positives <- sum(Metrics_computation_size2_1M_count$Label == 1 & Metrics_computation_size2_1M_count$PRR == 1)
false_positives <- sum(Metrics_computation_size2_1M_count$Label == 0 & Metrics_computation_size2_1M_count$PRR == 1)
total_positives <- sum(Metrics_computation_size2_1M_count$Label == 1)
precision_single <- true_positives / (true_positives + false_positives)
recall_single <- true_positives / total_positives

# Create a data frame for the single point with a name
single_pr_point <- data.frame(
  recall = recall_single,
  precision = precision_single,
  Curve = "PRR"
)

combined_pr_data_with_point <- bind_rows(
  combined_pr_data,
  single_pr_point
)
################################# And plot them ################################
ggplot(combined_pr_data_with_point, aes(x = recall, y = precision, color = Curve, linetype = Curve)) +
  geom_line(data = combined_pr_data, size = 1.1) +
  geom_point(data = single_pr_point, size = 6, shape = 17) +
  labs(title = "Precision-Recall Curves for Cocktail Score",
       x = "Recall",
       y = "Precision",
       color = "Score",
       linetype = "Score") +
  theme_minimal() +
  guides(
    color = guide_legend(keywidth = unit(1, "lines"), keyheight = unit(0.8, "lines")),
    linetype = guide_legend(keywidth = unit(1, "lines"), keyheight = unit(0.8, "lines"))
  )
