# Estima a média diária de passageiros em 2022


library(tidyverse)
library(lubridate)

# Carregando arquivos
rdo_brt <- read_csv2(file = "input/data_processed/rdo_brt.csv")
rdo_sppo <- read_csv2(file = "input/data_processed/rdo_sppo.csv")

# Criando a série histórica para uma análise mensal
demanda_mensal <- bind_rows(rdo_brt, rdo_sppo) %>%
  rename(TOTPAS = TOTAL_PAX_TRANSPORTADO) %>%
  mutate(ano = year(DATA),
         mes = month(DATA)) %>%
  select(ano, mes, SISTEMA, TOTPAS) %>%
  group_by(ano, mes, SISTEMA) %>%
  summarise(media_pax_dia = mean(TOTPAS)) %>%
  mutate(data = ym(paste(ano, mes, sep = "-"))) %>%
  ungroup() %>%
  select(data, SISTEMA, media_pax_dia)

# Existe uma inconsistência nos dados:
# A informação da RDO do BRT para o mês de março/2022, refere-se
# na verdade na RDO do SPPO. Por isso, será necessário imputar dados.
# Será utilizada a média entre os meses de fev e abr/2022.

fev_2022 <- as.numeric(demanda_mensal[171,3])
abr_2022 <- as.numeric(demanda_mensal[175,3])

demanda_mensal[173,3] <- mean(c(abr_2022,fev_2022))

# Média para imputação de 2022
demanda2022 <- demanda_mensal %>%
  filter(year(data) == 2022) %>%
  group_by(year(data), SISTEMA) %>%
  summarise(mean(media_pax_dia))

round(as.numeric(demanda2022[1,3]), digits = 4)
