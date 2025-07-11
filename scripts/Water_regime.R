
# Packages ----------------------------------------------------------------

library(asreml)
library(readr)
library(dplyr)
library(tidyr)
library(ggplot2)
library(RColorBrewer)
library(purrr)

# Data --------------------------------------------------------------------

data <- read_delim("data.csv", 
                   delim = ";", 
                   escape_double = FALSE, 
                   trim_ws = TRUE)


data <- transform(data,
                  COUNTRY = as.factor(COUNTRY),
                  env = as.factor(env),
                  SEASON = as.factor(SEASON),
                  rep = as.factor(rep),
                  gen = as.factor(gen),
                  loc = as.factor(loc),
                  RAINFED = as.factor(RAINFED),
                  YEAR = as.factor(YEAR))


num.env <- nlevels(data$env)
num.gen <- nlevels(data$gen)
num.year <- nlevels(data$YEAR)
num.loc <- nlevels(data$loc)
num.sea <- nlevels(data$SEASON)
num.coun <- nlevels(data$COUNTRY)

name.env <- levels(data$env)
name.gen <- levels(data$gen)
name.year <- levels(data$YEAR)
name.loc <- levels(data$loc)
name.sea <- levels(data$SEASON)



# eBLUE -------------------------------------------------------------------
data <- data %>%
  mutate(across(c(COUNTRY, env, 
                  SEASON, rep, 
                  gen, loc, 
                  RAINFED, YEAR), 
                  as.factor))

env_list <- unique(data_filtered$env)
get_eblue_by_env <- function(env_id) {
  df_env <- filter(data_filtered, env == env_id)
  
  mod <- asreml(fixed = GY ~ gen,
                random = ~ rep,
                data = df_env,
                trace = FALSE)
  
  pred <- predict(mod, classify = "gen", vcov = TRUE)
  df_eblue <- pred$pvals[, c("gen", "predicted.value")]
  df_eblue$env <- env_id
  df_eblue$RAINFED <- unique(df_env$RAINFED)
  df_eblue
}
eblues_all <- map_dfr(env_list, get_eblue_by_env)




# Plot --------------------------------------------------------------------

df_plot <- eblues_all %>%
  rename(value = predicted.value) %>%
  group_by(RAINFED, env) %>%
  summarise(value = mean(value), .groups = "drop") %>%
  arrange(RAINFED, value) %>%
  group_by(RAINFED) %>%
  mutate(
    env_id = row_number(),
    avg = mean(value)
  ) %>%
  ungroup()

df_lines <- df_plot %>%
  group_by(RAINFED) %>%
  summarise(
    start_x = min(env_id) - 1,
    end_x = max(env_id) + 1,
    y = unique(avg)
  ) %>%
  pivot_longer(c(start_x, end_x), names_to = "type", values_to = "x") %>%
  mutate(x_group = if_else(type == "start_x", x + 0.1, x - 0.1))



# Water regime ------------------------------------------------------------

rainfed_colors <- setNames(brewer.pal(3, "Set2"), sort(unique(df_plot$RAINFED)))

p <- ggplot(df_plot, aes(x = env_id, y = value, color = RAINFED)) +
  geom_hline(yintercept = seq(floor(min(df_plot$value)), ceiling(max(df_plot$value)), by = 500),
             color = "grey90", size = 0.3) +
  
  geom_segment(aes(xend = env_id, yend = avg), linewidth = 0.6, alpha = 0.5) +
  
  geom_line(data = df_lines,
            aes(x = x_group, y = y, group = RAINFED),
            linewidth = 2, alpha = 0.8) +
  
  geom_point(size = 2.2) +
  
  facet_grid(. ~ RAINFED, scales = "free_x", space = "free_x") +
  
  scale_color_manual(values = rainfed_colors) +
  
  labs(
    x = "Environment",
    y = expression("Grain yield (kg·ha"^{-1}*")"),
    title = ""
  ) +
  
  theme_minimal(base_family = "sans") +
  theme(
    panel.grid.major.x = element_blank(),
    axis.text.x = element_blank(),
    axis.title = element_text(size = 12),
    axis.text.y = element_text(size = 10),
    legend.position = "none",
    plot.title = element_text(face = "bold", size = 14, hjust = 0.5),
    strip.text = element_text(face = "bold", size = 12),
    strip.background = element_rect(fill = "grey90", color = NA),
    panel.background = element_rect(fill = "grey95", color = NA),
    panel.spacing = unit(1.2, "lines")
  )

print(p)











