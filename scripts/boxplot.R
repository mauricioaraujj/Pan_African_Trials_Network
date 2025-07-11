
# Packages ----------------------------------------------------------------
library(asreml)
library(readr)
library(dplyr)
library(tidyr)
library(ggplot2)
library(patchwork)
library(ComplexHeatmap)


# Data --------------------------------------------------------------------
data <- read_delim("data.csv", 
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



# Traits ------------------------------------------------------------------

traits <- c("LOD", "NDM", "PH_R8", "W100G", "GY", "PROT", "OIL")

data_filtered <- data
for (trait in traits) {
  data_filtered <- remove_outliers(data_filtered, trait)
}



# eBLUE -------------------------------------------------------------------
get_eblue_by_env <- function(env_id, trait) {
  df_env <- filter(data_filtered, env == env_id)
  
  form_fixed <- as.formula(paste(trait, "~ gen + rep"))
  
  mod <- asreml(
    fixed = form_fixed,
    data = df_env,
    trace = FALSE
  )
  
  pred <- predict(mod, classify = "gen", vcov = TRUE)
  
  df_eblue <- pred$pvals[, c("gen", "predicted.value")]
  df_eblue$env <- env_id
  df_eblue$trait <- trait
  df_eblue$RAINFED <- unique(df_env$RAINFED)
  names(df_eblue)[2] <- "eBLUE"
  return(df_eblue)
}

env_ids <- unique(data_filtered$env)
eblue_all <- list()

for (trait in traits) {
  for (env_id in env_ids) {
    try({
      res <- get_eblue_by_env(env_id, trait)
      eblue_all[[length(eblue_all) + 1]] <- res
    }, silent = TRUE)
  }
}


eblue_df <- do.call(rbind, eblue_all)
saveRDS(box, "box.RData")

trait_order <- c("NDM", "LOD", "PH_R8", "W100G", "GY", "PROT", "OIL")
eblue_df$trait <- factor(eblue_df$trait, levels = trait_order)
 
box <- ggplot(eblue_df, aes(x = "", y = eBLUE, fill = trait)) +
  geom_boxplot(
    color = "black",
    outlier.shape = NA,
    width = 0.6,
    alpha = 0.9
  ) +
  facet_wrap(~trait, scales = "free_y", ncol = 7) +
  scale_fill_brewer(palette = "Set2") +
  labs(
    x = NULL,
    y = "eBLUE"
  ) +
  theme_gray(base_size = 14) +
  theme(
    strip.text = element_text(face = "bold", size = 13),
    axis.text.x = element_blank(),
    axis.ticks.x = element_blank(),
    legend.position = "none",
    panel.spacing = unit(1, "lines"),  
    plot.title = element_text(face = "bold", size = 16, hjust = 0.5)
  )

print(box)
