library(dplyr)
library(knitr)
library(kableExtra)

library(DT)

# Ler o arquivo CSV
#lista_dup <- read.csv2("/home/pamela/Documentos/Linkage_Data_Health/DATA/lista_duplicidades.csv")

# Verificar as primeiras linhas para confirmar que os dados foram carregados corretamente
#head(lista_dup)

#colnames(lista_dup)


# Ler o CSV
lista_dup <- read.csv2("/home/pamela/Documentos/Linkage_Data_Health/DATA/lista_duplicidades.csv")

# Construir a tabela DT com formatação condicional
DT::datatable(head(lista_dup, 20), 
              rownames = FALSE,
              options = list(pageLength = 20)) %>%
  DT::formatStyle(
    'sexo',
    target = 'cell',
    backgroundColor = DT::styleEqual(
      c("F", "M"),
      c("#CC99FF", "#3366CC")
    ),
    color = DT::styleEqual(
      c("F", "M"),
      c("black", "white")
    )
  ) %>%
  DT::formatStyle(
    'idade',
    background = DT::styleColorBar(
      range(lista_dup$idade, na.rm = TRUE), 
      'lightgreen'
    ),
    backgroundSize = '100% 90%',
    backgroundRepeat = 'no-repeat',
    backgroundPosition = 'center'
  )

DT::datatable(head(lista_dup, 20), rownames = FALSE, options = list(pageLength = 20)) %>%
  DT::formatStyle(
    'pares',
    target = 'cell',
    backgroundColor = '#CC99FF',
    color = 'black'
  )



# TABELA 2
library(DT)

# Ler o CSV
lista_dup <- read.csv2("/home/pamela/Documentos/Linkage_Data_Health/DATA/lista_duplicidades.csv")

DT::datatable(
  head(lista_dup, 20),
  rownames = FALSE,
  options = list(pageLength = 20)
) %>%
  # já trazia lilás na coluna 'pares' como antes, e agora:
  DT::formatStyle(
    'sexo',
    target = 'cell',
    backgroundColor = '#3366CC',
    color = 'white',
    fontWeight = 'bold'
  )
