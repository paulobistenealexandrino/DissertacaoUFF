# Constroi o mapa de clusters LISA


library(tidyverse)
library(sf)
library(spdep)
library(rgeoda)


options(scipen = 10) # Ajusta a notação científica
set.seed(42)


# Lendo a base de dados de uso do solo já com os indicadores
# de acessibilidade
acess.rio <- read_rds("input/data_processed/acess_rio.RDS")
# Limpando a base de dados
acess.model <- acess.rio %>%
  filter(ratio > 0, R001 > 0, P001 > 0, P003 > 0, T001 > 0)

# Criando a matriz de pesos espaciais:
# Cria um arquivo do tipo neighboor
queen_wts <- queen_weights(acess.model)

# Calculando os clusters lisa
acess.lisa <- local_bimoran(queen_wts,
                            acess.model[c("R001","ratio")])

# Processando resultados
acess.model$cluster <- as.factor(acess.lisa$GetClusterIndicators())
levels(acess.model$cluster) <- acess.lisa$GetLabels()
acess.model$cluster <- factor(acess.model$cluster,
                              levels = c("Low-High",
                                         "Low-Low",
                                         "High-Low",
                                         "High-High",
                                         "Not significant",
                                         "Undefined",
                                         "Isolated"))

# Mapa LISA
# Interpretação (Renda-Ganho de Acessibilidade)

# Ajustando cores
cluster_colors <- c("Low-High" = "#ff0000",
                    "Low-Low" = "#ff9999",
                    "High-Low" = "#9999ff",
                    "High-High" = "#0000ff",
                    "Not significant" = "#606060")

# Filtrando os dados relevantes
acess.model_map <- acess.model %>%
  filter(!(cluster %in% c("Undefined", "Isolated")))


# Dados necessários ao mapa
source("temp/basemap_data.R")

# Construindo mapa
ggplot() +
  
  # Plotando os municípios do Estado
  geom_sf(data  = municipios_rj, 
          fill="grey96", 
          colour = "grey80") +
  
  # Destacando a cidade do Rio
  geom_sf(data  = municipios_rj %>% 
            filter(name_muni == "Rio De Janeiro")) +
  
  # Resultados do modelo LISA
  geom_sf(data = acess.model_map,
          color = NA,
          aes(fill = cluster)) +
  scale_fill_manual(values = cluster_colors) +
  
  # Destacando a cidade do Rio
  geom_sf(data  = municipios_rj %>% 
            filter(name_muni == "Rio De Janeiro"),
          fill = NA) +
  
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
  annotation_scale(location = "br", height = unit(0.1, "cm")) +
  
  # Editando legenda
  labs(fill = "LISA Cluster") +
  
  # Editando tema
  theme_bw() + 
  theme(axis.text = element_blank(),
        axis.title = element_blank(),
        axis.ticks = element_blank(),
        panel.grid.major = element_line(color = "grey80",
                                        linetype = "dashed",
                                        size = 0.5),
        panel.background = element_rect(fill = "aliceblue"),
        rect = element_rect(fill = NA))
