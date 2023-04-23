# Ler RDO do BRT


library(tidyverse)
library(readxl)
library(lubridate)


# Nomes das colunas da RDO
colunas_rdo <- c("TERMO",
                 "LINHA",
                 "SERVICO",
                 "TERMO2",
                 "TIPO _VEICULO",
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

# Definindo os anos de interesse
serie_historica <- 2015:2017

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
                          col_names = colunas_rdo) %>% 
      mutate(data = ymd(paste(ANO,MES,DIA, sep = "-"))) %>%
      group_by(data) %>%
      summarise(sistema = "BRT",
                total_pax_transportado = sum(TOTAL_PAX_TRANSPORTADO))
    
    # Unindo RDOs mensais para formar série histórica
    rdo <- bind_rows(rdo, rdo_mes) %>%
      filter(!is.na(data)) %>%
      distinct()
    
  }
  
}

# PRÓXIMOS PASSOS

# Explicar fonte dos dados
# Consertar problemas de padrão de dados a partir do ano de 2018