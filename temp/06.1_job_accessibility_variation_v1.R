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

# Quantidade total de empregos
quant_oport <- landuse_rio %>%
  select(T001:T004) %>%
  st_drop_geometry() %>%
  mutate(T002_3 = T002 + T003, 
         T003_4 = T003 + T004) %>%
  pivot_longer(cols = T001:T003_4,
               names_to = "tipo_oport",
               values_to = "quant_total") %>%
  group_by(tipo_oport) %>%
  summarise(total_jobs = sum(quant_total))

# Distribuição dos empregos entre os hexágonos
landuse_jobs <- landuse_rio %>%
  st_drop_geometry() %>%
  select(id, T001:T004) %>%
  mutate(T002_3 = T002 + T003, 
         T003_4 = T003 + T004) %>%
  select(!T002:T004)

# Calculando acesso a empregos antes
acess_antes <- NULL
tipo_oport <- c("T001","T002_3","T003_4")

for (t in tipo_oport) {
  
  if (t == "T001") {
    
    acess <- cumulative_cutoff(
      travel_matrix = ttm_antes,
      land_use_data = landuse_jobs,
      opportunity = t,
      travel_cost = "travel_time_p50",
      cutoff = 60
    )
    
    acess_antes <- acess
    
  } else {
    
    acess <- cumulative_cutoff(
      travel_matrix = ttm_antes,
      land_use_data = landuse_jobs,
      opportunity = t,
      travel_cost = "travel_time_p50",
      cutoff = 60
    )
    
    acess_antes <- acess_antes %>%
      left_join(acess, by = "id")
    
  }
}

# Organizando dados
acess_antes <- acess_antes %>%
  pivot_longer(T001:T003_4,
               names_to = "tipo_oport",
               values_to = "quant_oport") %>%
  mutate(cenario = "antes")

# Removendo variáveis temporárias
rm(acess, t, tipo_oport)

# Calculando acesso a empregos depois
acess_depois <- NULL
tipo_oport <- c("T001","T002_3","T003_4")

for (t in tipo_oport) {
  
  if (t == "T001") {
    
    acess <- cumulative_cutoff(
      travel_matrix = ttm_depois,
      land_use_data = landuse_jobs,
      opportunity = t,
      travel_cost = "travel_time_p50",
      cutoff = 60
    )
    
    acess_depois <- acess
    
  } else {
    
    acess <- cumulative_cutoff(
      travel_matrix = ttm_depois,
      land_use_data = landuse_jobs,
      opportunity = t,
      travel_cost = "travel_time_p50",
      cutoff = 60
    )
    
    acess_depois <- acess_depois %>%
      left_join(acess, by = "id")
    
  }
}

# Organizando dados
acess_depois <- acess_depois %>%
  pivot_longer(T001:T003_4,
               names_to = "tipo_oport",
               values_to = "quant_oport") %>%
  mutate(cenario = "depois")

# Removendo variáveis temporárias
rm(acess, t, tipo_oport)
rm(ttm_antes, ttm_depois, landuse_jobs)

# Unindo resultado antes e depois
acess_rio <- acess_antes %>%
  bind_rows(acess_depois) %>%
  pivot_wider(names_from = "cenario",
              values_from = "quant_oport") %>%
  left_join(quant_oport, by = "tipo_oport")

# Criando indicadores
acess_rio_ind <- acess_rio %>%
  mutate(ratio_antes = round(100*antes/total_jobs, digits = 2),
         ratio_depois = round(100*depois/total_jobs, digits = 2),
         abs_change = depois - antes,
         rel_change = (depois - antes)/antes)
