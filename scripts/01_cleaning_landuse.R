# Cleaning Landuse Dataset

# Esse script prepara o dataset principal da análise: 
# as informações de uso da terra da cidade do Rio de Janeiro.

library(tidyverse)
library(aopdata)
library(sf)

# Malha Hexagonal do Rio de Janeiro
landuse_rio <- read_landuse(city = 'rio', geometry = TRUE)

# Gerando as coordenadas do centroide de cada um dos hexágonos
coords_centroids <- st_centroid(landuse_rio) %>%
  st_coordinates()

# Associando coordenadas dos centroides aos hexágonos
landuse_rio <- landuse_rio %>%
  mutate(lon = coords_centroids[,1],
         lat = coords_centroids[,2])

# Salvando o dataset
landuse_rio %>%
  write_rds("input/data_processed/landuse_rio.RDS")
