
# Packages ----------------------------------------------------------------
library(readr)
library(terra)
library(sf)
library(ggplot2)
library(rnaturalearth)
library(ggspatial)
library(dplyr)
library(RColorBrewer)
library(cowplot)


# Data --------------------------------------------------------------------
data <- read_delim("data.csv", delim = ";", escape_double = FALSE, trim_ws = TRUE)
data <- data %>%
  mutate(
    lat = as.numeric(gsub(",", ".", LAT)),
    lon = as.numeric(gsub(",", ".", LON))
  ) %>%
  filter(!is.na(lat), !is.na(lon))


# Rasters -----------------------------------------------------------------
sf_pts <- st_as_sf(data, coords = c("lon", "lat"), crs = 4326)


# African Biomes ----------------------------------------------------------
sf_bio <- st_read("Raster/Africa_Biomes_Dataset.shp") |> st_transform(crs = 4326)
sf_af <- ne_countries(scale = "medium", continent = "Africa", returnclass = "sf") |> st_transform(crs = 4326)
sf_af$ISO_A2 <- as.factor(sf_af$iso_a2)
sf_af_centroids <- st_centroid(sf_af)

# Paleta de cores dos biomas
sf_bio$ECO_NAME <- factor(sf_bio$ECO_NAME, levels = sort(unique(sf_bio$ECO_NAME)))
biome_colors <- RColorBrewer::brewer.pal(n = length(levels(sf_bio$ECO_NAME)), name = "Set3")



# Sites by Country --------------------------------------------------------
country_env <- tibble::tribble(
  ~COUNTRY,        ~num_env, ~ISO,
  "Malawi",        68,       "MW",
  "Zimbabwe",      42,       "ZW",
  "Kenya",         39,       "KE",
  "Zambia",        33,       "ZM",
  "Benin",         15,       "BJ",
  "Uganda",        12,       "UG",
  "Ethiopia",      11,       "ET",
  "Ghana",         11,       "GH",
  "Rwanda",        11,       "RW",
  "Mozambique",    10,       "MZ",
  "Cameroon",       9,       "CM",
  "Mali",           7,       "ML",
  "Nigeria",        7,       "NG",
  "South Sudan",    4,       "SS",
  "Senegal",        3,       "SN",
  "Somalia",        3,       "SO",
  "DRC",            2,       "CD",
  "Tanzania",       2,       "TZ",
  "Burkina Faso",   1,       "BF",
  "Namibia",        1,       "NA",
  "Togo",           1,       "TG"
)

sf_pts <- sf_pts %>% left_join(country_env, by = "COUNTRY")

map_plot <- ggplot() +
  geom_sf(data = sf_bio, aes(fill = ECO_NAME), color = NA, alpha = 0.85) +
  geom_sf(data = sf_af, fill = NA, color = "gray30", size = 0.3) +
  geom_sf(data = sf_pts, color = "black", size = 1.2) +
  geom_sf_text(data = sf_af_centroids, aes(label = ISO_A2),
               size = 2.3, fontface = "bold", color = "black") +
  annotation_scale(location = "bl", width_hint = 0.2, text_cex = 0.7) +
  annotation_north_arrow(location = "br", which_north = "true",
                         style = north_arrow_fancy_orienteering,
                         height = unit(1, "cm"), width = unit(1, "cm")) +
  scale_fill_manual(name = "Biomes", values = biome_colors,
                    guide = guide_legend(order = 1, override.aes = list(shape = 21, size = 4))) +
  coord_sf(xlim = c(-20, 60), ylim = c(-40, 40), expand = FALSE) +
  labs(title = "", x = "Longitude", y = "Latitude") +
  theme_minimal(base_size = 12) +
  theme(
    legend.position = "right",
    legend.title = element_text(size = 9, face = "bold"),
    legend.text = element_text(size = 9),
    legend.box = "vertical",
    panel.grid.major = element_line(color = "gray90"),
    legend.key = element_blank()
  )
legend_data <- country_env %>%
  group_by(num_env) %>%
  summarise(
    countries = paste0(COUNTRY, " (", ISO, ")"),
    .groups = "drop"
  ) %>%
  arrange(desc(num_env)) %>%
  mutate(label_text = paste0(countries, " – ", num_env))

legend_plot <- ggplot(legend_data, aes(x = 1, y = reorder(label_text, num_env))) +
  geom_point(aes(size = num_env), color = "black", fill = "black", shape = 21, stroke = 0.2) +
  geom_text(aes(label = label_text), hjust = -0.1, size = 3) +
  scale_size_continuous(range = c(2, 8)) +
  labs(title = "Number of Trials ") +
  theme_void() +
  theme(
    plot.title = element_text(hjust = 0, size = 11, face = "bold"),
    legend.position = "none"
  ) +
  xlim(0.9, 2)

final_plot <- cowplot::plot_grid(
  map_plot,
  legend_plot,
  rel_widths = c(2.5, 1),
  nrow = 1
)

print(final_plot)
ggsave("map_with_grouped_bubble_legend.pdf",
       final_plot, 
       width = 13,
       height = 8, 
       device = cairo_pdf)
