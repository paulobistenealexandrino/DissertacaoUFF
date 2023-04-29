## Cleaning Routing Data ##

library(gtfstools)
library(tidyverse)
library(sf)

# Esse script prepara e organiza os arquivos que serão utilizados no
# calculo da matriz de tempo de viagem.

# Arquivos necessários:

# Malha Viária (.pbf)
# Pontos de origem e destino do roteamento (.csv)
# GTFS (.zip)
# ??? Dados de topografia


### Malha Viária

# Foi baixada a partir do site Hot Export Tool
# Disponível em: https://export.hotosm.org/en/v3/exports/c0f0daa3-9918-45ed-8f75-7d8a8a2cc6f1
# Acesso em: 20 mar. 2023


### Pontos de origem e destino

landuse_rio <- read_rds("input/data_processed/landuse_rio.RDS")

# Pontos de Origem: Locais com população entre 15 e 69 anos maior que zero.

origin_points <- landuse_rio %>%
  filter(P001 > 0) %>%
  select(id = id_hex, lon, lat) %>%
  st_drop_geometry()

write.csv(origin_points, "input/data_raw/r5r/origin_points.csv", row.names = FALSE)

# Pontos de Destino: Locais com número de oportunidades de emprego maior que zero.

destiny_points <- landuse_rio %>%
  filter(T001 > 0 | E001 > 0 | S001 > 0) %>%
  select(id = id_hex, lon, lat) %>%
  st_drop_geometry()

write.csv(destiny_points, "input/data_raw/r5r/destiny_points.csv", row.names = FALSE)


### GTFS
folder <- "input/data_raw/r5r/"

# Lendo GTFS
gtfs_smtr <- read_gtfs(file.path(folder,"gtfs_rio-de-janeiro.zip"))
gtfs_setrans <- read_gtfs(file.path(folder,"gtfs_setrans.zip"))

# Unindo GTFS
gtfs_rj <- merge_gtfs(gtfs_smtr, gtfs_setrans)

# Salvando
endereco_destino <- paste0(folder,"gtfs_rj_merged.zip")
write_gtfs(gtfs_rj, path = endereco_destino)
