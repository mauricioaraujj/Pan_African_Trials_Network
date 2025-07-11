
# Packages ----------------------------------------------------------------
library(dplyr)
library(tidyr)
library(tibble)
library(ComplexHeatmap)
library(circlize)
library(grid)
library(RColorBrewer)


# Data --------------------------------------------------------------------
data <- read_delim("data.csv", 
                   delim = ";", 
                   escape_double = FALSE, 
                   trim_ws = TRUE)

data <- data %>% mutate(across(c(COUNTRY, YEAR, gen, env), as.factor))
env_info <- data %>%
  distinct(env, COUNTRY, YEAR) %>%
  arrange(as.numeric(as.character(YEAR)), env)

env_order <- env_info$env


# GxE matrix --------------------------------------------------------------
connectivity <- data %>%
  distinct(gen, env) %>%
  mutate(presence = 1) %>%
  pivot_wider(names_from = env, values_from = presence, values_fill = 0) %>%
  column_to_rownames("gen") %>%
  as.matrix()

connectivity <- connectivity[, env_order]
env_info <- env_info %>% column_to_rownames("env")
env_info <- env_info[colnames(connectivity), ]
years <- sort(unique(as.character(env_info$YEAR)))
year_colors <- setNames(brewer.pal(n = length(years), name = "Set3"), years)
country_colors <- setNames(rainbow(length(unique(env_info$COUNTRY))), unique(env_info$COUNTRY))
col_anno <- HeatmapAnnotation(COUNTRY = env_info$COUNTRY, YEAR = env_info$YEAR, col = list(COUNTRY = country_colors, YEAR = year_colors), annotation_name_side = "left")
gen_info <- rowSums(connectivity)

row_anno <- rowAnnotation(
  Total_Envs = anno_barplot(gen_info, gp = gpar(fill = "#2ca25f"), width = unit(2, "cm")),
  annotation_name_rot = 0
)

# Heatmap -----------------------------------------------------------------
rs <- Heatmap(
  connectivity,
  name = "Presence",
  col = c("0" = "white", "1" = "#238b45"),
  top_annotation = col_anno,
  right_annotation = row_anno,
  cluster_rows = FALSE,
  cluster_columns = FALSE,
  show_row_names = FALSE,
  show_column_names = FALSE,
  column_split = env_info$YEAR,
  column_gap = unit(6, "mm"),  
  border = TRUE,
  heatmap_legend_param = list(
    title = "Presence",
    at = c(0, 1),
    labels = c("Absent", "Present")
  ),
  column_title_gp = gpar(fontsize = 10, fontface = "bold")  
) 
draw(ht, heatmap_legend_side = "right", annotation_legend_side = "right", merge_legend = TRUE)
grid.text("Genotypes", x = unit(0.01, "npc"), y = unit(0.5, "npc"), rot = 90,
          gp = gpar(fontsize = 12, fontface = "bold"))
grid.text("Environments", x = unit(0.5, "npc"), y = unit(0.02, "npc"),
          gp = gpar(fontsize = 12, fontface = "bold"))

print(rs)

dev.off()

















