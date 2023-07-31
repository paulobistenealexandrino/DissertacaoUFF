# Gera mapa com a distribuição da acessibilidade no Rio (2023)


library(tidyverse)
library(sf)
library(RColorBrewer)


# Lendo a base de dados de uso do solo já com os indicadores
# de acessibilidade
acess_rio <- read_rds("input/data_processed/acess_rio.RDS")

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
  geom_sf(data = acess_rio %>% filter(!is.na(percent_depois)),
          color = NA,
          aes(fill = percent_depois)) +
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
  labs(fill = "Empregos Acessíveis (%)", color = "Modal") +
  
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
