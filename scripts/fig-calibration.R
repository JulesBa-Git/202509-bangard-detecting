library(emcAdr)
library(ggplot2)

load("figures/datasets/simulated_dataset_2_3_med.RData")

H1_nodes <- matrix(c(2590, 2740,
                     919, 3760), nrow = 2, ncol = 2, byrow = TRUE)

# Generate cocktails of size 2 under H_1
# h1_nodes    : integer matrix, 2 cols; each row = a size-2 depth-4 solution (H1) pair
#               (node indices, 0-based)
# upper_bound : ATCtree$upperBound  (stores 0-based subtree-end indices;
#               R vector is 1-based, so converted as upper_bound[node + 1])
#
# Returns: integer matrix, 2 cols, each row a unique size-2 H1 cocktail (0-based).
generate_h1_cocktails <- function(h1_nodes, upper_bound) {
  ub <- function(node) upper_bound[node + 1L]

  pieces <- vector("list", nrow(h1_nodes))
  for (k in seq_len(nrow(h1_nodes))) {
    a <- h1_nodes[k, 1]; b <- h1_nodes[k, 2]
    sub_a <- seq.int(a, ub(a))
    sub_b <- seq.int(b, ub(b))
    g  <- expand.grid(x = sub_a, y = sub_b)
    g  <- g[g$x != g$y, , drop = FALSE]
    lo <- pmin(g$x, g$y); hi <- pmax(g$x, g$y)
    pieces[[k]] <- cbind(lo, hi)
  }

  all_pairs <- unique(do.call(rbind, pieces))
  storage.mode(all_pairs) <- "integer"

  lapply(seq_len(nrow(all_pairs)), function(i) all_pairs[i, ])
}

H1_cocktails <- generate_h1_cocktails(H1_nodes, ATC_Tree_UpperBound_2014$upperBound)

# Compute their score
scores_H1 <- compute_hypergeom_on_list(cocktails = H1_cocktails,
                                       ATCtree = ATC_Tree_UpperBound_2014,
                                       observations = simulPatient_2_3medic_realistic,
                                       num_thread = 8)
scores_H1 <- scores_H1[scores_H1 > 0]

# Convert them to nearest bin as MCMC bins are discretized to the first decimal :
bin_score_H_1 <- floor(scores_H1 * 10) / 10

# Retrieve only cocktail under H0 score : need to remove H_1 cocktails using a precision
# based function since equality can be ambiguous between floating points
H0_sample <- histogramToDitribution(true_dist_size2_2_3med$Distribution[-1]) + 0.1

remove_once_tol <- function(A, B, tol = 1e-8) {
  remove <- integer(0)

  for (b in B) {
    idx <- which(abs(A - b) <= tol & !(seq_along(A) %in% remove))[1]
    if (!is.na(idx)) {
      remove <- c(remove, idx)
    }
  }

  A[-remove]
}

H0_sample_cleaned <- remove_once_tol(H0_sample, bin_score_H_1)

# Compute the p-value of H_0 cocktails using the estimated distribution
compute_pvalues <- function(null_dist, observed_scores) {
  p_vals <- 1 - ecdf(null_dist)(observed_scores - 1e-9)
  return(p_vals)
}

score_distribution_hat <- histogramToDitribution(distribution_outputs_2_3_med[[1]]$Distribution[-1]) + 0.1

p_values_H0 <- compute_pvalues(score_distribution_hat, H0_sample_cleaned)
plot_data <- data.frame(p_value = p_values_H0)

# Plot the results
ggplot(plot_data, aes(x = p_value)) +
  geom_histogram(
    breaks = seq(0, 1, length.out = 13),
    fill = "steelblue",
    color = "white"
  ) +
  scale_x_continuous(
    breaks = seq(0, 1, by = 0.2),
    limits = c(0, 1)
  ) +
  labs(
    title = "Distribution of p-values under the null hypothesis",
    x = "Value",
    y = "Count"
  ) +
  theme_classic() +
  theme(
    plot.title = element_text(hjust = 0.5),
    axis.text = element_text(color = "black")
  )
