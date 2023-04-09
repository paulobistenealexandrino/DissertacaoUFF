# Criando mapa dos transportes do Rio de Janeiro


library(tidyverse)
library(geobr)
library(sf)
library(ggspatial)
library(gtfstools)


# Organizando os shapefiles dos transportes

# Ônibus 
# Fonte: Data.Rio | GTFS do Rio de Janeiro
# Link: https://www.data.rio/datasets/gtfs-do-rio-de-janeiro/about
# Lendo GTFS
gtfs_path <- "input/data_raw/r5r/gtfs_rio-de-janeiro.zip"
rj_gtfs <- read_gtfs(gtfs_path)
# Pegando shapefile das linhas
sf_onibus <- get_trip_geometry(rj_gtfs, file = "shapes")
# Removendo arquivos auxiliares
rm(gtfs_path, rj_gtfs)

# BRT
# Fonte: Data.Rio | Trajetos BRT
# Link: https://www.data.rio/datasets/trajetos-brt/explore?location=-22.915687%2C-43.431850%2C11.49
# Lendo shapefile:
sf_brt <- st_read("input/data_raw/shapefiles/Trajetos_BRT/Trajetos_BRT.shp")
# Filtrando linhas inoperantes
sf_brt <- sf_brt %>%
  filter(flg_ativa == 1)

# Trem
# Fonte: Data.Rio | Trajetos Trem
# Link: https://www.data.rio/datasets/trajetos-trem/explore?location=-22.699543%2C-43.297792%2C9.35
# Lendo shapefile:
sf_trem <- st_read("input/data_raw/shapefiles/Trajetos_Trem/Trajetos_Trem.shp")

# Metro
# Fonte: Data.Rio | Estações Metrô
# Link: https://www.data.rio/datasets/esta%C3%A7%C3%B5es-metr%C3%B4/explore
# Utilizei o script "temp/gerar_shapefile_metro.R"
sf_metro <- read_rds("input/data_processed/sf_metro.RDS")

# VLT
# Fonte: Data.Rio | Trajetos VLT
# Link: https://www.data.rio/datasets/trajeto-vlt/explore?location=-22.912172%2C-43.192131%2C14.20
# Lendo shapefile:
sf_vlt <- st_read("input/data_raw/shapefiles/Trajetos_VLT/Trajetos_VLT.shp")


# Atribuindo cores para cada um dos modais
modes_colors <- c("Ônibus Convencional" = "#BB8FCE",
                  "BRT" = "#009E73",
                  "Trem" = "#E69F00",
                  "Metrô" = "#D55E00",
                  "VLT" = "#0072B2")

# Montando o basemap

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
  
  # Inserindo as camadas com os transportes
  geom_sf(data = sf_onibus, aes(color = "Ônibus Convencional")) +
  geom_sf(data = sf_brt, linewidth = 0.75, aes(color = "BRT")) +
  geom_sf(data = sf_trem, linewidth = 0.75, aes(color = "Trem")) +
  geom_sf(data = sf_metro, linewidth = 0.75, aes(color = "Metrô")) +
  geom_sf(data = sf_vlt, linewidth = 0.75, aes(color = "VLT")) +
  # Atribuindo a escala com cores
  scale_color_manual(values = modes_colors,
                     breaks = c("Ônibus Convencional",
                                "BRT",
                                "Trem",
                                "Metrô",
                                "VLT")) +
  
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
  # Alterando nome da legenda
  labs(color = "Modal") +
  
  # Ajustando tema
  theme_bw() + 
  theme(axis.text = element_blank(),
        axis.ticks = element_blank(),
        panel.grid.major = element_line(color = "grey80",
                                        linetype = "dashed",
                                        size = 0.5),
        panel.background = element_rect(fill = "aliceblue"),
        legend.position = "bottom")
