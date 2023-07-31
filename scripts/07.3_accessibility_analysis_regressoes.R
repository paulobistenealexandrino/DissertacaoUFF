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
acess.rio <- read_rds("input/data_processed/acess_rio.RDS")
# Limpando a base de dados
acess.model <- acess.rio %>%
  filter(ratio > 0, R001 > 0, P001 > 0, P003 > 0, T001 > 0)


# Criando a matriz de pesos espaciais:
# Cria um arquivo do tipo neighboor
queen.nb <- poly2nb(acess.model)
#Converte de neighboor para list
queen.listw <- nb2listw(queen.nb, style = "W", zero.policy = TRUE)

# Define a equação da regressão
reg.eq <- log(ratio) ~ log(R001) + log(P001) + log(T001)
reg.eq2 <- log(ratio) ~ log(R001) + log(P001) + log(P003) + log(T001)

# Rodando regressão do modelo Durbin 1
reg_SDM <- lagsarlm(reg.eq, 
                    data = acess.model, 
                    queen.listw, 
                    type = "mixed", 
                    zero.policy = TRUE)

# Salvando resultados
#saveRDS(reg_SDM, "output/Resultados/reg_SDM.RDS")

# Resultados da regressão 1:
summary(reg_SDM)

impacts_SDM <- impacts(reg_SDM, listw = queen.listw)
#saveRDS(impacts_SDM, "output/Resultados/impacts_SDM.RDS")

summary.impacts_SDM <- summary(impacts(reg_SDM, listw = queen.listw, R = 500), zstats = TRUE)
#saveRDS(summary.impacts_SDM, "output/Resultados/summary.impacts_SDM.RDS")



# Rodando regressão do modelo Durbin 2:
reg_SDM2 <- lagsarlm(reg.eq2, 
                     data = acess.model, 
                     queen.listw, 
                     type = "mixed", 
                     zero.policy = TRUE)

# Salvando resultados 2:
#saveRDS(reg_SDM2, "output/Resultados/reg_SDM2.RDS")

# Resultados da regressão 2:
summary(reg_SDM2)

impacts_SDM2 <- impacts(reg_SDM2, listw = queen.listw)
#saveRDS(impacts_SDM2, "output/Resultados/impacts_SDM2.RDS")

summary.impacts_SDM2 <- summary(impacts(reg_SDM2, listw = queen.listw, R = 500), zstats = TRUE)
#saveRDS(summary.impacts_SDM2, "output/Resultados/summary.impacts_SDM2.RDS")

# Calculando Pseudo R2

# Regressão 1
1-(reg_SDM$SSE/(var(acess.model$ratio)*(length(acess.model$ratio)-1)))

# Regressão 2
1-(reg_SDM2$SSE/(var(acess.model$ratio)*(length(acess.model$ratio)-1)))
