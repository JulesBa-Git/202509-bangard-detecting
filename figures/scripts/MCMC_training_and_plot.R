library(emcAdr)
library(ggplot2)
library(gridExtra)

# To illustrate we estimate the distribution of size 1 cocktails (drug) with Smax = 1
# nbResults = 200 says to the algorithm that top 200 encountered cocktails 
# during the MCMC run are kept in memory (according to the hypegeometric score).
# In the publication the length of the random walk was much larger than 60k, 
# it depends of the cocktail size distribution that we are approximating but 
# for size 2 it was around 5 millions steps.
estimated_distribution <-
  DistributionApproximation(60000,
                           ATC_Tree_UpperBound_2024, FAERS_myopathy,
                           temperature = 500, nbResults = 200,
                           Smax = 1,num_thread = 8)

# Now in order to compare our estimated distribution, we will compute the 
# true distribution for the same size of cocktails (1) in order to compare them
# This is possible only for size 1 and 2 since the computation cost is high due
# to the combinatorics.
true_distribution_size1 <- trueDistributionDrugs(ATC_Tree_UpperBound_2024, 
                                                 FAERS_myopathy, beta = 4,
                                                 num_thread = 8)

# Now we might want to compare both distribution, let's start by having a look 
# at both distribution.
plot_estimated_distribution <- plot_frequency(
  estimated_distribution$Filtered_score_distribution[2:length(estimated_distribution$Filtered_score_distribution)],
  binwidth = .3, sqrt = F, xlab = "H(C)") + 
  labs(title = "Estimated distribution of risks among size 1 cocktails") +
  theme(plot.title = element_text(size=20)) + ylim(c(0,0.35)) + xlim(c(0,30))

plot_true_distribution <- plot_frequency(
  true_distribution_size1$Filtered_score_distribution[2:length(true_distribution_size1$Filtered_score_distribution)],
  binwidth = .3, xlab = "H(C)") + 
  labs(title = "True Distribution of Risks among size 1 cocktails") +
  theme(plot.title = element_text(size=20)) + ylim(c(0,0.35)) + xlim(c(0,30))

# Here is how to reproduce the left part of Figure 3 and 5. Here the dataset is the one used to 
# draw the Figure 5.
grid.arrange(plot_estimated_distribution, plot_true_distribution ,nrow = 2)

# Now we reproduce the quantile-quantile plot and probability-probability plot
# on the right side of figure 3 and 5.

qq_plot_output(estimated_distribution,
               true_distribution_size1, filtered = T)

# There's no PP-plot function at the time, we have to do it by hand 
estimated_data <- histogramToDitribution(estimated_distribution$Filtered_score_distribution[2:length(estimated_distribution$Filtered_score_distribution)])
true_data <- histogramToDitribution(true_distribution_size1$Filtered_score_distribution[2:length(true_distribution_size1$Filtered_score_distribution)])

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
       title = "PP Plot of Estimated vs True Distribution")
pp_plot

