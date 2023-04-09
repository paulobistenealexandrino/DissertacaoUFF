# Cria o shapefile do MetroRio a partir da localização das estações


library(tidyverse)
library(sf)


# Baixando a localização das estações
estacoes_metro <- st_read("input/data_raw/shapefiles/Estacoes_Metro/Estacoes_Metro.shp")

# Estações Linha 1
linha1 <- data.frame(
  nome = c(
    "Uruguai",
    "Saens Peña",
    "São Francisco Xavier",
    "Afonso Pena",
    "Estácio",
    "Praca Onze",
    "Central",
    "Presidente Vargas",
    "Uruguaiana",
    "Carioca",
    "Cinelândia",
    "Glória",
    "Largo do Machado",
    "Flamengo",
    "Botafogo",
    "Cardeal Arcoverde",
    "Siqueira Campos",
    "Cantagalo",
    "Ipanema / General Osório"
  )
) %>%
  left_join(estacoes_metro, by = "nome") %>%
  select(nome, geometry)
# Criando o shapefile da Linha 1
linha1 <- linha1 %>%
  st_as_sf() %>%
  st_coordinates() %>%
  st_linestring()

st_crs(linha1)

# Estações Linha 2
linha2 <- data.frame(
  nome = c(
    estacoes_metro$nome[1:15],
    "Central"
  )
) %>%
  left_join(estacoes_metro, by = "nome") %>%
  select(nome, geometry)
# Criando o shapefile da Linha 2
linha2 <- linha2 %>%
  st_as_sf() %>%
  st_coordinates() %>%
  st_linestring()

# Estações Linha 4
linha4 <- data.frame(
  nome = c(
    "Ipanema / General Osório",
    "Jardim de Alah",
    "Antero de Quental",
    "São Conrado",
    "Jardim Oceânico"
  )
) %>%
  left_join(estacoes_metro, by = "nome") %>%
  select(nome, geometry)
# Criando o shapefile da Linha 4
linha4 <- linha4 %>%
  st_as_sf() %>%
  st_coordinates() %>%
  st_linestring()


# Dataset com o shapefile do MetroRio
sf_metro <- data.frame(
  linha = c(
    "Linha 1",
    "Linha 2",
    "Linha 4"
  )
)
# Atribuindo os shapes
sf_metro$geometry = st_sfc(linha1, linha2, linha4)

# Transformando em coordenada UTM
st_crs(sf_metro) <- "+proj=utm +zone=23 +south +datum=WGS84"

# Transformar coordenadas em latitude e longitude
sf_metro <- st_transform(sf_metro, crs = 4674)

# Salvando
write_rds(sf_metro, "input/data_processed/sf_metro.RDS")
