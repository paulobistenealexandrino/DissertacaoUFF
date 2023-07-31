# Gera gráficos de demanda do sistema de ônibus com 2 eixos Y
# Média Diária por Ano


library(tidyverse)
library(lubridate)
library(patchwork)

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

# Dividindo a base de dados
# BRT
demanda_anual_brt <- demanda_anual %>%
  filter(sistema == "BRT")

# Convencional
demanda_anual_conv <- demanda_anual %>%
  filter(sistema == "Convencional")

# Gráfico demanda Convencional
p1 <- demanda_anual_conv %>%
  ggplot(aes(x = data, y = media_pax_dia/10^3)) +
  geom_line(color = "red")  +
  scale_x_date(date_breaks = "year",
               labels = scales::date_format(format = "%Y")) +
  labs(color = "Sistema") +
  xlab("Ano") +
  ylab("Passageiros Transportados nos Ônibus Convencionais \n (milhares)") +
  theme_classic()  +
  theme(legend.position = "top",
        legend.title = element_blank())

# Gráfico demanda BRT
p2 <- demanda_anual_brt %>%
  ggplot(aes(x = data, y = media_pax_dia/10^3)) +
  geom_line(color = "blue")  +
  scale_x_date(date_breaks = "year",
               labels = scales::date_format(format = "%Y")) +
  labs(color = "Sistema") +
  xlab("Ano") +
  ylab("Passageiros Transportados no BRT \n (milhares)") +
  theme_classic()  +
  theme(legend.position = "top",
        legend.title = element_blank())

# Mostrando gráficos lado a lado
p1 + p2
