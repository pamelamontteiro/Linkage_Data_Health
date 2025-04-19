if(!require(tidyverse)) install.packages("tidyverse");library(tidyverse)
if(!require(reclin2)) install.packages("reclin2");library(reclin2)
if(!require(digest)) install.packages("digest");library(digest)
if(!require(knitr)) install.packages("knitr");library(knitr)
if(!require(DT)) install.packages("DT");library(DT)
if(!require(dplyr)) install.packages("dplyr");library(dplyr)
if(!require(tibble)) install.packages("tibble");library(tibble)


sivep <- read_csv2("/home/pamela/Documentos/Linkage_Data_Health/DATA/sivep_identificado.csv")



DT::datatable(head(sivep, 100))






# 2. Gerando e filtrando os pares
pares_blocagem <- pair_blocking(x = sivep, y = sivep, on = "sexo", deduplication = TRUE)

pares_blocagem


# 3. Aplicando o método de linkage determinístico
p_deter <- pares_blocagem|>
  

  compare_pairs(on = c("nome", "data_nasc", "cpf", "nome_mae"))

# Instala e carrega o pacote tibble

library(tibble)

pares_iguais <- p_deter |>

  as_tibble() |>
 
  filter(nome & data_nasc & cpf & nome_mae)

pares_iguais




library(dplyr)
library(knitr)
pares_iguais
sivep |> 
  slice(pares_iguais$.x[1], pares_iguais$.y[1]) |> 
  kable()




# 4 Aplicando o método de linkage probabilístico

library(reclin2)

# Criando o objeto 'pares_link_prob' com o resultado do linkage probabilístico
pares_link_prob <- pares_blocagem |>
  
  compare_pairs(on = c("nome", "data_nasc", "cpf", "nome_mae"),
                default_comparator = jaro_winkler(threshold = 0.9))

# Visualizando o objeto com resultado do linkage
pares_link_prob



# Verificando as colunas existentes em pares_link_prob para escolher o identificador correto
colnames(pares_link_prob)



# Adicionando as variáveis de identificação diretamente no objeto pares_link_prob
pares_link_prob$nu_not_x <- pares_link_prob$nu_not  # Substituindo 'nome' por 'nu_not' (o identificador correto)
pares_link_prob$nu_not_y <- pares_link_prob$nu_not  # Da mesma forma, atribuindo o identificador correto à coluna 'nu_not_y'

# Verifique se as variáveis foram adicionadas corretamente
head(pares_link_prob)  # Exibe as primeiras linhas do objeto 'pares_link_prob' para garantir que as colunas 'nu_not_x' e 'nu_not_y' foram corretamente adicionadas



# Renomeando pares_link_prob para p3
p3 <- pares_link_prob

# Adicionando as variáveis de identificação diretamente em p3
p3$nu_not_x <- p3$nu_not  # Substituindo 'nome' por 'nu_not' (o identificador correto)
p3$nu_not_y <- p3$nu_not  # Da mesma forma, atribuindo o identificador correto à coluna 'nu_not_y'

# Verificando as primeiras linhas do objeto 'p3' para garantir que as colunas 'nu_not_x' e 'nu_not_y' foram corretamente adicionadas
head(p3)




# Adicionando as variáveis de identificação diretamente
p3$nu_not_x <- p3$nome   # Aqui, você está criando uma nova coluna chamada 'nu_not_x' em 'p3'.

p3$nu_not_y <- p3$nome # Da mesma forma, criando a coluna 'nu_not_y' que também usa a coluna 'nome'.

# Verifique se as variáveis foram adicionadas corretamente
head(p3)  



library(dplyr)
library(tibble)

# Verifique os nomes das colunas de similaridade (ex: nome, mae, nascimento)
colnames(p3)

p3$simsum <- rowSums(p3[, c("nome", "data_nasc", "cpf", "nome_mae")], na.rm = TRUE)

p3$select <- p3$simsum > 3.5

# Criar o objeto de duplicidades
reg_dup <- p3 |>
  as_tibble() |>
  filter(select) |>
  select(.x, .y, simsum, select, nu_not_x, nu_not_y) |>
  arrange(simsum)  # agora ordenando do maior para o menor simsum

# Visualizar o resultado
reg_dup




# Carregue o pacote necessário (caso ainda não tenha feito isso)
library(reclin2)

head(p3)

res <- deduplicate_equivalence(pairs = p3, variable = "select")

head(res)



res <- res |>
  rename(duplicate_groups = select)

# Criando um novo objeto com as duplicidades encontradas agrupadas
dup_grupos <- res |> 
  
  # Agrupando os registros de acordo com os códigos da coluna duplicate_groups
  group_by(duplicate_groups) |> 
  
  # Subagrupando a tabela de valores duplicados e salvando-os como uma lista em 
  # cada linha da nova coluna "data"
  nest() |> 
  
  # Criando uma nova coluna denominada "pares" com o número de registros em cada grupo
  mutate(pares = map_dbl(data, nrow))

# Visualizando os primeiros grupos de duplicados encontrados
dup_grupos


# Cria um novo objeto chamado 'lista_dup' que irá conter todos os registros que 
# pertencem a grupos com mais de um indivíduo (ou seja, possíveis duplicatas)
lista_dup <- dup_grupos |>
  
  filter(pares > 1) |> 
  
  unnest(data) 

kable(head(lista_dup))





# Salvando a lista de duplicidades em um arquivo CSV
# A função write_csv2() é usada para escrever a tabela 'lista_dup' em um arquivo CSV.
# O argumento 'file' especifica o nome do arquivo de saída. Usamos o formato CSV com ponto e vírgula como delimitador (CSV2).
write_csv2(lista_dup, file = 'lista_duplicidades.csv')



