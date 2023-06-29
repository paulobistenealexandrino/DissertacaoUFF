# Gera gráficos de demanda do sistema de ônibus


library(tidyverse)
library(lubridate)


# Ler o arquivo contendo a demanda média anual
demanda_anual <- read.csv2("input/data_raw/passageiros_onibus.csv") %>%
  pivot_longer(brt:convencional,
               names_to = "sistema",
               values_to = "media_pax_dia")

# Ajustando a variável ano
demanda_anual <- demanda_anual %>%
  mutate(data = ymd(paste0(ano,"-01-01"))) %>%
  select(data, sistema, media_pax_dia)

# Ajustando a variável sistema
demanda_anual$sistema <- factor(demanda_anual$sistema)
levels(demanda_anual$sistema) <- c("BRT", "Convencional")

# Montando gráfico
demanda_anual %>%
  ggplot() +
  geom_line(aes(x = data, y = media_pax_dia/10^3, color = sistema))  +
  scale_x_date(date_breaks = "year",
               labels = scales::date_format(format = "%Y")) +
  labs(color = "Sistema") +
  xlab("Ano") +
  ylab("Passageiros Transportados (milhares)") +
  theme_classic()  +
  theme(legend.position = "top",
        legend.title = element_blank())
