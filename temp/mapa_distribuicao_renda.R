# Criando um mapa de calor da distribuição de renda
# do Rio de Janeiro


library(tidyverse)
library(sf)
library(ggspatial)
library(viridisLite)


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

# Baixando os dados de uso do solo do Rio de Janeiro
landuse_rio <- landuse_rio %>%
  mutate(R003 = if_else(R003 == 0, 1, as.double(R003)))

# Construindo mapa
gg_renda <- ggplot() +
  
  # Plotando os municípios do Estado
  geom_sf(data  = municipios_rj, 
          fill="grey96", 
          colour = "grey80") +
  
  # Destacando a cidade do Rio
  geom_sf(data  = municipios_rj %>% 
            filter(name_muni == "Rio De Janeiro")) +
  
  # Dados da distribuição de renda
  geom_sf(data = subset(landuse_rio, !is.na(R003)), 
          aes(fill = factor(R003)),
          color = NA) +
  scale_fill_manual(values = inferno(10),
                    guide = guide_legend(direction = "horizontal")) +
  
  # Inserindo as camadas com os transportes
  geom_sf(data = sf_onibus, color = "azure4") +
  geom_sf(data = sf_brt, color = "azure4") +
  geom_sf(data = sf_trem, color = "azure4") +
  geom_sf(data = sf_metro, color = "azure4") +
  geom_sf(data = sf_vlt, color = "azure4") +
  
  # Destacando a cidade do Rio
  geom_sf(data  = municipios_rj %>% 
            filter(name_muni == "Rio De Janeiro"),
          fill = NA) +

  # Centralizando o mapa no Rio
  coord_sf(xlim = zoom_bounds(coords = "lon"), 
           ylim = zoom_bounds(coords = "lat")) +
  
  # Inserindo rosa-dos-ventos
  #annotation_north_arrow(location = "bl", 
  #                       which_north = "true",
  #                       style = north_arrow_fancy_orienteering,
  #                       height = unit(.75, "cm"),
  #                       width = unit(.75, "cm")) +
  # Inserindo escala
  #annotation_scale(location = "br", height = unit(0.1, "cm")) +
  
  # Editando legenda
  labs(fill = "Renda Domiciliar per Capita Média (Decil) ") +
  
  # Editando tema
  theme_bw() + 
  theme(axis.text = element_blank(),
        axis.title = element_blank(),
        axis.ticks = element_blank(),
        panel.grid.major = element_line(color = "grey80",
                                        linetype = "dashed",
                                        size = 0.5),
        panel.background = element_rect(fill = "aliceblue"),
        legend.position = c(0.5, 0.075),
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
