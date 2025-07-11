
# Packages ----------------------------------------------------------------

library(readr)
library(tidyverse)
library(dplyr)
library(raster)
library(tibble)
library(raster)
library(sp)
library(dplyr)
library(tools)

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

# Download of Soil Raster - SoilGrids (5, 15, 30 cm) --------------------------------

geodata::soil_world(var = 'bdod', depth = 60, stat = 'mean', path = 'Rasters')
geodata::soil_world(var = 'clay', depth = 60, stat = 'mean', path = 'Rasters')
geodata::soil_world(var = 'nitrogen', depth = 60, stat = 'mean', path = 'Rasters')
geodata::soil_world(var = 'phh2o', depth = 60, stat = 'mean', path = 'Rasters')
geodata::soil_world(var = 'sand', depth = 60, stat = 'mean', path = 'Rasters')
geodata::soil_world(var = 'silt', depth = 60, stat = 'mean', path = 'Rasters')
geodata::soil_world(var = 'soc', depth = 60, stat = 'mean', path = 'Rasters')
geodata::soil_world(var = 'cfvo', depth = 60, stat = 'mean', path = 'Rasters')
geodata::soil_world(var = 'ocd', depth = 60, stat = 'mean', path = 'Rasters')


# Environmental Soil data ------------------------------------------------------

soil_dir <- "C:/Users/mauri/OneDrive/Documentos/Scientific_data/soil"
soil_files <- list.files(soil_dir, pattern = "\\.tif$", full.names = TRUE)

coords <- data %>%
  dplyr::select(env, LAT, LON) %>%
  distinct(env, .keep_all = TRUE)

sp_points <- SpatialPoints(coords[, c("LON", "LAT")],
                           proj4string = CRS("+proj=longlat +datum=WGS84"))

soil_values <- tibble(env = coords$env)

for (raster_path in soil_files) {
  var_name <- file_path_sans_ext(basename(raster_path))  
  raster_layer <- raster(raster_path)
  extracted_vals <- extract(raster_layer, sp_points)
  soil_values[[var_name]] <- extracted_vals
}

write.csv(soil_values, "soil.csv", row.names = FALSE)
