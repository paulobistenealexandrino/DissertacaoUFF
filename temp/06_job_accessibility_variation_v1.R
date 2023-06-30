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
  filter(R003 %in% 1:10,
         acess_diff > 0)

# Dados necessários ao mapa
source("temp/basemap_data.R")

# Construindo mapa
ggplot() +
  
  # Plotando os municípios do Estado
  geom_sf(data  = municipios_rj, 
          fill="grey96", 
          colour = "grey80") +
  
  # Destacando a cidade do Rio
  geom_sf(data  = municipios_rj %>% 
            filter(name_muni == "Rio De Janeiro")) +
  
  # Indicadores de acessidade
  geom_sf(data = acessibilidade_rio,
          color = NA,
          aes(fill = acess_diff/1000)) +
  scale_fill_viridis_c(guide = guide_colorbar(direction = "horizontal")) +
  
  # Destacando a cidade do Rio
  geom_sf(data  = municipios_rj %>% 
            filter(name_muni == "Rio De Janeiro"),
          fill = NA) +

  # Centralizando o mapa no Rio
  coord_sf(xlim = zoom_bounds(coords = "lon"), 
           ylim = zoom_bounds(coords = "lat")) +
  
  # Inserindo rosa-dos-ventos
  annotation_north_arrow(location = "bl",
                        which_north = "true",
                        style = north_arrow_fancy_orienteering,
                        height = unit(.75, "cm"),
                        width = unit(.75, "cm")) +
  # Inserindo escala
  annotation_scale(location = "br", height = unit(0.1, "cm")) +
  
  # Editando legenda
  labs(fill = "Diferença Empregos Acessíveis (em milhares)") +
  
  # Editando tema
  theme_bw() + 
  theme(axis.text = element_blank(),
        axis.title = element_blank(),
        axis.ticks = element_blank(),
        panel.grid.major = element_line(color = "grey80",
                                        linetype = "dashed",
                                        size = 0.5),
        panel.background = element_rect(fill = "aliceblue"),
        legend.position = c(0.5, 0.075),
        rect = element_rect(fill = NA))

# Ditribuição do efeito por renda
ggplot(acessibilidade_rio,
       aes(factor(R003), acess_diff)) +
  geom_boxplot(aes(color = factor(R003))) +
  theme_bw()
