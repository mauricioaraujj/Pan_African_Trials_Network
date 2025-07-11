# Packages ----------------------------------------------------------------
if (!require("mixOmics")) install.packages("mixOmics")
library(mixOmics)
library(asreml)
library(dplyr)
library(ggplot2)
library(tibble)
library(tidyr)



# Data --------------------------------------------------------------------
data <- read.csv("Malawi.csv", h = TRUE, sep = ";")
data <- transform(data, 
                  gen = factor(gen),
                  rep = factor(rep),
                  env = factor(env))

# eBLUE -------------------------------------------------------------------

nomes <- unique(data$env)
eblues <- list()

for (i in seq_along(nomes)) {
  d_env <- droplevels(filter(data, env == nomes[i]))
  
  model_env <- asreml(
    fixed = GY ~ gen + rep,
    residual = ~ id(units),
    na.action = na.method(x = "exclude", y = "exclude"),
    data = d_env
  )
  
  pred <- predict(model_env, classify = "gen", vcov = TRUE)
  pred$pvals$SE <- sqrt(diag(pred$vcov))
  pred$pvals$env <- nomes[i]
  eblues[[i]] <- pred$pvals
}

MeanGY <- do.call(rbind, eblues)

GY_env <- MeanGY %>%
  group_by(env) %>%
  summarise(GY = mean(predicted.value, na.rm = TRUE))


# Covamb + eBLUE + sPLS ----------------------------------------------------------
covamb_summary <- covamb %>%
  group_by(env) %>%
  summarise(across(where(is.numeric), mean, na.rm = TRUE))
df_pls <- inner_join(GY_env, covamb_summary, by = "env")

X <- as.matrix(df_pls[, !(names(df_pls) %in% c("env", "GY"))])
Y <- df_pls$GY

spls_model <- spls(X, Y, ncomp = 2, keepX = c(10, 10))
coef_df <- data.frame(variable = rownames(spls_model$loadings$X),
                      comp1 = spls_model$loadings$X[,1],
                      comp2 = spls_model$loadings$X[,2]) %>%
  pivot_longer(cols = starts_with("comp"), names_to = "Component", values_to = "Loading")

vip_df <- data.frame(
  variable = colnames(X),
  VIP_comp1 = vip(spls_model)[,1],
  VIP_comp2 = vip(spls_model)[,2]
)

vip_df <- vip_df %>%
  rowwise() %>%
  mutate(mean_VIP = mean(c_across(starts_with("VIP_")), na.rm = TRUE)) %>%
  ungroup()

top10_vars <- vip_df %>%
  arrange(desc(mean_VIP)) %>%
  slice(1:10) %>%
  pull(variable)

top_df <- coef_df %>%
  filter(variable %in% top10_vars) %>%
  left_join(vip_df, by = "variable") %>%
  mutate(variable = fct_reorder(variable, mean_VIP)) # ordena por importância


# Plot --------------------------------------------------------------------
ggplot(top_df, aes(x = variable, y = Loading, fill = mean_VIP)) +
  geom_col(width = 0.4) +
  coord_flip() +
  scale_fill_gradient(
    low = "red",
    high = "blue",
    name = "VIP"
  ) +
  labs(
    title = "",
    x = "Environmental Features",
    y = "Component Loading"
  ) +
  theme_minimal(base_size = 14) +
  theme_gray()
