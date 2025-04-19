# linkage_funcoes.R

# Carrega pacotes
carregar_pacotes <- function() {
  if (!require(tidyverse)) install.packages("tidyverse"); library(tidyverse)
  if (!require(reclin2)) install.packages("reclin2"); library(reclin2)
  if (!require(digest)) install.packages("digest"); library(digest)
  if (!require(knitr)) install.packages("knitr"); library(knitr)
  if (!require(DT)) install.packages("DT"); library(DT)
}

# Função de linkage genérico
fazer_linkage <- function(base_x, base_y, colunas, bloco = "sexo", limiar = 2.7) {
  pair_blocking(base_x, base_y, bloco) |>
    compare_pairs(
      on = colunas,
      default_comparator = jaro_winkler(0.9)
    ) |>
    mutate(simsum = rowSums(across(all_of(colunas)))) |>
    filter(simsum >= limiar)
}


# Importa as funções do outro arquivo
source("/home/pamela/Documentos/Linkage_Data_Health/src/teste.R")

# Primeiro, apenas carrega os pacotes e lê os dados
carregar_pacotes()

# Leitura dos dados
sivep_dedup <- read_csv2("/home/pamela/Documentos/Linkage_Data_Health/DATA/SIVEP_DEDUP.csv")
do_rosas <- read_csv2("/home/pamela/Documentos/Linkage_Data_Health/DATA/DO_ROSAS.csv")

# Agora, tenta rodar a função do linkage
p5 <- fazer_linkage(sivep_dedup, do_rosas, colunas = c("nome", "data_nasc", "nome_mae"))

# Verifique o conteúdo de p5 antes de chamar add_from_x ou add_from_y
print(head(p5))

# Depois que verificar, pode adicionar as funções de adição
p5 <- p5 |>
  add_from_x(nu_not = "nu_notific") |>
  add_from_y(nu_do = "nu_do")

# Visualize
datatable(p5)