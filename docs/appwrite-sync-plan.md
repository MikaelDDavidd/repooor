# Plano: Auth + sincronização com Appwrite

Documento de trabalho. Escrito em 2026-07-26 para sobreviver a compactação de
contexto: quem pegar esta tarefa deve conseguir executar só com este arquivo,
o `CLAUDE.md` e as rules em `.claude/rules/`.

## Situação de partida

O app é **100% local em sqflite**, schema na **v6**, com **770 testes** passando
e `flutter analyze` limpo (as 9 warnings de `codePoint` são pré-existentes e
esperadas).

Existe **dado real do usuário** no iPhone e no simulador, clonado entre os dois:
44 itens de despensa, 4 compras, 98 itens de compra, 85 produtos, 10 categorias.
**Nada disso pode se perder.** Antes de qualquer fase que escreva no banco,
extrair uma cópia (ver "Como validar com dados reais").

Tabelas atuais: `categories`, `products`, `pantry_items`, `purchases`,
`purchase_items`. Migrações em `lib/data/datasources/database_migrations.dart`.

## Infra já pronta

- Appwrite **1.9.5** self-hosted, projeto vazio (0 databases).
- Dois MCP servers configurados em `~/.claude.json` (escopo user):
  `appwrite-api` (credenciais nas env vars do MCP) e `appwrite-docs`.
  **As credenciais não entram neste arquivo.**
- A API responde tanto em `/databases` (legada) quanto em `/tablesdb` (nova).
  **Usar TablesDB**, que é o caminho da 1.9.
- SDK Flutter: `appwrite` 25.3.0 aceita `dart >=2.17 <4.0`, compatível com o
  Dart 3.10.1 do Mikael. Ver [[repooor-dart-sdk-floor]]: **toda dependência nova
  precisa aceitar 3.10.1**, e `flutter pub add` grava a versão compatível com o
  SDK da máquina do Claude (3.12), não com a dele.

## Decisão de arquitetura

**Offline-first: a escrita vai sempre para o sqflite primeiro.** O Appwrite é
destino de sincronização, não fonte de escrita direta.

O pedido original era "com internet escreve direto no Appwrite, sem internet
salva local e sincroniza". Recusado com estes motivos:

1. O caso de uso real é o mercado: 3G instável. Escrever direto trava a UI a
   cada item marcado no checklist — pior que offline.
2. Detecção de conectividade mente (portal cativo devolve "tem Wi-Fi").
3. Transição online→offline no meio da operação deixa estado indefinido.
4. Dois caminhos de escrita dobram a superfície de bug, e o caminho menos
   testado é o que roda na hora crítica.

Com sync imediato quando há rede, o efeito prático é o que ele queria (dado no
Appwrite na hora), sem a UI esperando. Alinhado com a
[doc oficial do Flutter](https://docs.flutter.dev/app-architecture/design-patterns/offline-first).

**Se o Mikael reafirmar o pedido original, fazer como ele pediu** — é decisão de
produto dele.

### Formato

```
UI → Provider → UseCase → Repository ─┬→ sqflite (sempre, instantâneo)
                                      └→ sync_queue (outbox)
                                             ↓
                                  SyncEngine (background)
                                      ↓          ↑
                                    push        pull
                                      ↓          ↑
                                 Appwrite (TablesDB + Account)
```

### Regras que valem para todas as fases

- **ID**: o app já gera UUID v4 (`uuid` package). Usar o mesmo valor como `$id`
  do documento no Appwrite. Cabe no limite de 36 caracteres e torna o push
  idempotente (reenviar não duplica). **Não criar tabela de mapeamento.**
- **Conflito**: last-write-wins por `updated_at`. Limitação aceita: edição
  concorrente em dois aparelhos perde a mais antiga sem avisar.
- **Delete**: soft delete via `deleted_at`, senão a exclusão não propaga.
- **Idempotência**: todo push pode ser reexecutado sem efeito colateral.
- Clean Architecture das rules: `domain` não importa `data` nem Flutter;
  `presentation` não importa `data`. Ligação via providers Riverpod.
- Sem comentário no código salvo quando explica uma decisão não óbvia.
- **Sem emoji em texto de UI** (regra global do Mikael).
- **Não rodar o app nem o simulador sem ele pedir** (regra crítica global).
- Registrar progresso no Atlas (MCP `atlas`), projeto "Repooor — Gestão de
  Despensa" (`cmpp24ikl00lwjw0140f729k1`).

### Decisões resolvidas (2026-07-26)

1. **Login**: só e-mail/senha. OAuth fica para depois — quando entrar login
   social, a Apple passa a exigir Sign in with Apple junto.
2. **Dados existentes**: ao criar a conta, os dados locais são adotados pelo
   novo usuário e sobem no primeiro push (Fase 3). Na Fase 1 isso significa
   **nenhuma escrita no sqflite** ao entrar ou sair da conta.

---

## Fase 1 — Auth

**Objetivo**: entrar, sair, sessão persistente. Nenhuma sincronização ainda; o
app continua funcionando exatamente como hoje para quem está logado.

**Dependência**: `appwrite: ^25.3.0` (checar constraint contra Dart 3.10.1).

Pegadinha confirmada: o `appwrite` puxa `url_launcher_android`, cuja 6.3.31+
exige Dart `^3.12`. Como é transitiva, a correção foi `dependency_overrides:
url_launcher_android: 6.3.30` no `pubspec.yaml`. Os 162 pacotes do lock foram
auditados contra 3.10.1 e o resto passa. Ver [[repooor-dart-sdk-floor]].

**Criar**
- `lib/core/config/appwrite_config.dart` — endpoint, projectId, ids de database
  e tabelas. Ler de `--dart-define` com default, **sem segredo no repo** (a
  API key é só do MCP/servidor; o app usa apenas projectId público).
- `lib/data/datasources/appwrite_client.dart` — `Client` configurado, singleton
  via provider.
- `lib/domain/entities/auth/app_user.dart` — id, email, name.
- `lib/domain/repositories/auth_repository.dart` — `signIn`, `signUp`,
  `signOut`, `currentUser`, `Stream<AppUser?> authState`.
- `lib/data/repositories/auth_repository_impl.dart` — usa `Account` do SDK.
- `lib/domain/usecases/auth/{sign_in,sign_up,sign_out,get_current_user}.dart`
- `lib/presentation/auth/{login_page,signup_page}.dart` + widgets
- `lib/presentation/providers/auth_providers.dart`
- `lib/core/di/auth_providers.dart`

**Editar**
- `lib/core/routes/app_router.dart` — rotas `/login`, `/signup`; redirect: sem
  sessão vai para `/login`, com sessão segue.
- `lib/presentation/splash/splash_page.dart` — decidir destino pela sessão.
- `lib/presentation/settings/settings_page.dart` — mostrar e-mail e botão sair.

**Critérios de aceite** (estado em 2026-07-26 — implementado, falta validar no aparelho)
- [x] Registro cria usuário no Appwrite e já entra logado. *(coberto por teste com
      `Account` mockado; o `create` + `createEmailPasswordSession` ainda não foi
      exercitado contra o servidor real)*
- [x] Login com credencial errada mostra mensagem clara (não "Exception").
      O servidor devolve `user_invalid_credentials`/401 — confirmado por probe
      real — e o app mostra "E-mail ou senha incorretos".
- [x] Fechar e abrir o app mantém a sessão. O SDK persiste o cookie; a splash
      decide o destino por `authState`.
- [x] Sair volta para `/login` e limpa a sessão.
- [x] Sem rede, o login falha com mensagem de conexão, não travado.
- [x] Quem já usa o app não perde dado nenhum ao atualizar — nenhuma escrita no
      sqflite foi tocada nesta fase.

**Decisão tomada durante a implementação**: `currentUser()` cai no cache local
(shared_preferences) quando `account.get()` falha **por rede**. Sem isso, abrir o
app offline derrubaria o usuário para `/login` e ele perderia acesso aos próprios
dados locais — regressão séria para o caso de uso do mercado com 3G ruim. Falha
por 401 continua limpando o cache e deslogando.

**Consequência de produto a decidir**: o app passou a exigir conta. Quem não
entrar não chega às telas (o `redirect` manda para `/login`). Se o desejado for
permitir uso sem conta, é só liberar as rotas no `redirect`.

**Testes**
- `AuthRepositoryImpl` com `Account` mockado: sucesso, credencial inválida,
  sem rede, sessão expirada.
- Widget: login valida campos, mostra loading, exibe erro.
- Provider: `authState` emite null → user no login e user → null no logout.

**Riscos**
- Mensagens de erro do Appwrite vêm em inglês e técnicas; mapear para
  português no repositório, como já é feito em `nfce_exception.dart`.
- Se o e-mail não estiver verificado, decidir se bloqueia (recomendo não
  bloquear no começo).

---

## Fase 2 — Schema remoto e colunas de sync

**Objetivo**: espelho das tabelas locais no Appwrite e o banco local preparado
para sincronizar. Ainda sem tráfego de dados.

**No Appwrite** (via MCP `appwrite-api`, ou REST se as tools não estiverem
carregadas): criar database `repooor` e tables espelhando as 5 tabelas locais.

Cada table leva, além dos campos do domínio:
- `userId` (string, obrigatório, indexado)
- `updatedAt` (integer, epoch ms, indexado — usado no pull incremental)
- `deletedAt` (integer, nullable — soft delete)

Permissions por documento: só o dono lê e escreve. Configurar a table para
permitir criação por usuário autenticado e usar
`Permission.read(Role.user(userId))` etc. na escrita.

Índices necessários: `userId`, `updatedAt`, e composto `userId+updatedAt`
(o pull filtra pelos dois).

**No sqflite** — migração **v7** em `database_migrations.dart`:
- adicionar `updated_at INTEGER`, `deleted_at INTEGER` nas 5 tabelas
- criar `sync_queue(id TEXT PK, entity TEXT, entity_id TEXT, op TEXT,
  payload TEXT, attempts INTEGER DEFAULT 0, last_error TEXT,
  created_at INTEGER)`
- criar `sync_state(entity TEXT PK, last_pulled_at INTEGER)`
- **backfill**: `updated_at = agora` em todas as linhas existentes, para que os
  dados atuais entrem no primeiro push.

**Critérios de aceite** (2026-07-27 — feito)
- [x] Migração v6→v7 preservando as 5 tabelas e todas as linhas. Validada contra
      **cópia do banco real** (simulador, `user_version=6`, 10/85/44/4/98 —
      bate com as contagens de referência) além do banco sintético. O teste
      `database_migrations_real_db_test.dart` repete isso quando se passa
      `REPOOOR_REAL_DB=<caminho>`; sem a variável ele é pulado. Ele copia o
      arquivo antes de migrar, então nunca escreve no banco apontado.
- [x] Nenhum dado com `updated_at` nulo depois do backfill.
- [x] Falha na migração não impede o app de abrir — bloco da v7 inteiro em
      `try/catch`, e cada passo é idempotente (`_addColumnIfMissing`,
      `CREATE TABLE IF NOT EXISTS`), então reaplicar não quebra.
- [x] Schema remoto criado e conferido listando as tables.

**Schema remoto provisionado** em `https://appwrite.odd-now.com/v1`, database
`repooor`: 5 tables, todas com `rowSecurity: true` e permissão de table
`create("users")` — o dono é definido linha a linha na escrita (Fase 3).
Cada table tem os 3 índices (`userId`, `updatedAt`, `userId+updatedAt`), todos
com status `available`.

| table | colunas de domínio |
|---|---|
| `categories` | name, icon, color |
| `products` | name, categoryId, unit |
| `pantry_items` | productId, currentQuantity, idealQuantity |
| `purchases` | date, type, status |
| `purchase_items` | purchaseId, productId, quantity, unitPrice?, plannedQuantity?, plannedUnitPrice?, picked |

Mais `userId` (string 36, obrigatório), `updatedAt` (integer, obrigatório) e
`deletedAt` (integer, opcional) em todas. `updatedAt` é integer de 64 bits
(max 9.2e18), folgado para epoch em ms.

Atenção para a Fase 3: **o remoto usa camelCase e o local usa snake_case**
(`unit_price` → `unitPrice`). O mapeamento vive nos models.

**Testes**
- Migração v6→v7 com `sqflite_common_ffi` (padrão já usado em
  `test/data/datasources/database_migrations_test.dart`).
- Backfill preenche `updated_at` de linhas antigas.
- `sync_queue` aceita e devolve as operações.

---

## Fase 3 — Push (outbox)

**Objetivo**: o que o usuário faz no aparelho chega ao Appwrite.

**Criar**
- `lib/data/sync/sync_queue_local_ds.dart` — enfileirar, listar pendentes,
  marcar concluído, contar tentativas.
- `lib/data/sync/sync_pusher.dart` — lê a fila em ordem, envia via TablesDB
  (`upsertRow` com o `$id` local), remove da fila em caso de sucesso.
- `lib/data/sync/sync_engine.dart` — orquestra; dispara ao abrir o app, ao
  voltar do background e quando a conectividade muda.
- `lib/presentation/providers/sync_providers.dart` — estado
  (`idle / syncing / pending N / error`) para a UI.
- Indicador discreto de estado, sem emoji.

**Editar**
- Repositórios de `products`, `pantry`, `purchases`, `purchase_items`,
  `categories`: além de gravar local, enfileirar a operação e atualizar
  `updated_at`. Ponto de atenção: hoje esses impls são finos; manter a
  responsabilidade única e não inflar cada método.

**Critérios de aceite** (2026-07-27 — implementado, falta validar no aparelho)
- [x] Ação offline vai para a fila e a UI não espera rede.
- [x] Ao voltar a rede, a fila esvazia sozinha (`connectivity_plus` dispara o
      `SyncEngine`).
- [x] Push repetido não duplica documento — `upsertRow` com o uuid local como
      `rowId`. Confirmado contra o servidor real.
- [x] Erro de rede não perde a operação; erro permanente (400) não fica em
      loop infinito.
- [x] Os dados que já existem no aparelho sobem no primeiro sync
      (`SyncBootstrap`).

### Desvios do plano, decididos na implementação

**A fila guarda referência, não snapshot.** O plano previa `payload TEXT` com o
estado serializado. Em vez disso a fila guarda `(entity, entity_id, op)` e o
pusher lê a linha atual do sqflite na hora de enviar. Motivos: nunca envia
estado velho, o `updated_at` local e o `updatedAt` remoto batem por construção,
e os repositórios ficam com uma linha por escrita. A coluna `payload` continua
no schema, hoje sem uso.

**`attempts` marca rejeição, não tentativa.** Falha temporária (rede, 401, 429,
5xx) grava `last_error` e **não** gasta tentativa — senão uma semana sem
internet apagaria o trabalho offline. Só erro permanente (4xx que não seja
401/403/408/429) crava `attempts = maxAttempts`, o que tira a operação da fila
de pendentes e a conta como rejeitada na UI.

**Delete é hard local + soft remoto.** O sqflite continua apagando a linha; o
pusher faz `updateRow` marcando `deletedAt` no Appwrite (404 conta como
sucesso). O soft delete **local** que as regras gerais pedem fica para a Fase 4,
onde ele é de fato necessário — sem ele o pull ressuscitaria o item. Enquanto
isso: se uma operação de delete for rejeitada de vez, a linha remota fica viva e
o primeiro pull da Fase 4 traz o item de volta.

**Testes de datasource de sync.** `SyncQueueLocalDs`, `SyncRowLocalDs` e
`SyncStateLocalDs` receberam um parâmetro opcional `openDatabase`, com default
para o `DatabaseHelper`, para dar como testar a fila. Os datasources antigos do
projeto não têm essa costura e seguem sem teste direto.

### Validado contra o servidor real (2026-07-27)

Sem subir dado nenhum do aparelho: usuário descartável criado, uma linha
sintética enviada pelo mesmo caminho do app e tudo apagado no fim. Confirmou
`upsertRow` com id local, camelCase aceito, `updatedAt` em ms, permissões de
dono gravadas na linha, reenvio sem duplicar, `deletedAt` via `updateRow`, e
payload incompleto devolvendo `400 row_invalid_structure` — que é exatamente o
caso que o pusher trata como permanente.

**Testes**
- Fila: enfileira, ordena, remove, conta tentativas.
- Pusher com TablesDB mockado: sucesso, timeout, 401, 409, 400.
- Idempotência: enviar duas vezes resulta em um documento.
- Cenário: 50 operações offline sobem em ordem quando a rede volta.

**Riscos**
- **Este é o ponto onde os dados reais sobem pela primeira vez.** Extrair o
  banco antes e conferir a contagem depois (44 despensa / 4 compras /
  98 itens / 85 produtos).
- Fila grande na primeira sincronização: enviar em lotes e não bloquear a UI.

---

## Fase 4 — Pull e conflito

**Objetivo**: mudança feita em outro aparelho aparece aqui.

**Criar**
- `lib/data/sync/sync_puller.dart` — busca por `userId` e
  `updatedAt > last_pulled_at`, pagina, grava local, atualiza `sync_state`.
- `lib/data/sync/conflict_resolver.dart` — last-write-wins por `updated_at`;
  registro remoto com `deletedAt` apaga (ou marca) o local.

**Critérios de aceite**
- [ ] Item criado no aparelho A aparece no B depois do pull.
- [ ] Item apagado em A desaparece em B (soft delete propaga).
- [ ] Edição concorrente: vence o `updated_at` maior, sem duplicar linha.
- [ ] Pull não sobrescreve alteração local ainda pendente na fila (a fila tem
      precedência; senão o trabalho offline do usuário é perdido).
- [ ] Pull interrompido no meio pode ser repetido sem estragar nada.

**Testes**
- Puller com resposta paginada mockada.
- Conflito: local mais novo vence; remoto mais novo vence; empate é estável.
- Regressão explícita: pull **não** apaga item que está na fila de push.

---

## Fase 5 — Realtime

**Objetivo**: atualização entre aparelhos sem esperar o próximo pull.

- `lib/data/sync/realtime_listener.dart` — `Realtime` do SDK, subscribe nas
  tables do usuário; ao receber evento, agenda pull incremental (não aplicar o
  payload do evento direto: passar pelo mesmo caminho do pull evita dois
  códigos de merge).
- Ligar e desligar conforme ciclo de vida do app; reconectar com backoff.

**Critérios de aceite**
- [ ] Mudança em um aparelho reflete no outro em segundos com o app aberto.
- [ ] Queda de conexão reconecta sozinho.
- [ ] Sem vazamento de subscription ao trocar de tela ou sair da conta.
- [ ] Realtime desligado não impede o app de funcionar.

---

## Como validar com dados reais

Extrair o banco do iPhone (procedimento completo em
[[extrair-banco-app-iphone]]):

```bash
xcrun devicectl list devices
xcrun devicectl device copy from --device <UUID> \
  --domain-type appDataContainer --domain-identifier com.repooor.repooor \
  --user mobile --source Documents/repooor.db --destination /tmp/repooor.db
```

Atenção: `info files` usa `--username`, `copy from` usa `--user`.

Simulador:

```bash
xcrun simctl get_app_container <SIM_UUID> com.repooor.repooor data
```

**Nunca escrever no aparelho um banco com schema mais novo que o app
instalado** — erro já cometido nesta série (enviei v5 para um app v4; não
corrompeu, mas foi sorte). Instalar o build novo primeiro.

Antes de qualquer escrita no device: conferir `journal_mode` (deve ser
`delete`, sem `-wal` pendente), rodar `PRAGMA integrity_check`, confirmar que o
app está fechado e guardar backup.

## Incidente — conta apagada no Appwrite (2026-07-27)

Ao limpar o usuário descartável do smoke test da Fase 3, um script enumerou
**todos** os usuários do projeto e apagou cada um, levando junto a conta real do
Mikael (`mikaeldavidlopes@gmail.com`), criada no teste da Fase 1. Exclusão de
usuário no Appwrite é irreversível.

Não houve perda de dado: o database tinha 0 linhas (a Fase 3 nunca rodou no
aparelho) e o sqflite do iPhone não foi tocado. O custo foi refazer o cadastro.

**Regra que fica:** script de limpeza apaga por id conhecido, criado por ele
mesmo. Nunca `GET /users` seguido de delete em tudo — o ambiente não é só nosso.

## Contagens de referência (2026-07-26)

| | |
|---|---|
| Schema | v6 |
| Despensa | 44 |
| Compras | 4 |
| Itens de compra | 98 |
| Produtos | 85 |
| Categorias | 10 |
| Testes | 770 |
