
# Packages ----------------------------------------------------------------
library(terra)
library(dplyr)


# Coordinates -------------------------------------------------------------
coords <- read.csv("coords.csv")
rasters <- list.files("D:/Rasters/clim_data", pattern = "\\.tif$", full.names = TRUE)
stk <- rast(rasters)


# Extract values ----------------------------------------------------------
pts <- vect(coords[, c("LON", "LAT")], 
            geom = c("LON", "LAT"),
            crs = crs(stk))

vals <- extract(stk, pts)
res <- cbind(coords["env"], vals[, -1])  # remove ID column


# Save --------------------------------------------------------------------
write.csv(res, "bioclim.csv", 
          row.names = FALSE)
