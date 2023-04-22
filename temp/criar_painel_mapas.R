# Cria o painel com os mapas de informações sociodemográficas do Rio


library(tidyverse)
library(sf)
library(ggspatial)
library(patchwork)


# Carregando mapas

# Densidade populacional
source("temp/mapa_densidade_populacional.R")
# Oportunidades de Emprego
source("temp/mapa_vagas_trabalho.R")
# Distribuição de renda
source("temp/mapa_distribuicao_renda.R")
# Distribuição racial
source("temp/mapa_residentes_negros.R")

# Criando painel de mapas
ggpainel <- (gg_populacao | gg_empregos) / (gg_renda | gg_racial)

ggpainel +
  plot_annotation(tag_levels = "A") &
  theme(plot.tag.position = c(0.05, 0.95))
