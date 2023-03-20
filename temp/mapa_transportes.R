library(sf)
library(tidyverse)
library(geobr)

sf_rio <- st_read("input/data_raw/shapefiles/Limites_Rio_de_Janeiro/Limites_Rio_de_Janeiro.shp")

sf_trem <- st_read("input/data_raw/shapefiles/Trajetos_Trem/Trajetos_Trem.shp")
sf_vlt <- st_read("input/data_raw/shapefiles/Trajetos_VLT/Trajetos_VLT.shp")
sf_onibus <- st_read("input/data_raw/shapefiles/Trajetos_Onibus/Trajetos_Onibus.shp") %>%
  st_transform(crs = 4674)
sf_brt <- st_read("input/data_raw/shapefiles/Trajetos_BRT/Trajetos_BRT.shp")


# Plotando os shapefiles
ggplot() +
  geom_sf(data = sf_rio) +
  geom_sf(data = sf_onibus, color = "grey") +
  geom_sf(data = sf_brt, linetype = "dotdash", color = "green") +
  geom_sf(data = sf_trem, linetype = "dashed", color = "red") +
  geom_sf(data = sf_vlt, linetype = "dotted", color = "blue")
  
