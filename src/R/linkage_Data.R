if(!require(tidyverse)) install.packages("tidyverse");library(tidyverse)
if(!require(reclin2)) install.packages("reclin2");library(reclin2)
if(!require(digest)) install.packages("digest");library(digest)
if(!require(knitr)) install.packages("knitr");library(knitr)
if(!require(DT)) install.packages("DT");library(DT)
if(!require(dplyr)) install.packages("dplyr");library(dplyr)


# Carrega a função read_csv2 do pacote readr (caso o pacote ainda não tenha sido carregado, é necessário fazer library(readr))
# A função read_csv2() é utilizada para ler arquivos CSV que utilizam ponto e vírgula (;) como separador de colunas
# Esse é o padrão de separação de colunas em muitos arquivos CSV gerados em sistemas brasileiros, como os arquivos exportados de sistemas públicos de saúde

# Lê o arquivo chamado "sivep_identificado.csv" que está dentro da pasta "Dados"
# Este arquivo contém informações de internações por Síndrome Respiratória Aguda Grave (SRAG), incluindo casos de COVID-19
# A base foi extraída do sistema SIVEP-Gripe, utilizado para registrar e acompanhar esses casos no Brasil
# O nome do arquivo indica que os dados estão identificados (ou seja, possivelmente contêm nomes ou outros dados sensíveis que permitem identificar os pacientes)

# A função read_csv2() transforma esse arquivo CSV em um objeto do tipo data frame (ou tibble), que será armazenado na variável sivep
# Essa variável agora contém toda a base de dados de internações, e poderá ser manipulada, filtrada, cruzada com outras bases (como a de óbitos), analisada e visualizada

sivep <- read_csv2("/home/pamela/Documentos/Linkage_Data_Health/DATA/sivep_identificado.csv")




# Visualizando os 100 primeiros registros da base de dados "sivep"
# A função head() é usada para retornar as primeiras linhas de um data frame ou tibble
# No caso, estamos pedindo para exibir as primeiras 100 linhas do objeto "sivep"
# Isso é útil para ter uma visão geral das variáveis (colunas) disponíveis e seus valores iniciais
# Nos ajuda a entender a estrutura dos dados e verificar se a leitura do arquivo foi feita corretamente

# A função DT::datatable() é utilizada para criar uma tabela interativa no RStudio Viewer
# Esta função pertence ao pacote DT, que permite exibir data frames como tabelas dinâmicas com rolagem, ordenação e busca
# O "::" indica que estamos chamando a função datatable() diretamente do pacote DT (útil quando não usamos library(DT) antes)

# Esse passo é importante para a etapa de exploração dos dados (data exploration), fundamental antes de qualquer análise ou linkage
# As variáveis que iremos analisar neste dataset são:
# - nu_notific: número da notificação (provavelmente um identificador único do caso)
# - nome: nome completo da pessoa internada
# - sexo: sexo da pessoa
# - data_nasc: data de nascimento
# - idade: idade no momento da notificação
# - cpf: número do CPF (quando disponível)
# - nome_mae: nome da mãe (variável frequentemente usada em processos de linkage quando CPF está ausente ou incompleto)

# Ao analisar essas variáveis, poderemos futuramente cruzar essa base com outra (como a de óbitos) para verificar se os registros correspondem

DT::datatable(head(sivep, 100))






# 2. Gerando e filtrando os pares

# Realizando a blocagem dos dados pela variável "sexo"
# A função 'pair_blocking' do pacote 'reclin' é utilizada para blocar os dados
# especificando que a comparação será feita com base na variável "sexo".
# Isso ajuda a reduzir a quantidade de pares a serem comparados.
# O argumento 'deduplication = TRUE' indica que estamos realizando a deduplicação,
# ou seja, comparando o banco de dados consigo mesmo.
pares_blocagem <- pair_blocking(x = sivep, y = sivep, on = "sexo", deduplication = TRUE)
  

# Visualizando a tabela resultante da blocagem
# O objeto 'pares_blocagem' armazenará todos os pares de registros a serem comparados.
# O resultado dessa operação é um objeto que contém apenas os pares de registros
# com a variável "sexo" em comum. 
pares_blocagem

# A blocagem por "sexo" ajuda a reduzir a quantidade de pares de 52 milhões para 26 milhões,
# ou seja, diminui o espaço de busca para comparação, economizando recursos e tempo.
# Embora a redução de dimensão seja modesta, a variável "sexo" é confiável e pode melhorar
# a qualidade da comparação entre os registros.

# algumas informações sobre o processo de blocagem:

# - Simple blocking: indica que se trata de um método simples de blocagem, isto é, quando
#   os nomes das variáveis utilizadas são iguais entre si.
# - First data set e Second data set: número de registros em cada banco de dados.
#   Como neste exemplo comparamos a mesma base consigo própria, temos 10.196 registros.
# - Total number of pairs: indica o total de pares encontrados. Neste exemplo, foram encontrados
#   quase 26 milhões de pares compatíveis. Isto representa perto de 25% do total de pares que seriam
#   comparados caso todos os mais de 10 mil registros fossem comparados um a um.

# Após estas informações, o R retorna uma amostra da tabela listando as linhas que foram pareadas.
# Este objeto será utilizado nos próximos passos do linkage.








# 3. Aplicando o método de linkage determinístico

# Criando um objeto com o nome 'p_deter' para armazenar os resultados do linkage determinístico
# A partir do objeto 'pares_blocagem', realizamos a comparação entre os pares com base nas variáveis escolhidas.
p_deter <- pares_blocagem|>

  
  
  # Comparando os pares pelas variáveis de nome, data de nascimento, CPF e nome da mãe
  # A função 'compare_pairs' compara os registros do banco de dados com base nas variáveis especificadas.
  # Para o linkage determinístico, estamos verificando se há uma correspondência exata entre essas variáveis
  # nos pares de registros, retornando TRUE quando as variáveis coincidem e FALSE quando não.
compare_pairs(on = c("nome", "data_nasc", "cpf", "nome_mae"))


# Resultado esperado:
# O código acima irá gerar um objeto com as comparações, onde cada linha representará um par de registros
# e as variáveis "nome", "data_nasc", "cpf" e "nome_mae" serão comparadas entre si.
# Quando todas as variáveis para um par de registros forem iguais, o resultado será TRUE, indicando uma correspondência exata.
# Caso contrário, o resultado será FALSE, indicando que não há correspondência exata entre os registros.









# A biblioteca 'tibble' é parte do tidyverse e fornece uma forma moderna e mais legível
# de manipular e visualizar data frames. Diferente do data.frame padrão do R,
# os tibbles imprimem somente as primeiras linhas e colunas visíveis no console, facilitando a leitura.

# Instala e carrega o pacote dplyr, caso ainda não esteja instalado
if(!require(dplyr)) install.packages("dplyr")
library(dplyr)

# Instala e carrega o pacote tibble
install.packages("tibble")
library(tibble)

# Supondo que o objeto 'p_deter' foi gerado por um processo de linkage determinístico,
# ele contém os pares de registros comparados entre si e um valor lógico (TRUE/FALSE)
# para cada variável comparada (ex: nome, data de nascimento, CPF, nome da mãe),
# indicando se houve correspondência exata (TRUE) ou não (FALSE).

# Criando o objeto 'pares_iguais' com os pares de registros que apresentam correspondência perfeita
pares_iguais <- p_deter |>
  
  # Convertendo o objeto 'p_deter' em uma tibble (estrutura semelhante ao data.frame, porém mais legível)
  # Isso facilita a manipulação dos dados e melhora a exibição no console
  as_tibble() |>
  
  # Filtramos os pares que tiveram correspondência exata em todas as variáveis
  # Ou seja, onde nome, data_nasc, cpf e nome_mae são todos TRUE
  filter(nome & data_nasc & cpf & nome_mae)

# Exibimos os pares com correspondência perfeita
pares_iguais


# A saída será algo assim:
# # A tibble: 16 × 6
#        x     y nome  data_nasc cpf   nome_mae
#     <dbl> <int> <lgl> <lgl>     <lgl> <lgl>
#  1   528  3372 TRUE  TRUE      TRUE  TRUE
#  2   933  6984 TRUE  TRUE      TRUE  TRUE
#  3   978  3026 TRUE  TRUE      TRUE  TRUE
#  4  1023  9323 TRUE  TRUE      TRUE  TRUE
#  ...
#
# Cada linha da tabela representa um par de registros (linhas x e y das bases comparadas)
# que tiveram correspondência exata para todas as variáveis analisadas.
# Assim, os 16 pares listados são considerados **matchs perfeitos** segundo o critério determinístico.





library(dplyr)
library(knitr)
pares_iguais
sivep |> 
  # Selecionando no objeto SIVEP-Gripe a primeira linha dos registros duplicados 
  # no objeto `iguais` com a função slice()
  # Esse é o operador pipe (|>), que envia o resultado da expressão para a próxima função.
  # Aqui, começamos usando a base de dados `sivep`, que contém os registros originais de notificações de síndrome gripal.
  # Essa base contém os campos como: nu_notific (número de notificação), nome, sexo, data_nasc, cpf, nome_mae, entre outros.
  
  
  slice(pares_iguais$.x[1], pares_iguais$.y[1]) |> 
  # slice() é uma função do pacote dplyr que seleciona linhas específicas de uma tabela, com base em sua posição (índice).
  # Aqui estamos usando o objeto `pares_iguais`, que contém os pares de registros idênticos (matches perfeitos).
  # pares_iguais$x[1] e pares_iguais$y[1] são os índices das duas linhas que representam o primeiro par de registros duplicados.
  # pares_iguais$x[1] retorna o índice da primeira ocorrência (ex: 528)
  # pares_iguais$y[1] retorna o índice da segunda ocorrência (ex: 3372)
  # Ou seja, estamos extraindo da base `sivep` as duas linhas que formam o primeiro par duplicado identificado no linkage determinístico.
  # Exemplo: se x[1] = 528 e y[1] = 3372, ele seleciona essas duas linhas da base original `sivep`.
  
  
  kable()
# kable() é uma função do pacote knitr que formata os dados em uma tabela bonita para visualização.
# Ideal para deixar a apresentação dos dados mais organizada e clara.

#resultado
# A saída será algo assim:
# | nu_notific | nome                 | sexo     | data_nasc  | idade | cpf            | nome_mae           |
# |------------|----------------------|----------|------------|-------|----------------|--------------------|
# | 11885430   | Isabella Castro Melo  | feminino | 1991-08-26 | 30    | 460.393.107-74 | Jusara Castro Melo |
# | 39774953   | Isabella Castro Melo  | feminino | 1991-08-26 | 30    | 460.393.107-74 | Jusara Castro Melo |

# Esse é um exemplo de como o linkage determinístico identificou a duplicação entre dois registros (número de notificação diferentes),
# mas com todos os campos relevantes (nome, CPF, etc.) correspondendo perfeitamente, indicando que se trata da mesma pessoa.

# ➡️ Isso mostra que essas duas linhas (linha 528 e 3372 da base `sivep`) contêm exatamente os mesmos dados
# nas variáveis que usamos para o linkage: nome, data_nasc, cpf e nome_mae.

# ➡️ Isso confirma que são duplicatas perfeitas, ou seja, a mesma pessoa registrada mais de uma vez.

# 🔍 INTERPRETAÇÃO DOS RESULTADOS:
# Os dois registros exibidos representam a mesma pessoa, registrada duas vezes na base de dados `sivep`.
# Todas as informações relevantes usadas no linkage determinístico são idênticas:
# - nome: Isabella Castro Melo
# - data_nasc: 1991-08-26
# - cpf: 460.393.107-74
# - nome_mae: Jusara Castro Melo
# Os números das notificações (nu_notific) são diferentes: 11885430 e 39774953,
# o que indica que provavelmente são dois registros feitos em momentos diferentes ou em unidades distintas.
# As idades também coincidem: 30 anos.

# 💬 CONCLUSÃO:
# ✅ Esses dois registros são considerados um *match perfeito* no processo de linkage determinístico,
# pois apresentaram correspondência exata em todas as variáveis comparadas (nome, data_nasc, cpf, nome_mae).
# ✅ O linkage conseguiu identificar que se trata de uma duplicata da mesma pessoa,
# mesmo que com diferentes números de notificação.
# ✅ Esse tipo de análise é essencial para eliminar duplicações em bases de saúde,
# garantindo maior confiabilidade nas análises epidemiológicas e estatísticas.



#library(dplyr)
#library(knitr)
# Outro exemplo
#sivep |> 
  # Selecionando no objeto SIVEP-Gripe a nona linha dos registros duplicados 
  # no objeto `iguais` com a função slice()
  # Aqui, usamos a função `slice()` para selecionar as linhas que correspondem
  # ao nono par de registros duplicados armazenados no objeto `pares_iguais`.
  # O índice `pares_iguais$x[9]` refere-se à linha do primeiro registro (do par),
  # e `pares_iguais$y[9]` refere-se à linha do segundo registro (do par).
  # Ao selecionar essas duas linhas, estamos extraindo do banco de dados `sivep`
  # os dois registros considerados duplicados.
  #slice(pares_iguais$.x[9],pares_iguais$.y[9]) |> 
  
  # Visualizando a tabela com a função kable() 
  # O uso de `kable()` formata a visualização das linhas em uma tabela organizada
  # para facilitar a análise dos dados. É útil para gerar uma saída limpa e clara
 # kable()

# Resultado esperado:
# Aqui, dependendo do conteúdo de `pares_iguais`, podemos ver algo como:

# | nu_notific | nome                 | sexo     | data_nasc  | idade | cpf            | nome_mae           |
# |------------|----------------------|----------|------------|-------|----------------|--------------------|
# | 99874567   | João Silva Pereira    | masculino| 1985-06-15 | 36    | 123.456.789-00 | Maria Pereira      |
# | 99874568   | João Silva Pereira    | masculino| 1985-06-15 | 36    | 123.456.789-00 | Maria Pereira      |

# 💬 INTERPRETAÇÃO DOS RESULTADOS:
# Esses dois registros possuem exatamente os mesmos dados nas variáveis usadas para o linkage:
# nome, data_nasc, cpf e nome_mae. Apesar de serem registros duplicados,
# o número de notificação (nu_notific) é diferente: 99874567 e 99874568.
# Isso indica que foram feitos dois registros distintos, possivelmente em momentos diferentes
# ou por diferentes unidades de saúde, mas referindo-se à mesma pessoa.

# 🧐 POSSÍVEL AÇÃO:
# Com o resultado obtido, seria possível neste ponto simplesmente apagar da base `SIVEP-Gripe` do Estado de Rosas 
# todas as linhas correspondentes aos valores em `y`, visto que são idênticos ao menos para essas quatro variáveis (atributos).
# No entanto, é importante considerar que esse tipo de duplicação pode não ser um erro no banco de dados,
# pois pode refletir situações como reinfecções, reinternação ou transferências de pacientes para outros hospitais.

# 📊 CONSIDERAÇÕES SOBRE A VIGILÂNCIA EPIDEMIOLÓGICA:
# Como estamos lidando com dados de saúde, especialmente relacionados à síndrome gripal,
# a duplicação pode ocorrer por motivos legítimos, como o paciente sendo notificado mais de uma vez por diferentes motivos.
# Portanto, ao tratar os registros duplicados, é necessário analisar cuidadosamente o contexto 
# e as regras do sistema de informação, considerando fatores como:
# - Reinfeções ou reinternações: o paciente pode ter sido notificado mais de uma vez durante o acompanhamento.
# - Transferências de pacientes para outros hospitais: a duplicação pode ser uma consequência de registros de diferentes unidades de saúde.
# É fundamental que a vigilância epidemiológica tenha critérios bem definidos para lidar com esses casos de duplicação,
# decidindo se e quando remover registros ou tratá-los de outra forma no banco de dados.

# ✅ CONCLUSÃO:
# O processo de linkage determinístico ajudou a identificar esses casos de duplicação, mas agora é essencial que a equipe
# de saúde e os analistas de dados realizem uma revisão cuidadosa para garantir que os dados tratados sejam precisos e confiáveis,
# para uma análise correta e ações apropriadas no contexto da vigilância epidemiológica.


# Outro exemplo 2
# Exemplo de saída:
# | nu_notific | nome             | sexo      | data_nasc  | idade | cpf            | nome_mae      |
# |------------|------------------|-----------|------------|-------|----------------|---------------|
# | 14076116   | Vitor Lima Gomes | masculino | 1968-12-12 | 53    | 733.564.245-05 | Viviam Simoes |
# | 17166300   | Vitor Lima Gomes | masculino | 1968-12-12 | 63    | 733.564.245-05 | Viviam Simoes |

# 💬 INTERPRETAÇÃO DOS RESULTADOS:
# Nesse exemplo, observamos dois registros que pertencem à mesma pessoa, Vitor Lima Gomes, e apresentam 
# informações idênticas nas variáveis usadas para o linkage: nome, sexo, data de nascimento, cpf e nome da mãe.
# No entanto, a diferença está nos números de notificação (nu_notific) e na idade.
# Os números de notificação são diferentes (14076116 e 17166300), o que indica que esses dois registros 
# foram feitos em momentos distintos ou em unidades de saúde diferentes.
# Além disso, a idade do paciente também é ligeiramente diferente: 53 anos no primeiro registro e 63 anos no segundo.
# Essa diferença na idade pode ser um erro de digitação ou atualização do banco de dados.

# 🧐 POSSÍVEL AÇÃO:
# Em um caso como esse, a análise precisa ser mais detalhada:
# - Verifique o histórico completo dos registros e considere se há explicações plausíveis para as discrepâncias 
#   na idade, como a atualização incorreta do banco de dados ou o uso de uma idade diferente durante a notificação.
# - Considere que, em algumas situações, o paciente pode ter sido notificado em diferentes momentos de sua jornada de saúde, 
#   por exemplo, em situações de tratamento contínuo ou em hospitalizações subsequentes.

# 📊 CONSIDERAÇÕES SOBRE A VIGILÂNCIA EPIDEMIOLÓGICA:
# O processo de linkage determinístico identificou corretamente dois registros como pertencentes à mesma pessoa, 
# mas a análise deve levar em conta que a discrepância na idade pode ser um erro de registro.
# No caso de bases de dados sensíveis, como no SIVEP-Gripe, é importante ter um processo de verificação robusto 
# para garantir que as duplicações sejam tratadas de forma adequada, sem comprometer a qualidade dos dados.
# O sistema de informação precisa ter critérios claros para decidir se registros com pequenas discrepâncias 
# (como a idade) devem ser considerados duplicados ou se necessitam de uma revisão manual.

# ✅ CONCLUSÃO:
# Esse caso exemplifica a importância de realizar uma verificação detalhada ao tratar duplicações.
# A vigilância epidemiológica não deve apenas remover registros com base em correspondências perfeitas, 
# mas deve garantir que qualquer discrepância nos dados seja analisada dentro do contexto do sistema de informações
# e da situação clínica dos pacientes.






# 4 Aplicando o método de linkage probabilístico

library(reclin2)

# Criando o objeto 'pares_link_prob' com o resultado do linkage probabilístico
pares_link_prob <- pares_blocagem |>
  
  # Realizando o linkage probabilístico com a função compare_pairs()
  # A função compare_pairs() compara os pares de registros no objeto 'pares_blocagem'
  # Especificamos as variáveis a serem comparadas no argumento 'on' (nome, data_nasc, cpf, nome_mae)
  # E especificamos o método de similaridade para cada uma dessas variáveis com o argumento 'default_comparator'
  compare_pairs(on = c("nome", "data_nasc", "cpf", "nome_mae"),
                default_comparator = jaro_winkler(threshold = 0.9))

# Visualizando o objeto com resultado do linkage
pares_link_prob

# Explicações Detalhadas:

# 1. Função `compare_pairs()`:
#    A função `compare_pairs()` é usada para comparar todos os pares de registros dentro de um objeto de blocagem (neste caso, `pares_blocagem`).
#    Ela compara variáveis específicas, definidas no argumento `on`. No exemplo, estamos comparando as variáveis `nome`, `data_nasc`, `cpf`, e `nome_mae`,
#    que são os atributos que queremos verificar para possíveis duplicatas ou correspondências.

# 2. Distância Jaro-Winkler:
#    A função `jaro_winkler()` do pacote `reclin` é utilizada para calcular a similaridade entre as strings comparadas. Ela é uma medida de distância que verifica
#    o quão parecidas duas strings são, levando em consideração a ordem dos caracteres.
#    A principal vantagem do **Jaro-Winkler** em relação ao **Levenshtein** é que ela é mais sensível a diferenças no início das palavras, o que a torna mais eficaz
#    para dados com pequenas diferenças de digitação ou transposições de letras.
#    O parâmetro `threshold = 0.9` define o ponto de corte para a similaridade mínima aceitável entre dois registros. Ou seja, se a similaridade entre os valores das
#    variáveis comparadas for maior ou igual a 90%, eles serão considerados correspondentes. Se for abaixo de 90%, serão considerados não correspondentes.

# 3. Objeto `pares_link_prob`:
#    O resultado da execução da função `compare_pairs()` é armazenado no objeto `pares_link_prob`.
#    Esse objeto contém os pares de registros que foram comparados, junto com a similaridade de cada variável. Os pares de registros que possuem uma alta similaridade
#    (acima de 0.9 para cada variável especificada) são considerados correspondências.

# 4. Visualização do Resultado:
#    O comando `pares_link_prob` exibe o resultado do linkage probabilístico.
#    O objeto resultante indicará quais registros possuem correspondências com base na comparação das variáveis e no critério de similaridade estabelecido.

# Conclusão:
# O linkage probabilístico, especialmente com a medida de **Jaro-Winkler**, é uma técnica útil para detectar correspondências entre registros,
# mesmo quando existem pequenas variações nos dados. Esse tipo de análise é importante para encontrar duplicatas e melhorar a qualidade dos dados,
# especialmente em contextos de saúde pública ou vigilância epidemiológica, onde os dados podem ser registrados de maneiras ligeiramente diferentes
# em diferentes momentos ou locais.


# resultado

# Primeira base de dados: 10.196 registros
# Segunda base de dados: 10.196 registros
# Número total de pares: 25.985.290 pares
# Bloqueando pela variável: 'sexo'

#       .x   .y     nome   data_nasc   cpf     nome_mae
#    <int> <int>   <num>   <num>       <num>   <num>
# 1:     2     5  0.5388889  0.7047619  0.6101190  0.5126050
# 2:     2     9  0.5606238  0.6500000  0.5892857  0.6381837
# 3:     2    14  0.5740741  0.6500000  0.5684524  0.5546802
# 4:     2    15  0.5673401  0.6777778  0.6309524  0.6056384
# 5:     2    17  0.5752452  0.7285714  0.6507937  0.4852941
# ---                                                    
# 25985286: 10193  10195  0.5150794  0.8250000  0.6137566  0.5036995
# 25985287: 10193  10196  0.5544686  0.6777778  0.4801587  0.5649708
# 25985288: 10194  10195  0.5105820  0.6666667  0.5000000  0.5959632
# 25985289: 10194  10196  0.6883483  0.8041667  0.6507937  0.5788596
# 25985290: 10195  10196  0.6255242  0.6500000  0.5000000  0.6038509

# O resultado mostra uma comparação entre pares de registros de duas bases de dados, 
# considerando as variáveis 'nome', 'data_nasc', 'cpf' e 'nome_mae'.
# Cada linha da tabela representa um par de registros comparados, com os valores de 
# similaridade para cada variável calculados usando o método de Jaro-Winkler.

# .x e .y: Indicam os índices dos registros comparados.
# nome, data_nasc, cpf, nome_mae: São as variáveis comparadas, com os valores de 
# similaridade (que variam de 0 a 1) entre os pares de registros.
# Quanto mais próximo de 1, mais semelhantes os registros são para a variável específica.
# Valores baixos indicam registros diferentes.

# O bloqueio pelo 'sexo' foi aplicado para reduzir o número de comparações e focar nos pares 
# que têm sexo correspondente.





# Verificando as colunas existentes em pares_link_prob para escolher o identificador correto
colnames(pares_link_prob)

# Supondo que você tenha um identificador único de notificação como 'nu_not', vamos usá-lo.
# Caso contrário, substitua 'nu_not' pelo nome correto da coluna com o identificador de notificação.

# Adicionando as variáveis de identificação diretamente no objeto pares_link_prob
pares_link_prob$nu_not_x <- pares_link_prob$nu_not  # Substituindo 'nome' por 'nu_not' (o identificador correto)
pares_link_prob$nu_not_y <- pares_link_prob$nu_not  # Da mesma forma, atribuindo o identificador correto à coluna 'nu_not_y'

# Verifique se as variáveis foram adicionadas corretamente
head(pares_link_prob)  # Exibe as primeiras linhas do objeto 'pares_link_prob' para garantir que as colunas 'nu_not_x' e 'nu_not_y' foram corretamente adicionadas

# Resultado do comando 'head(pares_link_prob)' pode ser algo como o seguinte:
# First data set:  10,196 records
# Second data set: 10,196 records
# Total number of pairs: 6 pairs
# Blocking on: 'sexo'
# 
# .x    .y      nome        data_nasc     cpf         nome_mae
# <int> <int>   <num>       <num>         <num>       <num>
# 1:    2     5  0.5388889   0.7047619     0.6101190   0.5126050
# 2:    2     9  0.5606238   0.6500000     0.5892857   0.6381837
# 3:    2    14  0.5740741   0.6500000     0.5684524   0.5546802
# 4:    2    15  0.5673401   0.6777778     0.6309524   0.6056384
# 5:    2    17  0.5752452   0.7285714     0.6507937   0.4852941
# 6:    2    18  0.5265475   0.6777778     0.5357143   0.5340803

# Explicação das colunas da tabela:
# - .x e .y: São os índices dos pares de registros comparados entre os dois conjuntos de dados.
# - nome: Similaridade entre os campos de 'nome' dos dois registros.
# - data_nasc: Similaridade entre as datas de nascimento dos dois registros.
# - cpf: Similaridade entre os CPFs dos dois registros.
# - nome_mae: Similaridade entre os nomes das mães dos dois registros.

# As linhas representam pares de registros, e os valores nas colunas de 'nome', 'data_nasc', 'cpf' e 'nome_mae' 
# são os índices de similaridade calculados entre os dois registros comparados, com valores mais altos indicando 
# maior similaridade.


# Renomeando pares_link_prob para p3
p3 <- pares_link_prob

# Adicionando as variáveis de identificação diretamente em p3
p3$nu_not_x <- p3$nu_not  # Substituindo 'nome' por 'nu_not' (o identificador correto)
p3$nu_not_y <- p3$nu_not  # Da mesma forma, atribuindo o identificador correto à coluna 'nu_not_y'

# Verificando as primeiras linhas do objeto 'p3' para garantir que as colunas 'nu_not_x' e 'nu_not_y' foram corretamente adicionadas
head(p3)



# Primeiro, o número de registros nos dois conjuntos de dados
# O primeiro conjunto tem 10.196 registros
# O segundo conjunto também tem 10.196 registros
# E o total de pares encontrados (considerando as comparações de linkage) é de 6 pares

# Realiza o linkage probabilístico com bloqueio baseado na variável 'sexo'
# Esse processo vai comparar apenas registros que compartilham o mesmo valor para 'sexo', 
# o que torna a comparação mais eficiente ao reduzir o número de comparações

# Aqui é o início da tabela com os pares de registros e as pontuações de similaridade
# Cada linha representa um par de registros comparados.

# .x e .y são os índices dos registros dos dois conjuntos que estão sendo comparados.
# nome, data_nasc, cpf, nome_mae são as variáveis nas quais o algoritmo de linkage
# está calculando as similaridades.

# O valor de similaridade varia de 0 (nenhuma similaridade) até 1 (similaridade máxima).

# O código a seguir mostra os primeiros 6 pares encontrados, onde a similaridade é calculada
# para cada uma das variáveis.

# Os valores abaixo representam a similaridade dos pares em cada uma das variáveis.

# Por exemplo, o par (2, 5) tem:
# - nome: similaridade de 0.5388889
# - data_nasc: similaridade de 0.7047619
# - cpf: similaridade de 0.6101190
# - nome_mae: similaridade de 0.5126050

# O objetivo aqui é revisar esses pares e decidir se são duplicados ou não.

# Mostrando os 6 primeiros pares com seus respectivos valores de similaridade:
# .x    .y      nome data_nasc       cpf  nome_mae
# 1:     2     5 0.5388889 0.7047619 0.6101190 0.5126050  # Par 1
# 2:     2     9 0.5606238 0.6500000 0.5892857 0.6381837  # Par 2
# 3:     2    14 0.5740741 0.6500000 0.5684524 0.5546802  # Par 3
# 4:     2    15 0.5673401 0.6777778 0.6309524 0.6056384  # Par 4
# 5:     2    17 0.5752452 0.7285714 0.6507937 0.4852941  # Par 5
# 6:     2    18 0.5265475 0.6777778 0.5357143 0.5340803  # Par 6





# Adicionando as variáveis de identificação diretamente
p3$nu_not_x <- p3$nome   # Aqui, você está criando uma nova coluna chamada 'nu_not_x' em 'p3'.
# A coluna 'nu_not_x' será preenchida com os valores da coluna 'nome' do objeto 'p3'.
# No entanto, o identificador correto deveria estar relacionado ao número de notificação (nu_not), 
# ou qualquer outro identificador único que seja mais apropriado para o contexto de suas duplicidades.

p3$nu_not_y <- p3$nome # Da mesma forma, criando a coluna 'nu_not_y' que também usa a coluna 'nome'.
# Como acima, seria melhor substituir 'nome' por um identificador único, como 'nu_not', 
# que é o número de notificação ou qualquer outro identificador relevante.

# Verifique se as variáveis foram adicionadas corretamente
head(p3)  # Exibe as primeiras linhas do objeto 'p3' para verificar se as colunas 'nu_not_x' e 'nu_not_y' foram corretamente adicionadas.

# Resultado esperado:
# Aqui, você verá as primeiras linhas da tabela 'p3' com as colunas 'nu_not_x' e 'nu_not_y' adicionadas,
# ambas com os valores da coluna 'nome' (a qual você pode ter usado temporariamente para este exemplo).
# Como mencionado anteriormente, é recomendável substituir essa coluna por identificadores mais apropriados,
# como o número de notificação, para refletir corretamente os pares de registros.


# A tibble com 6 pares identificados após o linkage probabilístico

# Colunas:
# .x e .y: 
#   Essas colunas representam os índices dos registros que foram comparados. A comparação foi feita entre o primeiro conjunto de dados (referido como 'First data set') e o segundo conjunto de dados ('Second data set'). 
#   Por exemplo, o primeiro par compara o registro 2 do primeiro conjunto de dados com o registro 5 do segundo conjunto de dados.

# nome, data_nasc, cpf, nome_mae:
#   São as variáveis que foram utilizadas para calcular a similaridade entre os pares. Cada coluna contém a correspondência dos valores de cada variável entre os registros comparados.

# simsum:
#   Representa o escore de similaridade calculado para o par. Esse valor foi obtido somando os escores de similaridade para as colunas de comparação (nome, data de nascimento, CPF, nome da mãe). 
#   A similaridade mais alta indica que os registros são mais semelhantes entre si. Por exemplo, o primeiro par tem um escore de 2.366375.

# select:
#   Coluna lógica (TRUE/FALSE) que indica se o par foi selecionado como uma duplicidade. 
#   Neste caso, nenhum dos pares foi selecionado como duplicidade (todos os valores de 'select' são FALSE), o que sugere que, com o threshold atual, nenhum dos pares atendeu ao critério de ser considerado uma duplicidade.

# nu_not_x e nu_not_y:
#   São as colunas que representam os identificadores de notificação dos registros comparados. 
#   Embora tenha sido inicialmente preenchido com a coluna 'nome', essas colunas devem ser atualizadas para refletir um identificador único e apropriado para cada registro, como o número de notificação (nu_not). 
#   No caso da tabela, os valores em 'nu_not_x' e 'nu_not_y' correspondem aos valores das colunas 'nome'.

# Resultado final:
# O código parece não ter encontrado duplicidades, já que todos os valores de 'select' são FALSE. Isso pode ocorrer devido ao ponto de corte (threshold) estabelecido ou à natureza dos dados, onde as similaridades não foram suficientemente altas para considerar os pares como duplicados.

# Exemplo das primeiras 6 linhas:
#       .x    .y      nome  data_nasc    cpf   nome_mae simsum select nu_not_x nu_not_y
#   1:  2     5   0.5388889  0.7047619  0.6101190  0.5126050  2.366375 FALSE 0.5388889 0.5388889
#   2:  2     9   0.5606238  0.6500000  0.5892857  0.6381837  2.438093 FALSE 0.5606238 0.5606238
#   3:  2    14   0.5740741  0.6500000  0.5684524  0.5546802  2.347207 FALSE 0.5740741 0.5740741
#   4:  2    15   0.5673401  0.6777778  0.6309524  0.6056384  2.481709 FALSE 0.5673401 0.5673401
#   5:  2    17   0.5752452  0.7285714  0.6507937  0.4852941  2.439904 FALSE 0.5752452 0.5752452
#   6:  2    18   0.5265475  0.6777778  0.5357143  0.5340803  2.274120 FALSE 0.5265475 0.5265475






# As variáveis selecionadas ordenadas por similaridade (simsum) da menor para a maior.

library(dplyr)
library(tibble)

# Verifique os nomes das colunas de similaridade (ex: nome, mae, nascimento)
colnames(p3)

# Calcular simsum (soma das colunas de similaridade)
# Substitua "nome", "mae", "nascimento" pelas colunas que existem no seu p3
p3$simsum <- rowSums(p3[, c("nome", "data_nasc", "cpf", "nome_mae")], na.rm = TRUE)

# Definir a coluna select com base em um threshold (por exemplo, 3.5)
p3$select <- p3$simsum > 3.5

# Criar o objeto de duplicidades
reg_dup <- p3 |>
  as_tibble() |>
  filter(select) |>
  select(.x, .y, simsum, select, nu_not_x, nu_not_y) |>
  arrange(simsum)  # agora ordenando do maior para o menor simsum

# Visualizar o resultado
reg_dup


# Comentário do resultado:
# A tibble: 188 × 6
#   .x    .y simsum select nu_not_x nu_not_y
#  <int> <int>  <dbl> <lgl>     <dbl>    <dbl>
# 1    19  2301   3.53 TRUE      0.753    0.753
# 2  2716  5250   3.63 TRUE      0.835    0.835
# 3   195  2312   3.67 TRUE      0.812    0.812
# 4  5074  9982   3.70 TRUE      0.786    0.786
# 5  1134  5912   3.71 TRUE      1        1    
# 6   774  3166   3.72 TRUE      1        1    
# 7  3566  8351   3.73 TRUE      1        1    
# 8  7384  8581   3.73 TRUE      0.839    0.839
# 9  2735  6931   3.74 TRUE      0.829    0.829
# 10 2658  4698   3.76 TRUE      0.882    0.882
# # ℹ 178 more rows

# O que isso significa?
# - A tabela gerada contém 188 registros (linhas) de pares que foram identificados como duplicados com base no linkage probabilístico.
# - Para cada par de registros, as colunas '.x' e '.y' representam os índices ou identificadores dos registros que estão sendo comparados.
# - A coluna 'simsum' mostra a soma das similaridades para cada par de registros. Esses valores são usados para determinar o grau de correspondência entre os registros.
# - A coluna 'select' indica se o par de registros é considerado uma duplicidade, com base no threshold (neste caso, 3.5).
# - 'nu_not_x' e 'nu_not_y' são os identificadores dos registros, os quais foram atribuídos com base na coluna 'nu_not' original.



#
# Cada linha da tabela contém:
# - .x e .y: Os índices dos registros comparados. 
#            Estes representam os registros que estão sendo analisados para verificar se são duplicados.
# - simsum: A soma dos escores de similaridade entre os pares de registros comparados.
#           Quanto maior o valor de 'simsum', maior a probabilidade de que os registros sejam duplicados.
# - select: Um valor lógico que indica se o par de registros foi selecionado como duplicado (TRUE).
#           O valor é TRUE quando o 'simsum' ultrapassa o ponto de corte (3.5 no exemplo).
# - nu_not_x e nu_not_y: São as colunas de identificação associadas aos registros comparados. 
#           Neste caso, estão preenchidas com valores fictícios (como 'nome') para ilustrar, mas
#           deveriam representar um identificador único de cada registro, como números de notificação.

# O objetivo da análise é identificar duplicidades nos registros com base em variáveis como nome,
# data de nascimento, CPF e nome da mãe, utilizando o algoritmo de linkage probabilístico.










# Carregue o pacote necessário (caso ainda não tenha feito isso)
library(reclin2)

head(p3)
# Espera-se que 'p3' tenha colunas como: .x, .y, nome, data_nasc, cpf, nome_mae, simsum, select

# Gerando as chaves de duplicação para os registros
# A função deduplicate_equivalence identifica registros duplicados com base nos pares e em uma variável lógica
# Aqui usamos a variável 'select' para indicar quais pares devem ser considerados como duplicados

# Gera as chaves de duplicação apenas para os pares selecionados
res <- deduplicate_equivalence(pairs = p3, variable = "select")
# Espera-se que 'p3' tenha colunas como: .x, .y, nome, data_nasc, cpf, nome_mae, simsum, select

# Neste trecho, utilizamos a função deduplicate_equivalence() do pacote reclin2 para identificar registros duplicados
# com base nos pares previamente comparados e classificados.

# A função considera apenas os pares onde a variável select é TRUE,
# ou seja, os que ultrapassaram o threshold de similaridade definido anteriormente (ex: simsum > 3.5).

# A função gera automaticamente uma chave de agrupamento de duplicidade,
# que é atribuída a uma nova coluna chamada group (ou, neste caso, sobrescreve a coluna 'select').

# Registros que compartilham a mesma chave pertencem ao mesmo grupo de duplicação e são considerados duplicatas entre si.

# Veja os primeiros registros com chave de grupo
head(res)


# Os registros que pertencem ao mesmo grupo de duplicação recebem o mesmo valor na coluna 'select' (que foi sobrescrita)
# Isso significa que esses registros foram considerados duplicados entre si pelo algoritmo

# Exemplo do resultado:
#   nu_notific                   nome      sexo  data_nasc idade            cpf               nome_mae select
#   <num>                       <char>    <char>     <Date> <num>         <char>                 <char>  <int>
# 1   10001569  Kauan Azevedo Azevedo masculino 1965-07-27    57 622.290.767-95 Analia Azevedo Azevedo  10196
# 2   10009876     Raissa Cunha Costa  feminino 1939-07-15    83 662.957.878-35      Agata Cunha Costa  10186
# 3   10012252  Rafael Castro Barbosa masculino 1976-03-28    46 665.935.236-82 Natacha Castro Barbosa  10196
# 4   10012410 Vinicius Silva Ribeiro masculino 1964-02-10    58 532.933.567-10  Aldenir Silva Ribeiro  10196
# 5   10017778   Beatriz Araujo Rocha  feminino 1992-03-04    30 602.213.075-16      Raquel de Miranda  10186
# 6   10020320       Luís Silva Gomes masculino 1990-04-21    32 827.768.913-69     Romana Silva Gomes  10196

# Interpretação:
# Os registros com a mesma chave na coluna 'select' (por exemplo, 10196) foram agrupados como duplicatas.
# Isso permite uma revisão manual ou a posterior consolidação desses registros duplicados.
# O resultado mostra, por exemplo, que os registros de:
# - Kauan Azevedo Azevedo
# - Rafael Castro Barbosa
# - Vinicius Silva Ribeiro
# - Luís Silva Gomes
# foram atribuídos ao mesmo grupo (10196), o que indica que o algoritmo os identificou como possíveis duplicatas.

# Da mesma forma, os registros de:
# - Raissa Cunha Costa
# - Beatriz Araujo Rocha
# foram agrupados sob a chave 10186, sugerindo outra duplicidade.

# Este agrupamento permite uma revisão manual mais eficiente,
# facilitando tanto a validação dos matches quanto a posterior deduplicação da base de dados, se for o caso.





#teste
# Corrigindo o nome da coluna de agrupamento (ela foi sobrescrita pela função deduplicate_equivalence)
# Renomeando a coluna 'select' para 'duplicate_groups' para facilitar a compreensão
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


# Resultado:
# O objeto dup_grupos contém dois grupos de duplicatas identificados:
# - O grupo com código 10196 contém 5.126 registros
# - O grupo com código 10186 contém 5.070 registros

# Resultado do print(dup_grupos):
# # A tibble: 2 × 3
# # Groups:   duplicate_groups [2]
#   duplicate_groups data                 pares
#              <int> <list>               <dbl>
# 1            10196 <tibble [5,126 × 7]>  5126
# 2            10186 <tibble [5,070 × 7]>  5070



# Cria um novo objeto chamado 'lista_dup' que irá conter todos os registros que 
# pertencem a grupos com mais de um indivíduo (ou seja, possíveis duplicatas)
lista_dup <- dup_grupos |>
  
  # Filtra apenas os grupos que têm mais de um registro (pares > 1).
  # Isso garante que estamos olhando apenas para os grupos com duplicidades reais,
  # e não registros únicos (sem correspondência).
  filter(pares > 1) |> 
  
  
  # 'unnest(data)' expande os data frames aninhados da coluna 'data'.
  # A coluna 'data' foi criada com a função nest() e contém as listas de registros
  # de cada grupo de duplicatas. Aqui, estamos "desempacotando" essas listas para
  # voltar a uma tabela plana (um registro por linha).
  unnest(data) 


# Exibe as primeiras linhas do objeto 'lista_dup' de forma organizada
# kable() é uma função do pacote knitr que cria uma tabela visual mais agradável,
# ideal para relatórios, apresentações ou visualização rápida em RMarkdown.
kable(head(lista_dup))



# Resultado esperado (exemplo com base nos dados que você forneceu):
# A tabela abaixo mostra registros que pertencem ao grupo 10196 (considerados duplicados).
# A coluna 'pares' indica o total de registros nesse grupo — no caso, 5.126 registros!

# | duplicate_groups| nu_notific|nome                   |sexo      |data_nasc  | idade|cpf            |nome_mae               | pares|
# |----------------:|----------:|:----------------------|:---------|:----------|-----:|:--------------|:----------------------|-----:|
# |            10196|   10001569|Kauan Azevedo Azevedo  |masculino |1965-07-27 |    57|622.290.767-95 |Analia Azevedo Azevedo |  5126|
# |            10196|   10012252|Rafael Castro Barbosa  |masculino |1976-03-28 |    46|665.935.236-82 |Natacha Castro Barbosa |  5126|
# |            10196|   10012410|Vinicius Silva Ribeiro |masculino |1964-02-10 |    58|532.933.567-10 |Aldenir Silva Ribeiro  |  5126|
# |            10196|   10020320|Luís Silva Gomes       |masculino |1990-04-21 |    32|827.768.913-69 |Romana Silva Gomes     |  5126|
# |            10196|   10025007|Breno Cardoso Silva    |masculino |1976-06-15 |    46|507.679.906-33 |Lisiane Cardoso Silva  |  5126|
# |            10196|   10027790|Davi Rodrigues Santos  |masculino |1989-11-26 |    32|179.450.307-26 |Ivanilda Vilhena       |  5126|

# Comentário geral:
# Esse resultado mostra que o grupo de duplicidade identificado como 10196 possui 5.126 registros.
# Cada um desses registros foi agrupado pelo algoritmo de linkage probabilístico com base na similaridade
# dos campos comparados (como nome, CPF, nome da mãe, etc.).
# Esses registros devem ser revisados manualmente ou tratados conforme a política de deduplicação do sistema.







# Salvando a lista de duplicidades em um arquivo CSV
# A função write_csv2() é usada para escrever a tabela 'lista_dup' em um arquivo CSV.
# O argumento 'file' especifica o nome do arquivo de saída. Usamos o formato CSV com ponto e vírgula como delimitador (CSV2).
write_csv2(lista_dup, file = 'lista_duplicidades.csv')


# Especificando o caminho completo para salvar o arquivo na pasta desejada
# Aqui, você pode substituir "caminho/da/pasta" pelo diretório onde deseja salvar o arquivo.
write_csv2(lista_dup, file = "/home/pamela/Documentos/Linkage_Data_Health/DATA/lista_duplicidades.csv")


# | duplicate_groups| nu_notific|nome                   |sexo      |data_nasc  | idade|cpf            |nome_mae               | pares|
# |----------------:|----------:|:----------------------|:---------|:----------|-----:|:--------------|:----------------------|-----:|
# |            10196|   10001569|Kauan Azevedo Azevedo  |masculino |1965-07-27 |    57|622.290.767-95 |Analia Azevedo Azevedo |  5126|
# |            10196|   10012252|Rafael Castro Barbosa  |masculino |1976-03-28 |    46|665.935.236-82 |Natacha Castro Barbosa |  5126|
# |            10196|   10012410|Vinicius Silva Ribeiro |masculino |1964-02-10 |    58|532.933.567-10 |Aldenir Silva Ribeiro  |  5126|
# |            10196|   10020320|Luís Silva Gomes       |masculino |1990-04-21 |    32|827.768.913-69 |Romana Silva Gomes     |  5126|
# |            10196|   10025007|Breno Cardoso Silva    |masculino |1976-06-15 |    46|507.679.906-33 |Lisiane Cardoso Silva  |  5126|
# |            10196|   10027790|Davi Rodrigues Santos  |masculino |1989-11-26 |    32|179.450.307-26 |Ivanilda Vilhena       |  5126|


# Carregar pacotes necessários
library(knitr)

# Gerar tabela das primeiras 20 linhas usando kable
kable(head(lista_dup, 20))

# tabela 
# Ler o arquivo CSV que você gerou anteriormente
lista_dup <- read.csv2("/home/pamela/Documentos/Linkage_Data_Health/DATA/lista_duplicidades.csv")

DT::datatable(head(lista_dup, 20))

