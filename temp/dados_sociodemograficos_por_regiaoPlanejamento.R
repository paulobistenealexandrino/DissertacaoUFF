# Associa hexágonos a Regiões de Planejamento


library(tidyverse)
library(sf)
library(geobr)
library(aopdata)


# Baixa o shapefile dos bairros do Rio
bairros  <- st_read("input/data_raw/shapefiles/Limite_de_Bairros/Limite_de_Bairros.shp")
# Agrega por RP
regioes_planejamento <- bairros %>%
  group_by(rp) %>%
  summarise(geometry = st_union(geometry))
# Remove o dataset original
rm(bairros)


# Baixa a malha hexagonal do RJ
landuse_rio <- read_landuse(city = "Rio de Janeiro", geometry = TRUE) %>%
  filter(P001 > 0) %>%
  st_transform(st_crs(regioes_planejamento))

# Centroides dos hexágonos
hex_centroids <- landuse_rio %>%
  st_centroid() %>%
  st_transform(st_crs(regioes_planejamento))

# Associando informações dos hexágonos às RPs pelo centroide
landuse_rp <- st_intersection(hex_centroids, regioes_planejamento)
rm(hex_centroids)

# Alguns hexágonos não foram associados, pois seu centroide
# encontra-se fora dos limites das RPs
# Quais são?
nao_associados <- landuse_rio %>%
  filter(!(id_hex %in% landuse_rp$id_hex))

# Associando hexágono à RP
landuse_rp_aux <- st_intersection(nao_associados, regioes_planejamento)
# Algum hexágono foi associado a mais de uma RP
# Quais?
repetidos <- landuse_rp_aux %>%
  group_by(id_hex) %>%
  summarise(n = n()) %>%
  filter(n > 1) %>%
  st_drop_geometry()
repetidos <- repetidos$id_hex

# Removendo Repetidos
landuse_rp_aux <- landuse_rp_aux %>%
  filter(!(id_hex %in% repetidos))

# Juntando 
landuse_regioes_plan <- bind_rows(landuse_rp, landuse_rp_aux)
rm(landuse_rp, landuse_rp_aux, nao_associados, repetidos)


# Construindo dataset para análise
regioes_plan_sociodemograficos <- landuse_regioes_plan %>%
  st_drop_geometry() %>%
  select(rp, P001, T001, R001) %>%
  group_by(rp) %>%
  summarise(populacao = sum(P001),
            postos_trabalho = sum(T001),
            renda_media = mean(R001)) %>%
  mutate(trab_per_cap = postos_trabalho/populacao,
         percent_postos = 100*postos_trabalho/sum(postos_trabalho)) 


# Unindo informações
regioes_planejamento <- regioes_planejamento %>%
  left_join(regioes_plan_sociodemograficos)

# Construindo mapa
ggplot() +
  geom_sf(data = regioes_planejamento, aes(fill = percent_postos)) +
  geom_sf_text(data = regioes_planejamento, aes(label = rp), size = 2)
