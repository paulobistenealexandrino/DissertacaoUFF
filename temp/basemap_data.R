# Criando um mapa de calor da densidade populacional por raça
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