# Criar série histórica da demanda por serviços de ônibus


library(tidyverse)
library(lubridate)
library(bizdays)


# Carregando arquivos
rdo_brt <- read_csv2(file = "input/data_processed/rdo_brt.csv")
rdo_sppo <- read_csv2(file = "input/data_processed/rdo_sppo.csv")

# Carregando lista dos feriados
dias_uteis_br <- bizseq("2015-01-01", "2022-08-31", "Brazil/ANBIMA")

feriados_rio <- c(as.Date(paste0(2015:2022,"-01-20")),
                  as.Date(paste0(2015:2022,"-04-23")),
                  as.Date(paste0(2015:2022,"-11-25")))

dias_uteis_rio <- dias_uteis_br[!(dias_uteis_br %in% feriados_rio)]

# Unindo as duas bases
demanda_dias_uteis <- bind_rows(rdo_brt, rdo_sppo) %>%
  rename(TOTPAS = TOTAL_PAX_TRANSPORTADO) %>%
  filter(DATA %in% dias_uteis_rio)

# Montando gráfico
ggplot(demanda_dias_uteis, aes(x = DATA, y = TOTPAS/10^6)) +
  geom_vline(xintercept = as.Date("2020-03-16"),
             linetype = "dotted") +
  geom_line(aes(color = SISTEMA)) +
  labs(color = "Sistema") +
  xlab("Ano") +
  ylab("Passageiros Transportados (milhões)") +
  theme_classic()  +
  theme(legend.position = "top",
        legend.title = element_blank())

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

# Ajustando a legenda dos sistemas
demanda_mensal$SISTEMA <- factor(demanda_mensal$SISTEMA)
levels(demanda_mensal$SISTEMA) <- c("BRT", "Convencional")

# Gráfico da demanda média nos dias úteis por mês
demanda_mensal %>%
ggplot(aes(x = data, y = media_pax_dia/10^3)) +
  geom_line(aes(color = SISTEMA)) +
  scale_x_date(date_breaks = "year",
               labels = scales::date_format(format = "%Y")) +
  labs(color = "Sistema") +
  xlab("Ano") +
  ylab("Passageiros Transportados (milhares)") +
  theme_classic()  +
  theme(legend.position = "top",
        legend.title = element_blank())

# Variação percentual após pandemia (mensal)

# BRT
brt_mar2020 <- as.numeric(demanda_mensal[125,3])
brt_abr2020 <- as.numeric(demanda_mensal[127,3])
round(100*(brt_abr2020 - brt_mar2020)/brt_mar2020, digits = 1)

# Convencional
conv_mar2020 <- as.numeric(demanda_mensal[126,3])
conv_abr2020 <- as.numeric(demanda_mensal[128,3])
round(100*(conv_abr2020 - conv_mar2020)/conv_mar2020, digits = 1)

# Média diária de passageiros 2019-2020
demanda_anual <- bind_rows(rdo_brt, rdo_sppo) %>%
  rename(TOTPAS = TOTAL_PAX_TRANSPORTADO) %>%
  filter(year(DATA) %in% 2019:2020) %>%
  group_by(year(DATA), SISTEMA) %>%
  summarise(media_diaria = mean(TOTPAS)) %>%
  mutate(media_diaria = round())

# Variação percentual após pandemia (anual)

# BRT
brt_2019 <- as.numeric(demanda_anual[1,3])
brt_2020 <- as.numeric(demanda_anual[3,3])
round(100*(brt_2020 - brt_2019)/brt_2019, digits = 1)

# Convencial
conv_2019 <- as.numeric(demanda_anual[2,3])
conv_2020 <- as.numeric(demanda_anual[4,3])
round(100*(conv_2020 - conv_2019)/conv_2019, digits = 1)
