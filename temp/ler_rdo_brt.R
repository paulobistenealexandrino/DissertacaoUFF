# Ler RDO do BRT


library(tidyverse)
library(readxl)
library(lubridate)

# Fonte dos dados:
# Relatório Diário de Operações (2015-2022)
# Disponível em: https://www.data.rio/documents/PCRJ::relat%C3%B3rio-di%C3%A1rio-de-opera%C3%A7%C3%B5es-rdo-sppo-%C3%B4nibus-comum-e-brt/about

# Nomes das colunas da RDO
colunas_rdo <- c("TERMO",
                 "LINHA",
                 "SERVICO",
                 "TERMO2",
                 "TIPO_VEICULO",
                 "ANO",
                 "MES",
                 "DIA",
                 "TARIFA_CODIGO",
                 "TARIFA_VALOR",
                 "FROTA_DETERMINADA",
                 "FROTA_LICENCIADA",
                 "FROTA_OPERANTE",
                 "VIAGEM_REALIZADA",
                 "KM",
                 "GRATUIDADE_IDOSO",
                 "GRATUIDADE_ESPECIAL",
                 "GRATUIDADE_ESTUDANTE_FEDERAL",
                 "GRATUIDADE_ESTUDANTE_ESTADUAL",
                 "GRATUIDADE_ESTUDANTE_MUNICIPAL",
                 "GRATUIDADE_RODOVIARIO",
                 "GRATUIDADE_TOTAL",
                 "BUC_PERNA1",
                 "BUC_PERNA2",
                 "BUC_RECEITA",
                 "BUC_SUPERVIA_PERNA1",
                 "BUC_SUPERVIA_PERNA2",
                 "BUC_SUPERVIA_RECEITA",
                 "VT_PAX_TRANSPORTADO",
                 "VT_RECEITA",
                 "ESPECIE_PAX_TRANSPORTADO",
                 "ESPECIE_RECEITA",
                 "TOTAL_PAX_TRANSPORTADO",
                 "TOTAL_RECEITA",
                 "TIPO_INFO",
                 "UNIVERSITARIO")

# Classes das colunas da RDO
classes_rdo <- c(rep("text",5),
                 rep("numeric",3),
                 "text",
                 rep("numeric",27))

# Definindo os anos de interesse
serie_historica <- 2015:2022

# Inicializando data frame vazio
rdo <- NULL

# Lendo as pastas por ano
for (ano in serie_historica) {
  
  # Definindo local de consulta dos arquivos
  minha_pasta <- file.path("input/data_raw/rdo",ano,"BRT")
  
  # Arquivos a serem lidos
  registros_mensais <- dir(minha_pasta)
  
  # Lendo arquivos por mês
  for (mes in registros_mensais) {
    
    # Endereço do arquivo a ser lido
    meu_arquivo <- file.path(minha_pasta,mes)
    
    # Carregando arquivo da RDO no mês
    rdo_mes <- read_excel(meu_arquivo,
                          skip = 3,
                          col_names = colunas_rdo,
                          col_types = "text")
    
    # Unindo RDOs mensais para formar série histórica
    rdo <- bind_rows(rdo, rdo_mes)
    
  }
  
}

# Salvando arquivo
write.csv2(rdo, 
           file = "input/data_processed/rdo_brt_2015a2022.csv",
           row.names = FALSE)
