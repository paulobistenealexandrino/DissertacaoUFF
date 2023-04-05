# Gerar Mapa de Transportes do Rio de Janeiro


library(tidyverse)
library(sf)
library(geobr)


# Limites Geográficos dos municípios do Estado do RJ
sf_rj_municipalities <- read_municipality(code_muni = 33)

# Limites Geográficos Rio de Janeiro
sf_rio <- st_read("input/data_raw/shapefiles/Limites_Rio_de_Janeiro/Limites_Rio_de_Janeiro.shp")

st_intersection(sf_rj_municipalities, polygon)
st_crs(polygon)

# Shapefiles dos transportes

# Trem
sf_trem <- st_read("input/data_raw/shapefiles/Trajetos_Trem/Trajetos_Trem.shp")
# VLT
sf_vlt <- st_read("input/data_raw/shapefiles/Trajetos_VLT/Trajetos_VLT.shp")
# Ônibus
sf_onibus <- st_read("input/data_raw/shapefiles/Trajetos_Onibus/Trajetos_Onibus.shp")
# BRT
sf_brt <- st_read("input/data_raw/shapefiles/Trajetos_BRT/Trajetos_BRT.shp")


# Plotando os shapefiles
ggplot() +
  geom_sf(data = sf_rj_municipalities) +
  geom_sf(data = sf_onibus, color = "grey") +
  geom_sf(data = sf_brt, linetype = "dotdash", color = "green") +
  geom_sf(data = sf_trem, linetype = "dashed", color = "red") +
  geom_sf(data = sf_vlt, linetype = "dotted", color = "blue") +
  xlim(c(-43.827588, -43.091552)) +
  ylim(c(-23.101184, -22.707933)) +
  geom_sf_text(data = sf_rj_municipalities, 
               aes(label = name_muni),
               size = 2) +
  theme()
