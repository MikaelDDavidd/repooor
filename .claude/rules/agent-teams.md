# Agent Teams - Workflow de Desenvolvimento

## Visao Geral
O desenvolvimento do Repooor segue um pipeline de 5 agentes especializados. Cada feature/task passa por todos os agentes em ordem.

## Pipeline

```
Planner → Designer → Developer → Reviewer → Tester
```

### Quando Usar
Quando o usuario pedir para implementar uma feature, modulo ou historia de usuario, executar o pipeline completo. Para bugfixes simples ou ajustes pontuais, usar apenas Developer → Reviewer → Tester.

## Agentes

### 1. Planner (Planejador)
- **Quando**: Inicio de qualquer feature nova
- **Subagent**: `Plan`
- **Input**: Descricao da feature do usuario
- **Output**: Lista de tarefas ordenadas com dependencias, arquivos a criar/editar, criterios de aceite
- **Prompt base**: Ver `.claude/rules/agents/planner.md`

### 2. Designer (UI/UX)
- **Quando**: Apos o Planner, antes de codar
- **Subagent**: `general-purpose`
- **Input**: Tarefas do Planner que envolvem UI
- **Output**: Specs de UI (widgets, layout, cores, espacamentos), hierarquia de widgets, estados visuais
- **Prompt base**: Ver `.claude/rules/agents/designer.md`

### 3. Developer (Desenvolvedor)
- **Quando**: Apos Planner e Designer terem definido o que fazer
- **Subagent**: Principal (voce mesmo) ou `general-purpose` para tarefas paralelas
- **Input**: Tarefas do Planner + specs do Designer
- **Output**: Codigo implementado seguindo Clean Architecture
- **Prompt base**: Ver `.claude/rules/agents/developer.md`

### 4. Reviewer (Analista de Qualidade)
- **Quando**: Apos o Developer terminar a implementacao
- **Subagent**: `general-purpose`
- **Input**: Arquivos criados/editados pelo Developer
- **Output**: Lista de violacoes, sugestoes, aprovacao ou rejeicao
- **Prompt base**: Ver `.claude/rules/agents/reviewer.md`

### 5. Tester (Testador)
- **Quando**: Apos o Reviewer aprovar (ou em paralelo)
- **Subagent**: `general-purpose`
- **Input**: Codigo implementado + criterios de aceite do Planner
- **Output**: Testes unitarios e de widget escritos, resultado de execucao
- **Prompt base**: Ver `.claude/rules/agents/tester.md`

## Fluxo de Execucao

```
1. [Planner]  → Gera tarefas + criterios de aceite
2. [Designer] → Gera specs visuais para tarefas de UI
3. [Developer] → Implementa codigo (pode ser paralelo se independente)
4. [Reviewer] → Analisa codigo contra regras e requisitos
   - Se REJEITADO → volta para Developer com feedback
   - Se APROVADO → segue para Tester
5. [Tester]   → Escreve e roda testes
   - Se FALHOU → volta para Developer com falhas
   - Se PASSOU → Feature concluida
```

## Regras de Orquestracao

- O Planner SEMPRE roda primeiro
- Designer e Developer podem rodar em paralelo se o Developer tiver tarefas nao-UI para comecar
- Reviewer deve ler TODAS as rules (.claude/rules/) antes de analisar
- Se o loop Reviewer → Developer acontecer 3x, parar e pedir input do usuario
- Tester nao testa codigo que o Reviewer rejeitou
- Cada agente recebe o contexto do projeto (CLAUDE.md + rules relevantes) no prompt
