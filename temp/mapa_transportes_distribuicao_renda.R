library(aopdata)
library(viridisLite)

landuse_rio <- read_landuse(city = "Rio de Janeiro", geometry = TRUE)
landuse_rio <- landuse_rio %>%
  mutate(R003 = if_else(R003 == 0, 1, as.double(R003)))

# Atribuindo cores para cada um dos modais
modes_colors <- c("Ônibus Convencional" = "magenta",
                  "BRT" = "cyan",
                  "Trem" = "darkgreen",
                  "Metrô" = "red",
                  "VLT" = "blue")

# Plotando mapa
ggplot() +
  
  # Plotando os municípios do Estado
  geom_sf(data  = municipios_rj, 
          fill="grey96", 
          colour = "grey80") +
  # Destacando a cidade do Rio
  geom_sf(data  = municipios_rj %>% 
            filter(name_muni == "Rio De Janeiro")) +
  # Destacando as características sociodemográficas
  geom_sf(data = subset(landuse_rio, !is.na(R003)), 
          aes(fill = factor(R003)),
          color = NA,
          alpha = .4) +
  scale_fill_manual(values = c("#403800",
                               "#554a00",
                               "#6a5d00",
                               "#806f00",
                               "#958200",
                               "#aa9400",
                               "#bfa700",
                               "#d5b900",
                               "#eacc00",
                               "#ffde00")) +
  
  # Inserindo as camadas com os transportes
  geom_sf(data = sf_onibus, aes(color = "Ônibus Convencional")) +
  geom_sf(data = sf_brt, linewidth = 0.75, aes(color = "BRT")) +
  geom_sf(data = sf_trem, linewidth = 0.75, aes(color = "Trem")) +
  geom_sf(data = sf_metro, linewidth = 0.75, aes(color = "Metrô")) +
  geom_sf(data = sf_vlt, linewidth = 0.75, aes(color = "VLT")) +
  # Atribuindo a escala com cores
  scale_color_manual(values = modes_colors,
                     breaks = c("Ônibus Convencional",
                                "BRT",
                                "Trem",
                                "Metrô",
                                "VLT")) +
  
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
  # Alterando nome da legenda
  labs(title = "Infraestrutura de Transportes e Distribuição de Renda",
       subtitle = "Município do Rio de Janeiro",
       caption = "Fonte: IBGE (2010), Ipea (2022), SMTR (2023). Elaboração: Paulo Alexandrino",
       color = "Modal",
       fill = "Renda Domiciliar per Capita Média \n (Decil) ") +
  
  # Ajustando tema
  theme_bw() + 
  theme(axis.text = element_blank(),
        axis.ticks = element_blank(),
        panel.grid.major = element_line(color = "grey80",
                                        linetype = "dashed",
                                        size = 0.5),
        panel.background = element_rect(fill = "aliceblue"),
        legend.position = "bottom")
