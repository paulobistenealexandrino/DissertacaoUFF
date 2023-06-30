# Calculando a acessibilidade ANTES da intervenção


library(tidyverse)
library(sf)
library(accessibility)
library(RColorBrewer)


# Carregando os dados de uso do solo
landuse_rio <- read_rds("input/data_processed/landuse_rio.RDS") %>%
  rename(id = id_hex)

# Carregando a matriz de tempo de deslocamento antes
ttm_antes <- read_rds("input/data_processed/analise_impacto/ttm_antes.RDS")

# Carregando a matriz de tempo de deslocamento depois
ttm_depois <- read_rds("input/data_processed/analise_impacto/ttm_depois.RDS")

# Quantidade total de empregos
total_jobs <- as.numeric(sum(landuse_rio$T001))

# Calculando acesso a empregos antes
acess_antes <- cumulative_cutoff(
  travel_matrix = ttm_antes,
  land_use_data = landuse_rio,
  opportunity = "T001",
  travel_cost = "travel_time_p50",
  cutoff = 60) %>%
  rename(acess_antes = T001)

# Calculando acesso a empregos depois
acess_depois <- cumulative_cutoff(
  travel_matrix = ttm_depois,
  land_use_data = landuse_rio,
  opportunity = "T001",
  travel_cost = "travel_time_p50",
  cutoff = 60) %>%
  rename(acess_depois = T001)

# Unindo resultado antes e depois
acess_indices <- acess_antes %>%
  left_join(acess_depois, by = "id") %>%
  mutate(ratio = acess_depois/acess_antes,
         percent_antes = round(100*acess_antes/total_jobs, digits = 2),
         percent_depois = round(100*acess_depois/total_jobs, digits = 2),
         abs_change = acess_depois - acess_antes,
         rel_change = (acess_depois - acess_antes)/acess_antes)

# Unindo os indicadores de acessibilidade com os dados de uso do solo
acess_rio <- landuse_rio %>%
  left_join(acess_indices, by = "id") %>%
  mutate(R003 = if_else(R003 == 0, 1, as.double(R003)))

# Salvando resultados
saveRDS(acess_rio, file = "input/data_processed/acess_rio.RDS")
