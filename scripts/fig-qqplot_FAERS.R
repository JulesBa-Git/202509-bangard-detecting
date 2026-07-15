library(emcAdr)
library(ggplot2)
library(stringr)

load("figures/datasets/plot_MCMC_FAERS.RData")

plot_estimated_distribution <- plot_frequency(
  aprox_distribution_size2_5Mstep$Filtered_score_distribution[2:length(aprox_distribution_size2_5Mstep$Filtered_score_distribution)],
  binwidth = .40, sqrt = FALSE, xlab = "H(C)"
) +
  labs(title = "Estimated Distribution of Risk Among Size 2 Cocktails") +
  ylim(0, 0.20) +
  xlim(0, 80) +
  theme(
    plot.title = element_text(size = 15, hjust = .5),
    axis.text = element_text(size = 13)
  )
plot_estimated_distribution

# true Size 2
plot_true_distribution <- plot_frequency(
  true_distribution_myopathy_size2$Filtered_score_distribution[2:length(true_distribution_myopathy_size2$Filtered_score_distribution)],
  binwidth = .40, sqrt = FALSE, xlab = "H(C)"
) +
  labs(title = "True Distribution of Risk Among Size 2 Cocktails") +
  ylim(0, 0.20) +
  xlim(0, 80) +
  theme(
    plot.title = element_text(size = 15, hjust = .5),
    axis.text = element_text(size = 13)
  )


# QQ-plot size 2
qq_plot_output(aprox_distribution_size2_5Mstep,
               true_distribution_myopathy_size2, filtered = T) +
  labs(title = str_wrap("QQ Plot of Estimated vs True Distribution of Risk Among Size 2 Cocktail",50)) +
  theme(
    plot.title = element_text(size = 15, hjust = .5),
    axis.text = element_text(size = 13)
  )

plot_true_distribution

# PP-plot size 2

estimated_data <- histogramToDitribution(aprox_distribution_size2_5Mstep$Filtered_score_distribution[2:length(aprox_distribution_size2_5Mstep$Filtered_score_distribution)])
true_data <- histogramToDitribution(true_distribution_myopathy_size2$Filtered_score_distribution[2:length(true_distribution_myopathy_size2$Filtered_score_distribution)])

ecdf_estimated_data <- ecdf(estimated_data)
ecdf_true_data <- ecdf(true_data)

common_sorted_data <- sort(unique(c(estimated_data, true_data)))
cp_estimated_data <- ecdf_estimated_data(common_sorted_data)
cp_true_data <- ecdf_true_data(common_sorted_data)

pp_df <- data.frame(EmpiricalCP1 = cp_estimated_data, EmpiricalCP2 = cp_true_data)

pp_plot <- ggplot(pp_df, aes(x = EmpiricalCP1, y = EmpiricalCP2)) +
  geom_point(alpha = 0.5) +
  geom_abline(slope = 1, intercept = 0, linetype = "dashed", color = "red") +
  theme_minimal() +
  labs(x = "Cumulative Probabilities of Estimated Distribution",
       y = "Cumulative Probabilities of True Distribution",
       title = str_wrap("PP Plot of Estimated vs True Distribution of Risk Among Size 2 Cocktail",50)) +
  theme(
    plot.title = element_text(size = 15, hjust = .5),
    axis.text = element_text(size = 13)
  )
pp_plot
