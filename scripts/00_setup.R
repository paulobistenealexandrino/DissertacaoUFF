## Set Up ##

# Esse é o script de configuração da análise.
# Aqui se encontra:

# 1. Pacotes
# 2. Ajustes de parâmetros
# 3. Funções 

# Sempre rodar ==>

{
  
  #### Pacotes ####
  
  library(tidyverse)
  library(geobr)
  library(aopdata)
  library(sf)
  library(r5r)
  library(fs)
  library(ggmap)
  
  #### Parâmetros ####
  
  options(java.parameters = "-Xmx2G")
  set.seed(999)
  
}

#### Funções ####
