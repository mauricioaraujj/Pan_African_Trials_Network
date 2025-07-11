
# Packages ----------------------------------------------------------------
library(asreml)
library(dplyr)
library(ggplot2)



# Data --------------------------------------------------------------------

data <- read.csv("data.csv", header = TRUE, sep = ";")
data <- transform(data, 
                  gen = as.factor(gen),
                  env = as.factor(env),
                  rep = as.factor(rep))



# eBLUE + Plot -------------------------------------------------------------------

blue_list <- list()
for (e in unique(data$env)) {
  
  d_env <- filter(data, env == e)
  
  mod <- asreml(
    fixed = GY ~ rep + gen,
    data = d_env,
    na.action = na.method(x = "include", y = "include")
  )
  
  blue <- predict(mod, classify = "gen")$pvals
  blue$env <- e
  blue_list[[e]] <- blue
  

  resid <- residuals(mod, type = "pearson")
  qqnorm(resid, main = paste("Q-Q Plot -", e))
  qqline(resid)
}


blue_df <- bind_rows(blue_list)
head(blue_df)
