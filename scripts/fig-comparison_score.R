library(emcAdr)
library(dplyr)
library(dbscan)
library(ggplot2)
library(umap)
library(stringr)

load("figures/datasets/PRC_without_computation.RData")

Metrics_computation_size2_1M_count$omega_025[Metrics_computation_size2_1M_count$omega_025 <= -2e+09] <- -4
zero_score <- Metrics_computation_size2_1M_count[Metrics_computation_size2_1M_count$RR == 0, ]
non_zero_score <- Metrics_computation_size2_1M_count[Metrics_computation_size2_1M_count$RR != 0, ]
set.seed(42)

zero_score_sample <- zero_score[sample(nrow(zero_score), size = 0.05 * nrow(zero_score)), ]
reduced_data <- rbind(non_zero_score, zero_score_sample)

ggplot(reduced_data, aes(x = RR, y = as.factor(Label), color = as.factor(Label))) +
  geom_jitter(width = 0, height = 0.1, size = 2, alpha = 0.7) +
  scale_color_manual(values = c("red", "limegreen")) +
  labs(
    title = "RR by Label",
    x = "RR",
    y = "Label",
    color = "Label"
  ) +
  theme_minimal(base_size = 16) +
  theme(
    plot.title = element_text(size = 20, hjust = 0.5),
    axis.title = element_text(size = 16),
    axis.text = element_text(size = 14),
    legend.title = element_text(size = 16),
    legend.text = element_text(size = 14),
    legend.position = "right"
  )

ggplot(reduced_data, aes(x = phyper, y = as.factor(Label), color = as.factor(Label))) +
  geom_jitter(width = 0, height = 0.1, size = 2, alpha = 0.7) +
  scale_color_manual(values = c("red", "limegreen")) +
  labs(
    title = "Hypergeometric Score by Label",
    x = "phyper",
    y = "Label",
    color = "Label"
  ) +
  theme_minimal(base_size = 16) +
  theme(
    plot.title = element_text(size = 20, hjust = 0.5),
    axis.title = element_text(size = 16),
    axis.text = element_text(size = 14),
    legend.title = element_text(size = 16),
    legend.text = element_text(size = 14),
    legend.position = "right"
  )

ggplot(reduced_data, aes(x = CSS, y = as.factor(Label), color = as.factor(Label))) +
  geom_jitter(width = 0, height = 0.1, size = 2, alpha = 0.7) +
  scale_color_manual(values = c("red", "limegreen")) +
  labs(
    title = "CSS by Label",
    x = "CSS",
    y = "Label",
    color = "Label"
  ) +
  theme_minimal(base_size = 16) +
  theme(
    plot.title = element_text(size = 20, hjust = 0.5),
    axis.title = element_text(size = 16),
    axis.text = element_text(size = 14),
    legend.title = element_text(size = 16),
    legend.text = element_text(size = 14),
    legend.position = "right"
  )

ggplot(reduced_data, aes(x = omega_025, y = as.factor(Label), color = as.factor(Label))) +
  geom_jitter(width = 0, height = 0.1, size = 2, alpha = 0.7) +
  scale_color_manual(values = c("red", "limegreen")) +
  labs(
    title = "Omega Shrinkage by Label",
    x = expression(Omega[025]),
    y = "Label",
    color = "Label"
  ) +
  theme_minimal(base_size = 16) +
  theme(
    plot.title = element_text(size = 20, hjust = 0.5),
    axis.title = element_text(size = 16),
    axis.text = element_text(size = 14),
    legend.title = element_text(size = 16),
    legend.text = element_text(size = 14),
    legend.position = "right"
  )

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


single_pr_point <- data.frame(
  recall = recall_single,
  precision = precision_single,
  Curve = "PRR"
)

combined_pr_data_with_point <- bind_rows(
  combined_pr_data,
  single_pr_point
)

ggplot(combined_pr_data_with_point, aes(x = recall, y = precision, color = Curve, linetype = Curve)) +
  geom_line(data = combined_pr_data, linewidth = 1.1) +
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
