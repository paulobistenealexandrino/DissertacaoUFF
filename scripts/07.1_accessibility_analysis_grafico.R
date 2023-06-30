# Gera gráfico com a proporção de empregos acessíveis


library(tidyverse)
library(sf)


# Lendo a base de dados de uso do solo já com os indicadores
# de acessibilidade
acess_rio <- read_rds("input/data_processed/acess_rio.RDS")

# Gerando gráfico com a proporção dos empregos acessíveis
acess_rio %>%
  filter(!is.na(R003)) %>%
  ggplot() +
  geom_abline() +
  geom_point(aes(x = percent_antes, y = percent_depois, color = as.factor(R003), size = P001/1000),
             alpha = .6) +
  scale_color_brewer(palette = "RdBu") +
  scale_size_continuous(breaks = c(1, 5, 10)) +
  labs(color = "Decil Renda",
       size = "População \n (Milhares)") +
  xlab("% Empregos Acessíveis \n (Sem Linhas Retomadas)") +
  ylab("% Empregos Acessíveis \n (Com Linhas Retomadas)") +
  theme_classic()
