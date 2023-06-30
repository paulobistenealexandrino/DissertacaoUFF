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

acess_rio %>%
  filter(!is.na(R003)) %>%
  ggplot() +
  geom_abline() +
  geom_point(aes(x = percent_antes, y = percent_depois, color = as.factor(R003), size = P001/1000),
             alpha = .6) +
  scale_color_brewer(palette = "RdBu") +
  scale_size_continuous(breaks = c(1, 5, 10)) +
  labs(color = "Decil Renda",
       size = "População \n (Milhares)") +
  xlab("% Empregos Acessíveis \n (Sem Linhas Retomadas)") +
  ylab("% Empregos Acessíveis \n (Com Linhas Retomadas)") +
  theme_classic()



# Dados necessários ao mapa
source("temp/basemap_data.R")

# Atribuindo cores para cada um dos modais
modes_colors <- c("Ônibus Convencional" = "slategray",
                  "BRT" = "magenta",
                  "Trem" = "#E69F00",
                  "Metrô" = "red",
                  "VLT" = "#0072B2")

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
  geom_sf(data = acess_rio %>% filter(!is.na(percent_depois)),
          color = NA,
          aes(fill = percent_depois)) +
  scale_fill_viridis_c() +
  
  # Inserindo as camadas com os transportes
  geom_sf(data = sf_onibus, aes(color = "Ônibus Convencional")) +
  geom_sf(data = sf_brt, linewidth = 0.6, aes(color = "BRT")) +
  geom_sf(data = sf_trem, linewidth = 0.6, aes(color = "Trem")) +
  geom_sf(data = sf_metro, linewidth = 0.6, aes(color = "Metrô")) +
  geom_sf(data = sf_vlt, linewidth = 0.6, aes(color = "VLT")) +
  # Atribuindo a escala com cores
  scale_color_manual(values = modes_colors,
                     breaks = c("Ônibus Convencional",
                                "BRT",
                                "Trem",
                                "Metrô",
                                "VLT")) +
  
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
  labs(fill = "Empregos Acessíveis (%)", color = "Modal") +
  
  # Ajustando tema
  theme_bw() + 
  theme(axis.text = element_blank(),
        axis.title = element_blank(),
        axis.ticks = element_blank(),
        panel.grid.major = element_line(color = "grey80",
                                        linetype = "dashed",
                                        size = 0.5),
        panel.background = element_rect(fill = "aliceblue"),
        legend.position = "bottom") +
  guides(col = guide_legend(direction = "horizontal"))
