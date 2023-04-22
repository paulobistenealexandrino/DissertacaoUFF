# Criando um mapa de calor da densidade populacional do Rio de Janeiro


library(tidyverse)
library(sf)
library(ggspatial)


# Definindo local onde estão localizados arquivos
path <- "input/data_processed/plot_layers/"

# Carregando função zoom_bounds
source("temp/zoom_bounds.R")


# Carregando os layers do mapa

# Linhas de Ônibus 
sf_onibus <- readRDS(paste0(path,"sf_onibus.RDS"))

# Linhas BRT
sf_brt <- readRDS(paste0(path,"sf_brt.RDS"))

# Linhas Trem
sf_trem <- readRDS(paste0(path,"sf_trem.RDS"))

# Linhas Metro
sf_metro <- readRDS(paste0(path,"sf_metro.RDS"))

# Linhas VLT
sf_vlt <- readRDS(paste0(path,"sf_vlt.RDS"))

# Pontos de referência
pts_referencia <- readRDS(paste0(path,"pts_referencia.RDS"))

# Municípios do Estado do RJ
municipios_rj <- readRDS(paste0(path,"municipios_rj.RDS"))

# Uso do solo cidade Rio de Janeiro
landuse_rio <- readRDS(paste0(path,"landuse_rio.RDS"))


# Densidade populacional em mil hab/km2
# Área dos hexágonos: 0.1083603 km2
landuse_rio <- landuse_rio %>%
  mutate(densidade_pop = P001/(0.1083603*10^3))


# Construindo mapa
gg_populacao <- ggplot() +
  
  # Plotando os municípios do Estado
  geom_sf(data  = municipios_rj, 
          fill="grey96", 
          colour = "grey80") +
  
  # Destacando cidade do Rio
  geom_sf(data  = municipios_rj %>% 
            filter(name_muni == "Rio De Janeiro")) +
  
  # Inserindo as camadas com os transportes
  geom_sf(data = sf_onibus, color = "azure4") +
  geom_sf(data = sf_brt, color = "azure4") +
  geom_sf(data = sf_trem, color = "azure4") +
  geom_sf(data = sf_metro, color = "azure4") +
  geom_sf(data = sf_vlt, color = "azure4") +
  
  # Dados de densidade populacional
  geom_sf(data = landuse_rio, 
          aes(fill = densidade_pop),
          color = NA) +
  scale_fill_gradientn(colors = c(NA, inferno(10)),
                       guide = guide_colorbar(direction = "horizontal")) +
  
  # Destacando a cidade do Rio
  geom_sf(data  = municipios_rj %>% 
            filter(name_muni == "Rio De Janeiro"),
          fill = NA) +
  
  # Pontos de referência
  # geom_sf_text(data = pts_referencia, size = 2, aes(label = nome)) +
  
  # Centralizando o mapa no Rio
  coord_sf(xlim = zoom_bounds(coords = "lon"), 
           ylim = zoom_bounds(coords = "lat")) +
  
  # Inserindo rosa-dos-ventos
  annotation_north_arrow(location = "bl", 
                         which_north = "true",
                         style = north_arrow_fancy_orienteering,
                         height = unit(.75, "cm"),
                         width = unit(.75, "cm")) +
  # Inserindo escala
  #annotation_scale(location = "br", height = unit(0.1, "cm")) +
  
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
        legend.position = c(0.5, 0.925),
        rect = element_rect(fill = NA))

# Removendo variáveis
remover <- c("landuse_rio",
             "municipios_rj",
             "pts_referencia",
             "sf_brt",
             "sf_metro",
             "sf_onibus",
             "sf_trem",
             "sf_vlt",
             "path",
             "zoom_bounds")
rm(list = c(remover,"remover"))