# Teste de autocorrelação espacial

library(tidyverse)
library(sf)
library(spdep)

options(scipen = 10) # Ajusta a notação científica
set.seed(42) # Define os valores aleatórios


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


# Teste de Moran

# Assumindo distribuição normal do ganho de acessibildade
# Nota: os dados não indicam normalidade dessa variável

moran.test(acess.model$ratio, queen.listw, zero.policy = TRUE)

# Teste de permutação de Moran

# Não assume a normalidade dos dados

moran.mc(acess.model$ratio, 
         queen.listw,
         nsim = 10000,
         zero.policy = TRUE)
