# Criando um mapa de calor da densidade populacional do Rio de Janeiro


library(tidyverse)
library(geobr)
library(sf)
library(ggspatial)
library(gtfstools)

# Organizando os shapefiles dos transportes

# Ônibus 
# Fonte: Data.Rio | GTFS do Rio de Janeiro
# Link: https://www.data.rio/datasets/gtfs-do-rio-de-janeiro/about
# Lendo GTFS
gtfs_path <- "input/data_raw/r5r/gtfs_rio-de-janeiro.zip"
rj_gtfs <- read_gtfs(gtfs_path)
# Pegando shapefile das linhas
sf_onibus <- get_trip_geometry(rj_gtfs, file = "shapes")
# Removendo arquivos auxiliares
rm(gtfs_path, rj_gtfs)

# BRT
# Fonte: Data.Rio | Trajetos BRT
# Link: https://www.data.rio/datasets/trajetos-brt/explore?location=-22.915687%2C-43.431850%2C11.49
# Lendo shapefile:
sf_brt <- st_read("input/data_raw/shapefiles/Trajetos_BRT/Trajetos_BRT.shp")
# Filtrando linhas inoperantes
sf_brt <- sf_brt %>%
  filter(flg_ativa == 1)

# Trem
# Fonte: Data.Rio | Trajetos Trem
# Link: https://www.data.rio/datasets/trajetos-trem/explore?location=-22.699543%2C-43.297792%2C9.35
# Lendo shapefile:
sf_trem <- st_read("input/data_raw/shapefiles/Trajetos_Trem/Trajetos_Trem.shp")

# Metro
# Fonte: Data.Rio | Estações Metrô
# Link: https://www.data.rio/datasets/esta%C3%A7%C3%B5es-metr%C3%B4/explore
# Utilizei o script "temp/gerar_shapefile_metro.R"
sf_metro <- read_rds("input/data_processed/sf_metro.RDS")

# VLT
# Fonte: Data.Rio | Trajetos VLT
# Link: https://www.data.rio/datasets/trajeto-vlt/explore?location=-22.912172%2C-43.192131%2C14.20
# Lendo shapefile:
sf_vlt <- st_read("input/data_raw/shapefiles/Trajetos_VLT/Trajetos_VLT.shp")

# Pontos de referência
bairros  <- st_read("input/data_raw/shapefiles/Limite_de_Bairros/Limite_de_Bairros.shp")

bairros_filtro <- c("Bangu",
                    "Barra da Tijuca",
                    "Campo Grande",
                    "Centro",
                    "Guaratiba",
                    "Inhaúma",
                    "Jacarepaguá",
                    "Madureira",
                    "Méier",
                    "Pavuna",
                    "Penha",
                    "Ramos",
                    "Santa Cruz",
                    "Tijuca",
                    "Copacabana",
                    "Rocinha",
                    "Maré")

ilha_gov <- bairros %>%
  group_by(rp) %>%
  summarise(geometry = st_union(geometry)) %>%
  filter(rp == "Ilha do Governador") %>%
  rename(nome = rp) %>%
  st_centroid()


pts_referencia <- bairros %>%
  st_centroid() %>%
  filter(nome %in% bairros_filtro) %>%
  select(nome, geometry) %>%
  bind_rows(ilha_gov)



# Baixando os municípios do Estado do RJ
municipios_rj <- read_municipality(code_muni = 33)

# Pegando o centroide da cidade do Rio para centralizar mapa
zoom_to <- municipios_rj %>% 
  filter(name_muni == "Rio De Janeiro") %>%
  st_centroid() %>%
  st_coordinates() %>%
  as.vector()

zoom_level <- 9

lon_span <- 360 / 2^zoom_level
lat_span <- 180 / 2^zoom_level

lon_bounds <- c(zoom_to[1] - lon_span / 2, zoom_to[1] + lon_span / 2)
lat_bounds <- c(zoom_to[2] - lat_span / 2, zoom_to[2] + lat_span / 2)


# Baixando os dados de uso do solo do Rio de Janeiro
landuse_rio <- read_landuse(city = "Rio de Janeiro", geometry = TRUE)

# Densidade populaiconal
landuse_rio <- landuse_rio %>%
  mutate(densidade_pop = P001/(0.1083603*10^3))

# Construindo mapa
ggplot() +
  
  # Plotando os municípios do Estado
  geom_sf(data  = municipios_rj, 
          fill="grey96", 
          colour = "grey80") +
  # Dados de densidade populacional
  geom_sf(data = landuse_rio, 
          aes(fill = densidade_pop),
          color = NA) +
  scale_fill_gradientn(colors = c("#e5e5e5","#f27373","#ff0000"),
                       guide = guide_colorbar(direction = "horizontal")) +
  # Destacando a cidade do Rio
  geom_sf(data  = municipios_rj %>% 
            filter(name_muni == "Rio De Janeiro"),
          fill = NA) +
  # Inserindo as camadas com os transportes
  geom_sf(data = sf_onibus, alpha = 0.5, color = "azure4") +
  geom_sf(data = sf_brt, alpha = 0.5, linewidth = 0.75, color = "azure4") +
  geom_sf(data = sf_trem, alpha = 0.5, linewidth = 0.75, color = "azure4") +
  geom_sf(data = sf_metro, alpha = 0.5, linewidth = 0.75, color = "azure4") +
  geom_sf(data = sf_vlt, alpha = 0.5, linewidth = 0.75, color = "azure4") +
  # Pontos de referência
  geom_sf_text(data = pts_referencia, size = 3, aes(label = nome)) +
  # Centralizando o mapa no Rio
  coord_sf(xlim = lon_bounds, 
           ylim = lat_bounds) +
  
  # Inserindo rosa-dos-ventos
  annotation_north_arrow(location = "bl", 
                         which_north = "true",
                         style = north_arrow_fancy_orienteering,
                         height = unit(.75, "cm"),
                         width = unit(.75, "cm")) +
  # Inserindo escala
  annotation_scale(location = "br", height = unit(0.1, "cm")) +
  
  # Editando legenda
  labs(fill = "Densidade Populacional (milhares/km²)") +
  # Editando tema
  theme_bw() + 
  theme(axis.text = element_blank(),
        axis.title = element_blank(),
        axis.ticks = element_blank(),
        panel.grid.major = element_line(color = "grey80",
                                        linetype = "dashed",
                                        size = 0.5),
        panel.background = element_rect(fill = "aliceblue"),
        legend.position = c(0.5, 0.05))
