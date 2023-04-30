# Calculando matriz de tempo de deslocamento
# DEPOIS da intervenção

# Esse é script para realizar o cálculo da matriz de tempo de deslocamento
# e os indicadores de acessibilidade.


library(tidyverse)
library(r5r)


# Alocando memória para o Java
options(java.parameters = "-Xmx3G")
# Definindo semente para reprodutibilidade
set.seed(999)

# Local onde encontram-se os arquivos a serem utilizados
folder <- "input/data_processed/analise_impacto/depois"

# Conexão com o r5
conexao_r5 <- setup_r5(folder)

# Lendo o arquivo de pontos de partida
origin_points <- read.csv(file.path(folder,"origin_points.csv"))

# Lendo o arquivo de pontos de destino
destiny_points <- read.csv(file.path(folder,"destiny_points.csv"))

# Calculando a matriz de tempo de deslocamento
{computation_time <- system.time(
  ttm_depois <- travel_time_matrix(
    conexao_r5,
    origins = origin_points,
    destinations = destiny_points,
    mode = c('WALK','TRANSIT'),
    departure_datetime = as.POSIXct(
      '16-01-2023 06:00:00',
      format = '%d-%m-%Y %H:%M:%S'
    ),
    max_walk_time = 30,
    max_trip_duration = 180,
    time_window = 120,
    verbose = FALSE,
    progress = FALSE
  )
)
  
  # Informa o tempo que levou para calcular  
  paste('Travel time matrix computed in',
        round(computation_time[["elapsed"]]/60,2),
        'minutes.')}

# Salvando os resultados
saveRDS(ttm_depois,"input/data_processed/analise_impacto/ttm_depois.RDS")
