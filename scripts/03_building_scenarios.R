# Constroi os cenários para análise de acessibilidade


library(gtfstools)
library(tidyverse)
library(readxl)


# Criando pasta onde estarão os cenários
dir.create("input/data_processed/analise_impacto/")


### Cenários


## DEPOIS

# Cria pasta do cenário
dir.create("input/data_processed/analise_impacto/depois")

# Traz arquivos para a pasta

# Malha Viário
file.copy(from = "input/data_raw/r5r/Malha_Viária_Rio_de_Janeiro.osm.pbf",
          to = "input/data_processed/analise_impacto/depois/Malha_Viária_Rio_de_Janeiro.osm.pbf")
# Origin points
file.copy(from = "input/data_raw/r5r/origin_points.csv",
          to = "input/data_processed/analise_impacto/depois/origin_points.csv")
# Destiny points
file.copy(from = "input/data_raw/r5r/destiny_points.csv",
          to = "input/data_processed/analise_impacto/depois/destiny_points.csv")
# GTFS
file.copy(from = "input/data_raw/r5r/gtfs_rj_merged.zip",
          to = "input/data_processed/analise_impacto/depois/gtfs_rio_depois.zip")


# ANTES

# Cria pasta do cenário
dir.create("input/data_processed/analise_impacto/antes")

# Traz arquivos para a pasta

# Malha Viário
file.copy(from = "input/data_raw/r5r/Malha_Viária_Rio_de_Janeiro.osm.pbf",
          to = "input/data_processed/analise_impacto/antes/Malha_Viária_Rio_de_Janeiro.osm.pbf")
# Origin points
file.copy(from = "input/data_raw/r5r/origin_points.csv",
          to = "input/data_processed/analise_impacto/antes/origin_points.csv")
# Destiny points
file.copy(from = "input/data_raw/r5r/destiny_points.csv",
          to = "input/data_processed/analise_impacto/antes/destiny_points.csv")
# GTFS

# É necessário filtrar as linhas que foram incluídas
# na intervenção

# Lendo GTFS
gtfs_rio <- read_gtfs("input/data_raw/r5r/gtfs_rj_merged.zip")

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
gtfs_rio_antes <- filter_by_route_id(gtfs_rio,
                                     route_id = route_id_retomadas,
                                     keep = FALSE)

# Salvando GTFS na pasta destino
write_gtfs(gtfs_rio_antes, 
           path = "input/data_processed/analise_impacto/antes/gtfs_rio_antes.zip")
