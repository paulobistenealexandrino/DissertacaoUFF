# Definindo trajeto das linhas que retornaram


library(tidyverse)
library(sf)
library(gtfstools)
library(readxl)

# Lendo GTFS
gtfs_path <- "input/data_raw/r5r/gtfs_rio-de-janeiro.zip"
gtfs_rio <- read_gtfs(gtfs_path)

# Criando lista das linhas que retornaram para excluí-las
linhas_retomadas <- read_excel("input/data_raw/64linhas.xlsx")
lista_linhas_retomadas <- linhas_retomadas %>% select(short_name)
lista_linhas_retomadas <- as_vector(lista_linhas_retomadas)

# Pegando o id das linhas retomadas
route_id_retomadas <- gtfs_rio$routes %>%
  filter(route_short_name %in% lista_linhas_retomadas) %>%
  select(route_id) %>%
  as_vector()

# Filtrando GTFS
linhas_retomadas_gtfs <- filter_by_route_id(gtfs_rio,
                                     route_id = route_id_retomadas)

# Pegando shapefile das linhas
sf_linhas_retomadas <- get_trip_geometry(linhas_retomadas_gtfs, file = "shapes")

plot(sf_linhas_retomadas)

# Salvando
write_rds(sf_linhas_retomadas, "input/data_processed/plot_layers/sf_64linhas.RDS")
