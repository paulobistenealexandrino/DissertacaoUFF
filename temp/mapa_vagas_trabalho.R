# Criando um mapa de calor das vagas de emprego no Rio de Janeiro


library(tidyverse)
library(geobr)
library(sf)
library(ggspatial)
library(aopdata)


# Baixando os municípios do Estado do RJ
municipios_rj <- read_municipality(code_muni = 33)

# Pegando o centroide da cidade do Rio para centralizar mapa
zoom_to <- municipios_rj %>% 
  filter(name_muni == "Rio De Janeiro") %>%
  st_centroid() %>%
  st_coordinates() %>%
  as.vector()

zoom_level <- 9

lon_span <- 360 / 2^zoom_level
lat_span <- 180 / 2^zoom_level

lon_bounds <- c(zoom_to[1] - lon_span / 2, zoom_to[1] + lon_span / 2)
lat_bounds <- c(zoom_to[2] - lat_span / 2, zoom_to[2] + lat_span / 2)


# Baixando os dados de uso do solo do Rio de Janeiro
landuse_rio <- read_landuse(city = "Rio de Janeiro", geometry = TRUE)


# Construindo mapa
ggplot() +
  
  # Plotando os municípios do Estado
  geom_sf(data  = municipios_rj, 
          fill="grey96", 
          colour = "grey80") +
  # Destacando a cidade do Rio
  geom_sf(data  = municipios_rj %>% 
            filter(name_muni == "Rio De Janeiro")) +
  # Dados de oportunidades de emprego
  geom_sf(data = subset(landuse_rio, T001 > 0), 
          aes(fill = T001/10^3),
          color = NA) +
  scale_fill_viridis_c(option = "viridis") +
  # Centralizando o mapa no Rio
  coord_sf(xlim = lon_bounds, 
           ylim = lat_bounds) +
  
  # Inserindo rosa-dos-ventos
  annotation_north_arrow(location = "bl", 
                         which_north = "true",
                         style = north_arrow_fancy_orienteering,
                         height = unit(.75, "cm"),
                         width = unit(.75, "cm")) +
  # Inserindo escala
  annotation_scale(location = "br", height = unit(0.1, "cm")) +
  
  # Editando legenda
  labs(fill = "Postos de Trabalho \n (em milhares)") +
  
  # Editando tema
  theme_bw() + 
  theme(axis.text = element_blank(),
        axis.ticks = element_blank(),
        panel.grid.major = element_line(color = "grey80",
                                        linetype = "dashed",
                                        size = 0.5),
        panel.background = element_rect(fill = "aliceblue"),
        legend.position = "bottom")
