
# Packages ----------------------------------------------------------------
pkgs <- c("nasapower", "doParallel", "foreach", "plyr", "dplyr", "EnvRtype")
invisible(lapply(pkgs, function(pkg) {if (!requireNamespace(pkg, quietly = TRUE)) install.packages(pkg)
  library(pkg, character.only = TRUE)}))

library(EnvRtype)
library(readr)
library(raster)
library(EnvRtype)
library(dplyr)
library(readr)
library(purrr)
library(tidyr)
library(tidyverse)
library(dplyr)
library(tidyr)


# Function ----------------------------------------------------------------
get_weather <- function(env.id = NULL, lat = NULL, lon = NULL, start.year = NULL, 
                        end.year = NULL, variables.names = NULL, dir.path = NULL, 
                        save = FALSE, country = NULL, parallel = TRUE, 
                        workers = NULL, chunk_size = 29, sleep = 60) {
  
  get_helper <- function(lon, lat, variables.names, start.year, 
                         end.year, env.id, save) {
    tryCatch({
      CL <- data.frame(nasapower::get_power(community = "ag", 
                                            lonlat = c(lon, lat), 
                                            pars = variables.names, 
                                            dates = c(start.year, end.year), 
                                            temporal_api = 'monthly'))
      cor_rain_name <- which(names(CL) %in% "PRECTOTCORR")
      names(CL)[cor_rain_name] <- "PRECTOT"
      CL$env <- env.id
      CL <- CL[, c(which(colnames(CL) == "env"), which(colnames(CL) != "env"))]
      if (isTRUE(save)) {
        utils::write.csv(file = paste(env.id, ".csv", sep = ""), 
                         row.names = FALSE, x = CL)
      }
      return(CL)
    }, error = function(e) {
      message(paste("Error:", env.id, "-", conditionMessage(e)))
      return(NULL)
    })
  }
  
  sec_to_hms <- function(t) {
    paste(formatC(t %/% (60 * 60) %% 24, width = 2, format = "d", flag = "0"),
          formatC(t %/% 60 %% 60, width = 2, format = "d", flag = "0"),
          formatC(t %% 60, width = 2, format = "d", flag = "0"), sep = ":")
  }
  
  progress <- function(min = 0, max = 100, char = "=", width = getOption("width"), time = Sys.time()) {
    list(min = min, max = max, char = char, width = width, time = time)
  }
  
  run_progress <- function(pb, actual, text = "", digits = 0, sleep = 0) {
    Sys.sleep(sleep)
    elapsed <- sec_to_hms(as.numeric(difftime(Sys.time(), pb$time, units = "secs")))
    step <- round(actual / pb$max * (pb$width - 30))
    step <- max(step, 0)
    space <- max(pb$width - step - 30, 0)
    msg <- sprintf("%s [%s%s] %s%% (%s)", text,
                   strrep(pb$char, step), strrep(" ", space),
                   round(actual / pb$max * 100, digits), elapsed)
    cat(msg, "\r")
    if (actual == pb$max) cat("\n")
  }
  
  
  split_chunk <- function(vec, chunk_len) {
    split(vec, ceiling(seq_along(vec) / chunk_len))
  }
  
  cat("------------------------------------------------ \n")
  cat("ATTENTION: This function requires internet access \n")
  cat("------------------------------------------------  \n")
  cat("Connecting to the NASA POWER API Client, Sparks et al 2018 \n")
  cat("https://docs.ropensci.org/nasapower \n")
  cat("------------------------------------------------  \n")
  
  if (is.null(env.id)) env.id <- paste0("env", seq_along(lat))
  if (!(is.character(env.id) || is.factor(env.id))) stop("env.id should be characters or factors")
  if (is.null(dir.path)) dir.path <- getwd()
  if (is.null(variables.names)) {
    variables.names <- c("T2M", "T2M_MAX", "T2M_MIN", "PRECTOTCORR", 
                         "WS2M", "RH2M", "T2MDEW", "ALLSKY_SFC_LW_DWN", "ALLSKY_SFC_SW_DWN")
  }
  
  variables.names[grepl(variables.names, pattern = "PRECTOT")] <- "PRECTOTCORR"
  env.id <- as.factor(env.id)
  
  results <- list()
  if (!parallel) {
    pb <- progress(max = length(env.id))
    init_time <- Sys.time()
    iter <- 0
    for (i in seq_along(env.id)) {
      iter <- iter + 1
      if (iter >= 30 && as.numeric(difftime(Sys.time(), init_time, units = "secs")) > 60) {
        message("Waiting ", sleep, "s to avoid API blocking")
        Sys.sleep(sleep)
        iter <- 0
        init_time <- Sys.time()
      }
      results[[i]] <- get_helper(lon[i], lat[i], variables.names, start.year, end.year, env.id[i], save)
      run_progress(pb, actual = i, text = paste("Env", env.id[i]))
    }
  } else {
    env.id_par <- split_chunk(env.id, chunk_size)
    lat_par <- split_chunk(lat, chunk_size)
    lon_par <- split_chunk(lon, chunk_size)
    
    nworkers <- ifelse(is.null(workers), max(1, floor(parallel::detectCores() * 0.9)), workers)
    clust <- parallel::makeCluster(nworkers)
    on.exit(parallel::stopCluster(clust), add = TRUE)
    
    pb <- progress(max = length(env.id_par))
    
    for (i in seq_along(env.id_par)) {
      env.id_tmp <- env.id_par[[i]]
      lat_tmp <- lat_par[[i]]
      lon_tmp <- lon_par[[i]]
      
      parallel::clusterExport(clust, varlist = c("get_helper", "lat_tmp", "lon_tmp", 
                                                 "variables.names", "start.year", 
                                                 "end.year", "env.id_tmp"), envir = environment())
      temp <- parallel::parLapply(clust, seq_along(env.id_tmp), function(j) {
        get_helper(lon_tmp[j], lat_tmp[j], variables.names, start.year, end.year, env.id_tmp[j], save)
      })
      results[[i]] <- plyr::ldply(temp)
      run_progress(pb, actual = i, text = paste("Chunk", i, "/", length(env.id_par)))
      if (i < length(env.id_par)) {
        message("Waiting ", sleep, "s to avoid API overload")
        Sys.sleep(sleep)
      }
    }
    message("\n NASA POWER download completed!")
  }
  
  df <- plyr::ldply(results)
  return(df)
}




# Data --------------------------------------------------------------------

data <- read_delim("data.csv", delim = ";", 
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
                  YEAR = as.factor(YEAR)
)


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



# Coords ------------------------------------------------------------------
points_df <- unique(data[, c('env', 'LAT', 'LON', 'SOWING', 'HARVEST')])
write.csv(points_df, "points_df.csv")
points_df$SOWING  <- format(as.Date(points_df$SOWING), "%Y-%m-%d")
points_df$HARVEST <- format(as.Date(points_df$HARVEST), "%Y-%m-%d")
coords <- points_df[, c('env', 'LAT', 'LON', 'SOWING', 'HARVEST')]
coords <- read.table("coords2.txt", sep = "", header = TRUE)
covamb_raw <- get_weather(env.id = coords$env, 
                          lat = coords$LAT,
                          lon = coords$LON,
                          start.year = coords$SOWING,
                          end.year = coords$HARVEST,
                          parallel = TRUE,
                          chunk_size = 29)

covamb_long <- covamb_raw %>%
  pivot_longer(cols = JAN:DEC, 
               names_to = "MONTH", 
               values_to = "value")

covamb_summary <- covamb_long %>%
  dplyr::group_by(env, PARAMETER) %>%
  dplyr::summarise(mean_value = mean(value, na.rm = TRUE), .groups = "drop") %>%
  tidyr::pivot_wider(names_from = PARAMETER, values_from = mean_value)

write.csv(covamb_summary, "covamb_summary.csv", row.names = F)

