library(ggplot2)
library(dplyr)
library(scales)  # para melhor formatação de cores

# Gerar uma paleta de cores grande em tons de lilás e rosa
cores_lilas_rosa <- colorRampPalette(c("#E6CCFF", "#FFCCE5", "#CC99FF", "#FFB3D9", "#D9B3FF", "#FF99CC"))(length(unique(contagem_pares$data_nasc)))

# Criar o gráfico
grafico_pares <- ggplot(contagem_pares, aes(x = idade, y = quantidade_pares, fill = factor(data_nasc))) +
  geom_bar(stat = "identity", position = "dodge") +
  scale_fill_manual(values = cores_lilas_rosa) +
  labs(title = "Duplicagem em relação a idade e data de Nascimento",
       x = "Idade",
       y = "Quantidade de Pares",
       fill = "Data de Nascimento") +
  theme_minimal() +
  theme(legend.position = "none")  # Oculta legenda se tiver muita coisa

# Exibir
grafico_pares

# Salvar o gráfico como PNG
png("/home/pamela/Documentos/Linkage_Data_Health/grafico_pares.png", width = 800, height = 600)
print(grafico_pares)
dev.off()


library(ggplot2)
library(dplyr)
library(scales)

# Amostra aleatória de 20 linhas
set.seed(123)  # Semente para reprodutibilidade
amostra_20 <- sample_n(contagem_pares, 20)

# Gerar uma paleta de 20 cores em tons de lilás e rosa
cores_lilas_rosa <- colorRampPalette(c("#E6CCFF", "#FFCCE5", "#CC99FF", "#FFB3D9", "#D9B3FF", "#FF99CC"))(20)

# Criar o gráfico com a amostra
grafico_pares <- ggplot(amostra_20, aes(x = idade, y = quantidade_pares, fill = factor(data_nasc))) +
  geom_bar(stat = "identity", position = "dodge") +
  scale_fill_manual(values = cores_lilas_rosa) +
  labs(title = "Duplicagem em relação à Idade e Data de Nascimento (Amostra de 20)",
       x = "Idade",
       y = "Quantidade de Pares",
       fill = "Data de Nascimento") +
  theme_minimal() +
  theme(legend.position = "none")

# Exibir
grafico_pares

# Salvar o gráfico como PNG
png("/home/pamela/Documentos/Linkage_Data_Health/grafico_pares_amostra20.png", width = 800, height = 600)
grafico_pares
dev.off()


#grafico3
library(ggplot2)
library(dplyr)
library(scales)

# Amostra aleatória de 20 linhas
set.seed(123)
amostra_20 <- sample_n(contagem_pares, 10)

# Gerar uma paleta de 20 tons de azul
cores_azul <- colorRampPalette(c("#99CCFF", "#003366"))(10)

# Criar o gráfico com barras mais grossas e tons de azul
grafico_pares <- ggplot(amostra_20, aes(x = idade, y = quantidade_pares, fill = factor(data_nasc))) +
  geom_bar(stat = "identity", position = "dodge", width = 0.9) +  # barras mais grossas
  scale_fill_manual(values = cores_azul) +
  labs(title = "Duplicagem em relação à Idade e Data de Nascimento (Amostra de 10)",
       x = "Idade",
       y = "Quantidade de Pares",
       fill = "Data de Nascimento") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))  # Gira os rótulos do eixo X pra não sobrepor

# Exibir
grafico_pares

# Salvar como PNG
png("/home/pamela/Documentos/Linkage_Data_Health/grafico_pares_azul_amostra20.png", width = 800, height = 600)
print(grafico_pares)
dev.off()



# Grafico 4
library(dplyr)
library(ggplot2)

# Padronizar sexo para "F" e "M"
lista_dup <- lista_dup %>%
  mutate(sexo = case_when(
    tolower(sexo) %in% c("f", "feminino") ~ "F",
    tolower(sexo) %in% c("m", "masculino") ~ "M",
    TRUE ~ as.character(sexo)
  ))

# Filtrar idades entre 45 e 90 anos
lista_dup_filtrada <- lista_dup %>%
  filter(idade >= 45 & idade <= 90)

# Criar amostra aleatória de 20 registros
set.seed(123)  # Definir semente para reprodutibilidade
amostra_20 <- sample_n(lista_dup_filtrada, 20)

# Agrupar por idade e sexo na amostra
contagem_idade_sexo <- amostra_20 %>%
  group_by(idade, sexo) %>%
  summarise(quantidade = n(), .groups = "drop")

# Criar gráfico com barras mais grossas
grafico_sexo_idade <- ggplot(contagem_idade_sexo, aes(x = idade, y = quantidade, fill = sexo)) +
  geom_bar(stat = "identity", position = "dodge", width = 1.0) +  # Barras mais grossas
  scale_fill_manual(values = c("F" = "#CC99FF", "M" = "#3366CC")) +  # Lilás p/ mulher, azul p/ homem
  labs(title = "Duplicação: Comparação de Sexo e Idade (45 a 90 anos) - Amostra de 20",
       x = "Idade",
       y = "Quantidade de Duplicações",
       fill = "Sexo") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

# Exibir gráfico
grafico_sexo_idade

# Salvar como PNG
png("/home/pamela/Documentos/Linkage_Data_Health/grafico_sexo_idade_amostra20_45_90.png", width = 800, height = 600)
grafico_sexo_idade
dev.off() 




