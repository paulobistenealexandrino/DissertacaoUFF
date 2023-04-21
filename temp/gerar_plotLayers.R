# Gerar camadas dos mapas em .RDS


library(tidyverse)
library(gtfstools)
library(sf)
library(aopdata)


# Organizando os shapefiles dos transportes


# Ônibus 
# Fonte: Data.Rio | GTFS do Rio de Janeiro
# Link: https://www.data.rio/datasets/gtfs-do-rio-de-janeiro/about
# Lendo GTFS
gtfs_path <- "input/data_raw/r5r/gtfs_rio-de-janeiro.zip"
rj_gtfs <- read_gtfs(gtfs_path)
# Pegando shapefile das linhas
sf_onibus <- convert_shapes_to_sf(rj_gtfs) %>%
  st_combine()
# Removendo arquivos auxiliares
rm(gtfs_path, rj_gtfs)
# Salvando
write_rds(sf_onibus,"input/data_processed/plot_layers/sf_onibus.RDS")


# BRT
# Fonte: Data.Rio | Trajetos BRT
# Link: https://www.data.rio/datasets/trajetos-brt/explore?location=-22.915687%2C-43.431850%2C11.49
# Lendo shapefile:
sf_brt <- st_read("input/data_raw/shapefiles/Trajetos_BRT/Trajetos_BRT.shp")
# Filtrando linhas inoperantes
sf_brt <- sf_brt %>%
  filter(flg_ativa == 1) %>%
  st_combine()
# Salvando
write_rds(sf_brt,"input/data_processed/plot_layers/sf_brt.RDS")


# Trem
# Fonte: Data.Rio | Trajetos Trem
# Link: https://www.data.rio/datasets/trajetos-trem/explore?location=-22.699543%2C-43.297792%2C9.35
# Lendo shapefile:
sf_trem <- st_read("input/data_raw/shapefiles/Trajetos_Trem/Trajetos_Trem.shp") %>%
  st_combine()
# Salvando
write_rds(sf_trem,"input/data_processed/plot_layers/sf_trem.RDS")


# Metro
# Fonte: Data.Rio | Estações Metrô
# Link: https://www.data.rio/datasets/esta%C3%A7%C3%B5es-metr%C3%B4/explore
# Utilizei o script "temp/gerar_shapefile_metro.R"
sf_metro <- read_rds("input/data_processed/sf_metro.RDS") %>%
  st_combine()
# Salvando
write_rds(sf_metro,"input/data_processed/plot_layers/sf_metro.RDS")


# VLT
# Fonte: Data.Rio | Trajetos VLT
# Link: https://www.data.rio/datasets/trajeto-vlt/explore?location=-22.912172%2C-43.192131%2C14.20
# Lendo shapefile:
sf_vlt <- st_read("input/data_raw/shapefiles/Trajetos_VLT/Trajetos_VLT.shp") %>%
  st_combine()
# Salvando
write_rds(sf_vlt,"input/data_processed/plot_layers/sf_vlt.RDS")


# Pontos de referência
# Carregando limites dos bairros
bairros  <- st_read("input/data_raw/shapefiles/Limite_de_Bairros/Limite_de_Bairros.shp")
# Filtrando Bairros de interesse
bairros_filtro <- c("Bangu",
                    "Barra da Tijuca",
                    "Campo Grande",
                    "Centro",
                    "Guaratiba",
                    "Jacarepaguá",
                    "Madureira",
                    "Méier",
                    "Pavuna",
                    "Penha",
                    "Santa Cruz",
                    "Tijuca",
                    "Copacabana",
                    "Rocinha",
                    "Maré")
# Ajustando a Ilha do Governador
ilha_gov <- bairros %>%
  group_by(rp) %>%
  summarise(geometry = st_union(geometry)) %>%
  filter(rp == "Ilha do Governador") %>%
  rename(nome = rp) %>%
  st_centroid()
# Pegando apenas o centroide dos bairros
pts_referencia <- bairros %>%
  st_centroid() %>%
  filter(nome %in% bairros_filtro) %>%
  select(nome, geometry) %>%
  bind_rows(ilha_gov)
# Limpando
rm(bairros, bairros_filtro, ilha_gov)
# Salvando
write_rds(pts_referencia,"input/data_processed/plot_layers/pts_referencia.RDS")


# Municípios do Estado do RJ
# Baixando os municípios do Estado do RJ
municipios_rj <- read_municipality(code_muni = 33)
# Salvando
write_rds(municipios_rj,"input/data_processed/plot_layers/municipios_rj.RDS")


# Baixando os dados de uso do solo do Rio de Janeiro
landuse_rio <- read_landuse(city = "Rio de Janeiro", geometry = TRUE)
# Salvando
write_rds(landuse_rio,"input/data_processed/plot_layers/landuse_rio.RDS")
