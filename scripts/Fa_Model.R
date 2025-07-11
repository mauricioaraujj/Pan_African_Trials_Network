setwd("~/Scientific_data")
library(asreml)
library(readr)
library(tidyverse)
library(gghighlight)
library(ggrepel)
library(ggpubr)
library(ggspatial)
if(!require("BiocManager", quietly = TRUE)){
  install.packages("BiocManager")}
library(ComplexHeatmap)
library(circlize)
library(asreml)
source("https://raw.githubusercontent.com/saulo-chaves/May_b_useful/refs/heads/main/fa_outs.R")
require(pls)
library(raster)
library(sf)
library(spatstat)
library(geodata)
library(parallel)
library(doParallel)
library(foreach)
require(reshape2)
library(dplyr)

asreml.options(maxit = 100, workspace = "16gb", pworkspace = "16gb")



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

# FA Models ---------------------------------------------------------------

M1 = asreml(
  fixed = GY ~ rep:env + env,
  random = ~ gen:fa(env, 1),
  data = data,
  residual = ~ dsum(~id(units) | env),
  na.action = na.method(x = "include", y = "include"),
  maxit = 300)


M2 = asreml(
  fixed = GY ~ rep:env + env,
  random = ~ gen:fa(env, 2),
  data = data,
  residual = ~ dsum(~id(units) | env),
  na.action = na.method(x = "include", y = "include"),
  maxit = 300)

M3 = asreml(
  fixed = GY ~ rep:env + env,
  random = ~ gen:fa(env, 3),
  data = data,
  residual = ~ dsum(~id(units) | env),
  na.action = na.method(x = "include", y = "include"),
  maxit = 300)

M4 = asreml(
  fixed = GY ~ rep:env + env,
  random = ~ gen:fa(env, 4),
  data = data,
  residual = ~ dsum(~id(units) | env),
  na.action = na.method(x = "include", y = "include"),
  maxit = 300)

M4 = update(M4)

M5 = asreml(
  fixed = GY ~ rep:env + env,
  random = ~ gen:fa(env, 5),
  data = data,
  residual = ~ dsum(~id(units) | env),
  na.action = na.method(x = "include", y = "include"),
  maxit = 300)


M6 = asreml(
  fixed = GY ~ rep:env + env,
  random = ~ gen:fa(env, 6),
  data = data,
  residual = ~ dsum(~id(units) | env),
  na.action = na.method(x = "include", y = "include"),
  maxit = 300)



# Diagnos -----------------------------------------------------------------
fa.models = list(M4)
fa.res = lapply(fa.models, function(x) fa.outs(x, name.env = "env",
                                               name.gen = "gen"))
diagnos = do.call(rbind,lapply(fa.res, function(x) x$diagnostics))

rownames(diagnos) = c("M4"); diagnos[,'ASVR']

write.csv(diagnos, file = "Diaginostico.csv", row.names = F)

save(fa.res, file = "fa_res.RData")
fa4 = fa.res[[1]]
save(fa4, file = "fa4.RData")


rm(M1, M2, M3,M5, fa.models, fa.res); gc() 




# Fitting  ----------------------------------------------------------------

sum.M4 = summary(M4)$varcomp
sum.M4 = summary(M4)$varcomp
aic.M4 = summary(M4)$aic
bic.M4 = summary(M4)$bic
loglik.M4 = summary(M4)$loglik

fa1.loadings = sum.M4[grep('fa1',rownames(sum.M4)),1]
fa2.loadings = sum.M4[grep('fa2',rownames(sum.M4)),1]
fa3.loadings = sum.M4[grep('fa3',rownames(sum.M4)),1]
fa4.loadings = sum.M4[grep('fa4',rownames(sum.M4)),1]

mat.loadings = as.matrix(cbind(fa1.loadings, fa2.loadings,fa3.loadings,
                               fa4.loadings))
svd.mat.loadings = svd(mat.loadings)
mat.loadings.star = mat.loadings %*% svd.mat.loadings$v * -1
colnames(mat.loadings.star) = c("fa1",'fa2','fa3','fa4')
psi = diag(sum.M4[grep('var',rownames(sum.M4)),1])
lamblamb.star = mat.loadings.star %*% t(mat.loadings.star)
Gvcov = lamblamb.star + psi
expvar4.M4 = (sum(diag(lamblamb.star))/
                sum(diag(Gvcov))) * 100


# H2, CV and Acc ----------------------------------------------------------
par = data.frame(
  H2 = fa4$H2,
  CV = (sqrt(summary(M4)$varcomp[grep('!R', rownames(summary(M4)$varcomp)),1])/
          tapply(data$GY, data$env, mean, na.rm = T)) * 100
) |> 
  tibble::rownames_to_column("env") |> 
  ggplot(aes(x = H2, y = CV)) + 
  geom_text(aes(label = env)) + 
  labs(x = "Generalized heritability", y = "CV (%)") 




# Genetic Correlation -----------------------------------------------------
Gcor <- fa4$Gcor
Gcor[lower.tri(Gcor, diag = TRUE)] <- NA
Gcor_long <- na.omit(as.data.frame(as.table(Gcor)))
names(Gcor_long) <- c("from", "to", "correlation")
col_fun <- colorRamp2(c(-1, 0, 1), c("blue", "white", "red"))
circos.clear()
chordDiagram(
  Gcor_long,
  col = col_fun(Gcor_long$correlation),
  transparency = 0.4,
  annotationTrack = "grid",
  preAllocateTracks = 1
)
circos.trackPlotRegion(
  track.index = 1,
  panel.fun = function(x, y) {
    sector.name <- get.cell.meta.data("sector.index")
    circos.text(
      x = CELL_META$xcenter,
      y = CELL_META$ylim[1],
      labels = sector.name,
      facing = "clockwise",
      niceFacing = TRUE,
      adj = c(0, 0.5),
      cex = 0.6
    )
  },
  bg.border = NA
)

colbar <- colorRampPalette(c("blue", "white", "red"))(100)
legend_image <- as.raster(matrix(colbar, ncol = 1))
grid.raster(legend_image, x = unit(0.85, "npc"), y = unit(0.5, "npc"),
            width = unit(0.02, "npc"), height = unit(0.4, "npc"))
labels <- c(-1, -0.5, 0, 0.5, 1)
label_pos <- seq(0.3, 0.7, length.out = length(labels))

for (i in seq_along(labels)) {
  grid.text(
    label = labels[i],
    x = unit(0.88, "npc"),
    y = unit(label_pos[i], "npc"),
    gp = gpar(fontsize = 9)
  )
}
grid.text("Genetic correlation)",
          x = unit(0.93, "npc"), y = unit(0.73, "npc"),
          gp = gpar(fontsize = 10))


# ---  Heatmap ---------------------------------------------------------
Gcor <- fa4$Gcor
df <- as.data.frame(as.table(Gcor))
names(df) <- c("env1", "env2", "value")
df <- df %>% filter(as.numeric(env1) < as.numeric(env2))
env_order <- sort(unique(c(df$env1, df$env2)))
df$env1 <- factor(df$env1, levels = env_order)
df$env2 <- factor(df$env2, levels = env_order)
coor <- ggplot(df, aes(x = env1, y = env2, fill = value)) +
  geom_tile(color = "white") +
  geom_text(aes(label = round(value, 2)), color = "black", size = 3) +
  scale_fill_gradient2(
    low = "red", mid = "lightblue", high = "blue3",
    midpoint = 0, limits = c(-1, 1),
    name = "Genetic correlation"
  ) +
  coord_fixed() +
  theme_minimal(base_size = 15) +
  theme(
    axis.text.x = element_text(angle = 90, hjust = 0),
    axis.text.y = element_text(angle = 0, hjust = 0, vjust = 0.9),
    panel.grid = element_blank(),
    axis.title = element_blank(),
    legend.position = "bottom",
    legend.justification = "center"
  ) +
  scale_y_discrete(limits = rev(env_order))




# FAST --------------------------------------------------------------------

rel = fa4$blups |> 
  dplyr::reframe(rel = 1-(mean(std.error^2)/mean(diag(fa4$Gvcov))), .by = gen)

FAST = data.frame(
  env = fa4$blups$env,
  gen = fa4$blups$gen,
  RMSD = (fa4$blups$marginal - (kronecker(fa4$rot.loads[,1], diag(num.gen)) %*%
                                  fa4$rot.scores[,1]))^2
) |> dplyr::reframe(RMSD = sqrt(mean(RMSD)), .by = gen) |> 
  dplyr::mutate(OP = mean(fa4$rot.loads[,1]) * fa4$rot.scores[,1],
                index = 2*((OP-mean(OP))/sqrt(var(OP))) - ((RMSD-mean(RMSD))/sqrt(var(RMSD))),
                rel = rel$rel)


fast = FAST |> 
  ggplot(aes(x = RMSD, y = OP)) + 
  geom_point(aes(color = rel)) + 
  geom_vline(xintercept = 0, linetype = 'dashed') + 
  geom_hline(yintercept = 0, linetype = "dashed") + 
  gghighlight(gen %in% FAST[order(FAST$index, decreasing = TRUE), 'gen'][1:20]) +
  geom_label_repel(aes(label = gen), size = 3, box.padding = 0.5, max.overlaps = 30) + 
  scale_color_gradientn(
    colours = c("red", "#9938ea", "green1"),
    limits = c(0, 1),  
    name = "Reliability"
  ) +
  labs(x = "Root mean square deviation", y = "Overall performance")

print(fast)


