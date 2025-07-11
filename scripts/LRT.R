
# Packages ----------------------------------------------------------------
require(asreml)
require(tidyverse)
require(dplyr)


# Data --------------------------------------------------------------------

data <- read_delim("soy.csv", 
                   delim = ";", 
                   escape_double = FALSE, 
                   trim_ws = TRUE)

data <- transform(data,
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

name.env <- levels(data$env)
name.gen <- levels(data$gen)
name.year <- levels(data$YEAR)
name.loc <- levels(data$loc)
name.sea <- levels(data$SEASON)


results <- data.frame(site = character(), 
                         P_valor = numeric(), 
                         signn = character(), 
                         stringsAsFactors = FALSE)


for (i in levels(data$env)) {
  
  soydata <- subset(data, env == i)
  
  
  try({
    Mod_f <- asreml(GY ~ rep,
                    random = ~ gen,
                    data = soyadata,
                    maxit = 100,
                    na.action = na.method(x="include", y = "include"))
    
    Mod_r <- asreml(GY ~ rep,
                    data = soyadata,
                    maxit = 100,
                    na.action = na.method(x="include", y = "include"))
    
    
    p_valor <- lrt(Mod_f, Mod_r)[3]
    
    
    sig <- if (p_valor <= 0.001) {
      "***"
    } else if (p_valor <= 0.01) {
      "**"
    } else if (p_valor <= 0.05) {
      "*"
    } else {
      "ns"
    }
    
    
    results <- rbind(results, 
                        data.frame(site = i, 
                                   P_valor = p_valor, 
                                   signn = sig))
  }, silent = TRUE)
}


view(results)
