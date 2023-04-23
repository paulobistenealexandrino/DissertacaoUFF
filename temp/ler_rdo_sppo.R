# Ler RDO do SPPO


library(tidyverse)
library(readxl)
library(lubridate)


# Fonte dos dados:
# Relatório Diário de Operações (2015-2022)
# Disponível em: https://www.data.rio/documents/PCRJ::relat%C3%B3rio-di%C3%A1rio-de-opera%C3%A7%C3%B5es-rdo-sppo-%C3%B4nibus-comum-e-brt/about

# Lendo dicionário de variáveis
dicionario <- read.csv2("input/data_raw/rdo/dicionario_rdo.csv")

# Selecionando variáveis de interesse
# OBS: Todas as variáveis ficou muito pesado
vars_interesse <- dicionario %>%
  filter(CAMPO %in% c("ANO","MES","DIA","TOTPAS"))

# Definindo os anos de interesse
serie_historica <- 2015:2022

# Inicializando data frame vazio
rdo <- NULL

# Lendo as pastas por ano
for (ano in serie_historica) {
  
  # Definindo local de consulta dos arquivos
  minha_pasta <- file.path("input/data_raw/rdo",ano,"CONSÓRCIOS")
  
  # Arquivos a serem lidos
  registros_mensais <- dir(minha_pasta)
  
  # Lendo arquivos por mês para cada um dos consórcios
  for (consorcio_mes in registros_mensais) {
    
    # Endereço do arquivo a ser lido
    meu_arquivo <- file.path(minha_pasta, consorcio_mes)
    
    # Carregando arquivo da RDO no mês
    rdo_mes <- read_fwf(file = meu_arquivo,
                        col_positions = fwf_positions(start = vars_interesse$INICIO,
                                                      end = vars_interesse$FIM,
                                                      col_names = vars_interesse$CAMPO),
                        col_types = "dddd")
    
    # Unindo RDOs mensais para formar série histórica
    rdo <- bind_rows(rdo, rdo_mes)
    
  }
  
}

# Remover variáveis
rm(list = ls()[ls() != "rdo"])

# Série histórica RDO SPPO
rdo_sppo <- rdo %>%
  filter(!(is.na(ANO)| is.na(MES) | is.na(DIA))) %>%
  mutate(DATA = ymd(paste(ANO, MES, DIA, sep = "-"))) %>%
  filter(!is.na(DATA)) %>% 
  group_by(DATA) %>%
  summarise(SISTEMA = "SPPO",
            TOTAL_PAX_TRANSPORTADO = sum(TOTPAS))

# Salvando arquivo
write.csv2(rdo_sppo, 
           file = "input/data_processed/rdo_sppo.csv",
           row.names = FALSE)
