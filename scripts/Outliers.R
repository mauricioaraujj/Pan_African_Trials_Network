
# Packages ----------------------------------------------------------------
library(ggplot2)
library(ggrepel)
library(ggExtra)
library(tibble)

if (!require("BiocManager", quietly = TRUE))
  install.packages("BiocManager")
BiocManager::install(version='devel')
BiocManager::install("multtest")


# Function ----------------------------------------------------------------

outlier <- function(resid, alpha = 0.05) {
  library(multtest)
  studresid <- resid / sd(resid, na.rm = TRUE)
  rawp.BHStud <- 2 * (1 - pnorm(abs(studresid)))
  test.BHStud <- mt.rawp2adjp(rawp.BHStud, proc = c("Holm"), alpha = alpha)
  adjp <- cbind(test.BHStud[[1]][, 1])
  bholm <- cbind(test.BHStud[[1]][, 2])
  index <- test.BHStud$index
  out_flag <- ifelse(bholm < alpha, "OUTLIER", ".")
  BHStud_test <- cbind(adjp, bholm, index, out_flag)
  BHStud_test2 <- BHStud_test[order(index), ]
  colnames(BHStud_test2) <- c("rawp", "bholm", "index", "out_flag")
  outliers_BH <- as.numeric(BHStud_test2[which(BHStud_test2[, "out_flag"] != "."), "index"])
  if (length(outliers_BH) < 1) cat("No outlier detected\n")
  if (length(outliers_BH) == 1) cat("1 outlier detected!\n")
  if (length(outliers_BH) > 1) cat(length(outliers_BH), "outliers detected!\n")
  return(outliers_BH)
}


# Outliers ----------------------------------------------------------------
data$index <- 1:nrow(data)
outlier_indices <- data %>%
  group_by(env) %>%
  group_map(~ {
    idx <- .x$index
    res <- .x$GY
    detected <- outlier(res)
    return(idx[detected])
  }) %>%
  unlist()

data_clean <- data %>%
  filter(!index %in% outlier_indices)

cat("Removed", length(outlier_indices), "outliers in total.\n")

write.csv(data_clean, "data.csv")