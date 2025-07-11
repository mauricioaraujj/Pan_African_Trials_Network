
# Packages ----------------------------------------------------------------
library(asreml)
library(readr)
library(dplyr)
library(tidyr)
library(ggplot2)
library(patchwork)
library(ComplexHeatmap)


# Data + Covamb -----------------------------------------------------------

data <- read_delim("data.csv", 
                   delim = ";", 
                   escape_double = FALSE, 
                   trim_ws = TRUE)

covamb <- read_delim("covamb.csv", 
                     delim = ";", 
                     escape_double = FALSE, 
                     trim_ws = TRUE)
data <- transform(data,
                  COUNTRY = as.factor(COUNTRY),
                  env     = as.factor(env),
                  SEASON  = as.factor(SEASON),
                  rep     = as.factor(rep),
                  gen     = as.factor(gen),
                  loc     = as.factor(loc),
                  RAINFED = as.factor(RAINFED),
                  YEAR    = as.factor(YEAR))


# eBLUE -------------------------------------------------------------------

get_mean_GY_by_env <- function(df) {
  mod <- asreml(fixed = GY ~ gen + rep, 
                data = df,
                na.action = na.method(x = "include", y = "include"))
                
    pred <- predict(mod, classify = "gen")
  mean(pred$pvals$predicted.value, na.rm = TRUE)
}

mean_df <- data %>%
  group_by(env) %>%
  summarise(
    mean_GY = get_mean_GY_by_env(cur_data()),
    RAINFED = first(RAINFED)  
  )

plot_df <- mean_df %>%
  left_join(covamb, by = "env")


# Elevation + MeanT + Yield -----------------------------------------------

ggplot(plot_df, aes(x = ALT, y = T2M, color = mean_GY, shape = RAINFED)) +
  geom_point(size = 3, alpha = 0.5) +  
  scale_color_gradientn(
    colours = c("", "#fc8d59", "red"),
    name = expression("GY ("*kg~ha^{-1}*")")
  ) +
  labs(
    x = "Altitude (m)",
    y = expression("Mean Temperature ("*degree*C*")"),
    shape = "Water regime"
  ) +
  theme_bw(base_size = 14) 








