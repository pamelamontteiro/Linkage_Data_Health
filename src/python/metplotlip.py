import matplotlib.pyplot as plt
import numpy as np

# Dados simulados (adaptados do gráfico anterior)
idades = ['39', '40', '41', '42', '43', '44', '45', '46', '47', '48']
quantidade_pares = [1, 1, 2, 1, 1, 1, 2, 1, 1, 1]

# Criar gráfico de pizza
fig, ax = plt.subplots(figsize=(8, 8))
wedges, texts, autotexts = ax.pie(
    quantidade_pares,
    labels=idades,
    autopct='%1.1f%%',
    startangle=140,
    colors=plt.cm.Blues_r(range(0, 256, int(256/len(idades))))
)

# Personalizar
plt.setp(autotexts, size=10, weight="bold", color="white")
ax.set_title('Distribuição de Duplicações por Idade (Amostra SUS)', fontsize=16, weight='bold')

# Legenda
ax.legend(wedges, [f'Idade {i} anos' for i in idades],
          title="Faixas Etárias",
          loc="center left",
          bbox_to_anchor=(1, 0, 0.5, 1))

plt.tight_layout()
plt.savefig('/mnt/data/pizza_duplicacoes_idade.png')
plt.show()
