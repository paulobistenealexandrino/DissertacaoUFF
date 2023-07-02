# Roda modelos de regressão com os indicadores de acessibilidade

library(tidyverse)
library(sf)
library(spdep)
library(spatialreg)
library(stargazer)

options(scipen = 10) # Ajusta a notação científica
set.seed(42)


# Lendo a base de dados de uso do solo já com os indicadores
# de acessibilidade
acess_rio <- read_rds("input/data_processed/acess_rio.RDS")
# Limpando a base de dados
acess.model <- acess_rio %>%
  filter(ratio > 0, R001 > 0, P001 > 0, P003 > 0, T001 > 0)


# Criando a matriz de pesos espaciais:
# Cria um arquivo do tipo neighboor
queen.nb <- poly2nb(acess.model)
#Converte de neighboor para list
queen.listw <- nb2listw(queen.nb, style = "W", zero.policy = TRUE)

# Define a equação da regressão
reg.eq <- log(ratio) ~ log(R001) + log(P001) + log(T001)


# Rodar os quatro modelos mais simples:
# 1. OLS; 2. SLX (Lag X), SAR (Lag Y), SEM (Lag error)

# 1) OLS
reg1 <- lm(reg.eq, data = acess.model)
summary(reg1)
lm.morantest(reg1, queen.listw, zero.policy = TRUE)
lm.LMtests(reg1, queen.listw, zero.policy = TRUE, test = "all")

# 2) SLX (Lag X)
reg2 <- lmSLX(reg.eq, data = acess.model, queen.listw, zero.policy =  TRUE)
summary(reg2)
# Impacto total
impacts(reg2, listw = queen.listw)
# Impacto total com p-values
summary(impacts(reg2, listw = queen.listw, R = 500), zstats = TRUE)

# 3) SAR (Lag Y)
reg3 <- lagsarlm(reg.eq, data = acess.model, queen.listw, zero.policy =  TRUE)
summary(reg3)
impacts(reg3, listw = queen.listw)
summary(impacts(reg3, listw = queen.listw, R = 500), zstats = TRUE)

# 4) SEM (Lag Error)
reg4 <- errorsarlm(reg.eq, data = acess.model, queen.listw, zero.policy =  TRUE)



# Rodando regressão do modelo Durbin
reg_SDM <- lagsarlm(eq, data = acess_rio_model, queen.listw, type = "mixed", zero.policy = TRUE)

# Rodando modelo
model_acess <- lm(log(ratio) ~ log(R001) + log(P001) + log(P003) + log(T001), data = acess_rio_model)

# Resultados da regressãoins

summary(reg_SDM)

summary(impacts(reg_SDM, listw = queen.listw, R = 500), zstats = TRUE)
