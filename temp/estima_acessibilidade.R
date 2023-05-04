# Calculando a acessibilidade ANTES da intervenção


library(tidyverse)
library(sf)
library(accessibility)


# Carregando os dados de uso do solo
landuse_rio <- read_rds("input/data_processed/landuse_rio.RDS") %>%
  rename(id = id_hex)

# Carregando a matriz de tempo de deslocamento antes
ttm_antes <- read_rds("input/data_processed/analise_impacto/ttm_antes.RDS")

# Carregando a matriz de tempo de deslocamento depois
ttm_depois <- read_rds("input/data_processed/analise_impacto/ttm_depois.RDS")

# Calculando acesso a empregos (total) antes
acesso_empregos_antes <- cumulative_cutoff(
  travel_matrix = ttm_antes,
  land_use_data = landuse_rio,
  opportunity = "T001",
  travel_cost = "travel_time_p50",
  cutoff = 60
)

# Calculando acesso a empregos (total) depois
acesso_empregos_depois <- cumulative_cutoff(
  travel_matrix = ttm_depois,
  land_use_data = landuse_rio,
  opportunity = "T001",
  travel_cost = "travel_time_p50",
  cutoff = 60
)

# Ajustando nomes das colunas
acesso_empregos_antes <- acesso_empregos_antes %>%
  rename(acess_antes = T001)

acesso_empregos_depois <- acesso_empregos_depois %>%
  rename(acess_depois = T001)

# Analise de impacto
analise_impacto <- acesso_empregos_antes %>%
  full_join(acesso_empregos_depois, by = "id") %>%
  mutate(acess_diff = acess_depois - acess_antes)

# Unindo aos dados de uso do solo
acessibilidade_rio <- landuse_rio %>%
  left_join(analise_impacto, by = "id") %>%
  filter(acess_diff >= 0)

# Gerando mapa
ggplot() +
  geom_sf(data = acessibilidade_rio,
          aes(fill = acess_diff)) +
  scale_fill_viridis_c()

# Ditribuição do efeito por renda
ggplot(acessibilidade_rio,
       aes(factor(R003), acess_diff)) +
  geom_boxplot(aes(color = factor(R003)))


# Acesso a escolas
acesso_escolas_antes <- cost_to_closest(
  travel_matrix = ttm_antes,
  land_use_data = landuse_rio,
  opportunity = "E003",
  travel_cost = "travel_time_p50"
)

acesso_escolas_depois <- cost_to_closest(
  travel_matrix = ttm_depois,
  land_use_data = landuse_rio,
  opportunity = "E003",
  travel_cost = "travel_time_p50"
)

acessibilidade_rio <- acessibilidade_rio %>%
  left_join(acesso_escolas_antes, by = "id")

# Gerando mapa
ggplot() +
  geom_sf(data = acessibilidade_rio,
          aes(fill = travel_time_p50))
