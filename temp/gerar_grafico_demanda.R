# Gera gráficos de demanda do sistema de ônibus


library(tidyverse)


# Ler o arquivo contendo a demanda média anual
demanda_anual <- read.csv2("input/data_raw/passageiros_onibus.csv")

demanda_anual <- demanda_anual %>%
  pivot_longer(!ano,
               names_to = "sistema",
               values_to = "media_pax_dia")

# 
