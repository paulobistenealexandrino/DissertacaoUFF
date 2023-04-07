# Criando um base map do Rio de Janeiro


library(tidyverse)
library(geobr)
library(sf)
library(ggspatial)


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

# Plotando mapa
ggplot() +
  
  # Plotando os municípios do Estado
  geom_sf(data  = municipios_rj, 
          fill="grey96", 
          colour = "grey80") +
  # Destacando a cidade do Rio
  geom_sf(data  = municipios_rj %>% 
            filter(name_muni == "Rio De Janeiro")) +
  # Centralizando o mapa no Rio
  coord_sf(xlim = lon_bounds, 
           ylim = lat_bounds) +
  
  # Inserindo rosa-dos-ventos
  annotation_north_arrow(location = "br", 
                         which_north = "true",
                         height = unit(.75, "cm"),
                         width = unit(.75, "cm")) +
  # Inserindo escala
  annotation_scale() +
  
  
  theme_bw() + 
  theme(axis.text = element_blank(),
        axis.ticks = element_blank())


#################################################################


# Limites Geográficos dos municípios do Estado do RJ
sf_rj_municipalities <- read_municipality(code_muni = 33)

# Limites Geográficos Rio de Janeiro
sf_rio <- sf_rj_municipalities %>%
  filter(name_muni == "Rio De Janeiro")

# Shapefiles dos transportes

# Trem
sf_trem <- st_read("input/data_raw/shapefiles/Trajetos_Trem/Trajetos_Trem.shp")
# VLT
sf_vlt <- st_read("input/data_raw/shapefiles/Trajetos_VLT/Trajetos_VLT.shp")
# Ônibus
sf_onibus <- st_read("input/data_raw/shapefiles/Trajetos_Onibus/Trajetos_Onibus.shp")
# BRT
sf_brt <- st_read("input/data_raw/shapefiles/Trajetos_BRT/Trajetos_BRT.shp")

# Tentando fazer mapa com ggspatial
ggplot() +
  
  layer_spatial(sf_rio) +
  
  annotation_spatial(sf_rj_municipalities) +
  annotation_spatial(sf_onibus, color = "grey") +
  annotation_spatial(sf_brt, linetype = "dotdash", color = "green") +
  annotation_spatial(sf_trem, linetype = "dashed", color = "red") +
  annotation_spatial(sf_vlt, linetype = "dotted", color = "blue") +
  
  annotation_scale(location = "bl") +
  annotation_north_arrow(location = "br", which_north = "true") +
  
  theme_void()
  

# Plotando os shapefiles


ggplot() +
  geom_sf(data = sf_rj_municipalities) +
  geom_sf(data = sf_onibus, color = "grey") +
  geom_sf(data = sf_brt, linetype = "dotdash", color = "green") +
  geom_sf(data = sf_trem, linetype = "dashed", color = "red") +
  geom_sf(data = sf_vlt, linetype = "dotted", color = "blue") +
  coord_sf(xlim = lon_bounds, 
           ylim = lat_bounds, expand = FALSE) +
  annotation_scale(location = "bl") +
  annotation_north_arrow(location = "tl", which_north = "true") +
  
  theme_bw()
