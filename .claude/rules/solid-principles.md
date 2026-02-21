# SOLID Principles - Aplicacao Pratica

## S - Single Responsibility
- Um widget = uma responsabilidade visual
- Um usecase = uma operacao de negocio
- Um datasource = operacoes de uma tabela/aggregate
- Um provider = estado de um contexto especifico

## O - Open/Closed
- Interfaces de repository permitem trocar storage (sqflite → outro) sem tocar domain
- Theme centralizado permite mudar visual sem editar widgets
- Categorias como constants permitem extensao sem modificar logica

## L - Liskov Substitution
- Implementacoes de repository honram o contrato COMPLETO da interface
- Se a interface define `Future<List<Product>> getAll()`, a impl DEVE retornar todos os produtos, sem filtros implicitos
- Exceptions documentadas na interface devem ser as unicas lancadas pela impl

## I - Interface Segregation
- Repositories agrupados por aggregate root
- Cada repository tem entre 3-7 metodos no maximo
- Se um repository cresce demais, dividir por operacao (ex: ProductQueryRepository, ProductCommandRepository)
- Nao criar interfaces gigantes que forcam implementacoes desnecessarias

## D - Dependency Inversion
- Domain define interfaces (repository abstracts)
- Data implementa essas interfaces (repository impls)
- Providers Riverpod fazem a ligacao (injecao de dependencia)
- Presentation NUNCA conhece a implementacao concreta, apenas a interface
