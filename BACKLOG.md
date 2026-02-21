# Repooor - Backlog Completo

## Legenda
- **P** = Pequena | **M** = Media | **G** = Grande
- Prioridade: 🔴 Critica | 🟡 Importante | 🟢 Desejavel

---

## Epic 0: Setup & Infraestrutura

### 0.1 — Criar projeto Flutter [P] 🔴
Criar projeto com `flutter create`, configurar dependencias (riverpod, sqflite, go_router, fl_chart, uuid, build_runner), limpar boilerplate.

### 0.2 — Estrutura de pastas [P] 🔴
Criar arvore de diretorios: core/, data/, domain/, presentation/ com subpastas.

### 0.3 — Design System (Theme) [M] 🔴
Implementar AppColors, AppTextStyles, AppTheme com o design system definido (#53B175, tipografia, espacamentos). Criar ThemeData completo.

### 0.4 — Database setup (sqflite) [M] 🔴
Criar DatabaseHelper com singleton, onCreate com todas as tabelas (products, categories, pantry_items, purchases, purchase_items), versionamento de migrations.

### 0.5 — Routing (GoRouter) [M] 🔴
Configurar GoRouter com shell route para bottom navigation e rotas para todas as telas.

### 0.6 — Bottom Navigation [M] 🔴
Implementar shell com bottom nav bar: Home, Despensa, Compras, Analise. Estilo do design (icone + label, ativo = verde).

### 0.7 — Widgets compartilhados base [M] 🟡
Criar componentes reutilizaveis: AppButton, AppTextField, AppCard, EmptyState, LoadingState, ErrorState, ConfirmDialog.

---

## Epic 1: Categorias

### 1.1 — Entity Category [P] 🔴
Criar entity Category no domain (id, name, icon, color).

### 1.2 — Model + DataSource Category [M] 🔴
CategoryModel com serialização SQL. CategoryLocalDs com CRUD no sqflite.

### 1.3 — Repository Category [P] 🔴
Interface CategoryRepository no domain. CategoryRepositoryImpl no data.

### 1.4 — UseCases Category [P] 🔴
GetAllCategories, CreateCategory, UpdateCategory, DeleteCategory.

### 1.5 — Providers Category [P] 🔴
Riverpod providers conectando UI aos usecases.

### 1.6 — Categorias pre-definidas (seed) [P] 🟡
Popular banco com categorias iniciais no primeiro uso: Frutas, Verduras, Carnes, Laticinios, Bebidas, Limpeza, Higiene, Graos, Congelados, Outros.

### 1.7 — Tela de gerenciamento de categorias [M] 🟢
Listar, criar, editar e deletar categorias. Selecao de icone e cor.

---

## Epic 2: Produtos

### 2.1 — Entity Product [P] 🔴
Criar entity Product no domain (id, name, categoryId, unit).

### 2.2 — Model + DataSource Product [M] 🔴
ProductModel com serialização SQL. ProductLocalDs com CRUD + busca por categoria + busca por nome.

### 2.3 — Repository Product [P] 🔴
Interface ProductRepository no domain. ProductRepositoryImpl no data.

### 2.4 — UseCases Product [M] 🔴
GetAllProducts, GetProductsByCategory, SearchProducts, CreateProduct, UpdateProduct, DeleteProduct.

### 2.5 — Providers Product [P] 🔴
Riverpod providers para lista de produtos, busca, filtro por categoria.

### 2.6 — Tela de listagem de produtos [G] 🔴
Grid/lista de produtos com filtro por categoria (chips horizontais), busca por nome, FAB para adicionar novo. Cards com nome, categoria (cor/icone), unidade.

### 2.7 — Tela de cadastro/edicao de produto [M] 🔴
Form com: nome (text), categoria (dropdown/selector), unidade (dropdown: kg, un, L, ml, g, pacote, caixa, lata). Validacao de campos obrigatorios.

### 2.8 — Deletar produto [P] 🟡
Confirmacao antes de deletar. Se o produto esta na despensa ou em compras, avisar o usuario antes de confirmar.

---

## Epic 3: Despensa (Pantry)

### 3.1 — Entity PantryItem [P] 🔴
Criar entity PantryItem no domain (id, productId, currentQuantity, idealQuantity).

### 3.2 — Model + DataSource PantryItem [M] 🔴
PantryItemModel com serialização SQL. PantryItemLocalDs com CRUD + query com JOIN em products para exibir nome/categoria.

### 3.3 — Repository PantryItem [P] 🔴
Interface PantryRepository no domain. PantryRepositoryImpl no data.

### 3.4 — UseCases Pantry [M] 🔴
GetPantryItems, AddToPantry, UpdatePantryQuantity, UpdateIdealQuantity, RemoveFromPantry, GetLowStockItems.

### 3.5 — Providers Pantry [P] 🔴
Providers para lista da despensa, itens com estoque baixo, filtros.

### 3.6 — Tela principal da despensa [G] 🔴
Lista de itens na despensa mostrando: nome do produto, categoria (icone colorido), quantidade atual vs ideal (barra de progresso ou indicador visual), unidade. Ordenacao por categoria ou por nivel de estoque. Indicador visual quando currentQuantity < idealQuantity (vermelho/amarelo).

### 3.7 — Adicionar produto a despensa [M] 🔴
Selecionar produto existente (busca/dropdown), definir quantidade atual e quantidade ideal. Se o produto nao existe, poder criar inline.

### 3.8 — Ajustar quantidade na despensa [M] 🔴
Botoes +/- para ajuste rapido de quantidade diretamente na lista. Tap no item para abrir edicao completa (quantidade atual + ideal).

### 3.9 — Indicador de estoque baixo [P] 🟡
Badge no bottom nav ou indicador na home quando existem itens abaixo do ideal. Codigo de cor: verde (>=100% do ideal), amarelo (50-99%), vermelho (<50%).

### 3.10 — Remover item da despensa [P] 🟡
Swipe para remover ou botao na edicao. Confirmacao antes de remover.

---

## Epic 4: Compras (Purchases)

### 4.1 — Entity Purchase + PurchaseItem [P] 🔴
Purchase (id, date, type: main/midMonth, items). PurchaseItem (id, purchaseId, productId, quantity).

### 4.2 — Model + DataSource Purchase [M] 🔴
PurchaseModel e PurchaseItemModel com serialização SQL. PurchaseLocalDs com CRUD + queries com JOINs.

### 4.3 — Repository Purchase [P] 🔴
Interface PurchaseRepository no domain. PurchaseRepositoryImpl no data.

### 4.4 — UseCases Purchase [M] 🔴
CreatePurchase, GetAllPurchases, GetPurchaseById, GetPurchasesByMonth, AddItemToPurchase, RemoveItemFromPurchase, UpdatePurchaseItem, CompletePurchase, DeletePurchase.

### 4.5 — Providers Purchase [P] 🔴
Providers para lista de compras, compra ativa, historico mensal.

### 4.6 — Tela de listagem de compras [M] 🔴
Historico de compras agrupado por mes. Cada card mostra: data, tipo (mensal/avulsa), quantidade de itens, status. Filtro por tipo e por mes.

### 4.7 — Criar nova compra [M] 🔴
Selecionar tipo (compra do mes / avulsa). Definir data. Iniciar lista de itens vazia.

### 4.8 — Tela de edicao da compra (lista de itens) [G] 🔴
Adicionar itens: buscar produto, definir quantidade. Lista dos itens ja adicionados com quantidade editavel. Remover itens da lista. Resumo: total de itens, categorias envolvidas.

### 4.9 — Sugestao automatica de compra [G] 🟡
Ao criar nova compra, sugerir automaticamente todos os itens da despensa que estao abaixo da quantidade ideal. Calcular quantidade sugerida = idealQuantity - currentQuantity. Usuario pode aceitar, ajustar ou ignorar cada sugestao.

### 4.10 — Registrar compra realizada [M] 🔴
Ao finalizar/completar uma compra, atualizar automaticamente as quantidades na despensa (somar quantity do PurchaseItem ao currentQuantity do PantryItem correspondente).

### 4.11 — Deletar compra [P] 🟡
Confirmacao antes de deletar. Nao desfaz as atualizacoes de estoque ja aplicadas.

---

## Epic 5: Home / Dashboard

### 5.1 — Tela Home [G] 🔴
Tela inicial com visao geral:
- Saudacao (bom dia/boa tarde/boa noite)
- Card resumo da despensa: total de itens, itens em falta (abaixo do ideal)
- Card resumo de compras: ultima compra realizada, proxima compra sugerida
- Lista rapida: itens com estoque mais baixo (top 5)
- Acesso rapido: botao para iniciar nova compra

### 5.2 — Card de itens em falta [M] 🟡
Card na home listando itens que precisam ser repostos com quantidade faltante. Tap leva para a despensa filtrada.

### 5.3 — Acesso rapido a nova compra [P] 🟡
Botao/card que inicia uma compra ja pre-populada com sugestoes de itens em falta.

---

## Epic 6: Analise / Analytics

### 6.1 — UseCase de analytics [M] 🔴
GetConsumptionByCategory (quanto se consome por categoria em um periodo). GetConsumptionByProduct (historico de compra de um produto). GetPurchaseFrequency (frequencia de compras por mes). GetTopProducts (produtos mais comprados).

### 6.2 — Providers Analytics [P] 🔴
Providers para cada metrica, com filtro de periodo (ultimo mes, 3 meses, 6 meses, 1 ano).

### 6.3 — Tela de analytics [G] 🔴
Dashboard com graficos (fl_chart):
- Grafico de pizza/donut: consumo por categoria
- Grafico de barras: produtos mais comprados (top 10)
- Grafico de linha: frequencia de compras ao longo dos meses
- Filtro de periodo no topo da tela

### 6.4 — Detalhe por categoria [M] 🟡
Tap em uma fatia do grafico de categorias abre lista dos produtos daquela categoria com quantidade total comprada no periodo.

### 6.5 — Detalhe por produto [M] 🟡
Tap em um produto no grafico de barras abre historico de compras daquele produto ao longo do tempo (grafico de linha).

---

## Epic 7: Busca Global

### 7.1 — Busca de produtos [M] 🟡
Campo de busca acessivel da home ou de qualquer tela. Busca por nome de produto. Resultados mostram onde o produto esta (despensa, ultima compra) e acoes rapidas.

---

## Epic 8: Onboarding

### 8.1 — Splash screen [P] 🟢
Tela de splash com logo do Repooor e cor primaria verde.

### 8.2 — Onboarding (primeiro uso) [M] 🟢
2-3 telas explicando o app: 1) Cadastre seus produtos, 2) Controle sua despensa, 3) Planeje suas compras. Botao para pular. Salvar flag de "ja viu onboarding" localmente.

### 8.3 — Setup inicial [M] 🟢
Apos onboarding, guiar usuario para cadastrar primeiros produtos e montar a despensa inicial.

---

## Epic 9: Configuracoes

### 9.1 — Tela de configuracoes [M] 🟢
Opcoes: gerenciar categorias, unidades customizadas, limpar dados, sobre o app.

### 9.2 — Export/Import de dados [G] 🟢
Exportar dados da despensa e historico de compras como JSON/CSV. Importar backup.

---

## Ordem de Implementacao Sugerida

```
Fase 1 - Fundacao (Epics 0, 1, 2)
  0.1 → 0.2 → 0.3 → 0.4 → 0.5 → 0.6 → 0.7
  1.1 → 1.2 → 1.3 → 1.4 → 1.5 → 1.6
  2.1 → 2.2 → 2.3 → 2.4 → 2.5 → 2.6 → 2.7 → 2.8

Fase 2 - Core (Epics 3, 4)
  3.1 → 3.2 → 3.3 → 3.4 → 3.5 → 3.6 → 3.7 → 3.8 → 3.9 → 3.10
  4.1 → 4.2 → 4.3 → 4.4 → 4.5 → 4.6 → 4.7 → 4.8 → 4.9 → 4.10 → 4.11

Fase 3 - Experiencia (Epics 5, 6, 7)
  5.1 → 5.2 → 5.3
  6.1 → 6.2 → 6.3 → 6.4 → 6.5
  7.1

Fase 4 - Polish (Epics 8, 9)
  8.1 → 8.2 → 8.3
  9.1 → 9.2
```

## Resumo

| Epic | Demandas | Criticas | Importantes | Desejaveis |
|------|----------|----------|-------------|------------|
| 0 - Setup | 7 | 6 | 1 | 0 |
| 1 - Categorias | 7 | 5 | 1 | 1 |
| 2 - Produtos | 8 | 7 | 1 | 0 |
| 3 - Despensa | 10 | 7 | 3 | 0 |
| 4 - Compras | 11 | 8 | 3 | 0 |
| 5 - Home | 3 | 1 | 2 | 0 |
| 6 - Analytics | 5 | 3 | 2 | 0 |
| 7 - Busca | 1 | 0 | 1 | 0 |
| 8 - Onboarding | 3 | 0 | 0 | 3 |
| 9 - Config | 2 | 0 | 0 | 2 |
| **Total** | **57** | **37** | **14** | **6** |
