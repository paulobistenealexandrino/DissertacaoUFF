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
  theme(legend.position = "top")
