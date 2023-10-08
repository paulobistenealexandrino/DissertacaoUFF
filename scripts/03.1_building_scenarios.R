# Constroi os cenários para análise de acessibilidade

# Esse cenário extra foi sugerido após a defesa da dissertação
# Ele contém apenas as linhas que, na média, cumpriram o critério mínimo
# necessário para o pagamento do subsídio

library(gtfstools)
library(tidyverse)
library(readxl)

### Cenários


## DEPOIS (23 linhas com >= 80% de cumprimento do plano operacional)

# Cria pasta do cenário
dir.create("input/data_processed/analise_impacto/depois23linhas")

# Traz arquivos para a pasta

# Malha Viário
file.copy(from = "input/data_raw/r5r/Malha_Viária_Rio_de_Janeiro.osm.pbf",
          to = "input/data_processed/analise_impacto/depois23linhas/Malha_Viária_Rio_de_Janeiro.osm.pbf")
# Origin points
file.copy(from = "input/data_raw/r5r/origin_points.csv",
          to = "input/data_processed/analise_impacto/depois23linhas/origin_points.csv")
# Destiny points
file.copy(from = "input/data_raw/r5r/destiny_points.csv",
          to = "input/data_processed/analise_impacto/depois23linhas/destiny_points.csv")


# GTFS

# É necessário filtrar as linhas que, na média, cumpriram
# MENOS de 80% do plano operacional necessário ao recebimento do subsídio.

# Lendo GTFS
gtfs_rio <- read_gtfs("input/data_raw/r5r/gtfs_rj_merged.zip")

# Criando lista das linhas que retornaram e tiveram menos de 80% para excluí-las
linhas_retomadas <- read_excel("input/data_raw/64linhas.xlsx")
lista_linhas_retomadas_menor80 <- linhas_retomadas %>%
  filter(percent_cumprido < 0.8) %>%
  select(short_name)
lista_linhas_retomadas_menor80 <- as_vector(lista_linhas_retomadas_menor80)

# Pegando o id das linhas retomadas que tiveram menos de 80%
route_id_retomadas_menor80 <- gtfs_rio$routes %>%
  filter(route_short_name %in% lista_linhas_retomadas_menor80) %>%
  select(route_id) %>%
  as_vector()

# Filtrando GTFS
gtfs_rio_depois23 <- filter_by_route_id(gtfs_rio,
                                     route_id = route_id_retomadas_menor80,
                                     keep = FALSE)
# Salvando GTFS na pasta destino
write_gtfs(gtfs_rio_depois23, 
           path = "input/data_processed/analise_impacto/depois23linhas/gtfs_rio_depois23.zip")
