// Base de sinônimos para casar o nome do cupom fiscal com o nome do produto
// cadastrado. Curada a partir de nomes reais de NFC-e de supermercado.
// Tudo aqui está normalizado: minúsculo e sem acento.

/// Expressões que significam a mesma coisa escritas de formas diferentes.
/// A substituição gera a forma canônica em palavras normais, para a
/// tokenização seguir funcionando: "pasta de dente" -> "creme dental".
///
/// Não entram aqui expressões cujo sentido é a soma literal das palavras
/// ("farinha de trigo", "creme de leite"): juntá-las num único token faria
/// o produto genérico ("Farinha") voltar a casar por prefixo.
const productPhraseSynonyms = <String, String>{
  'pasta de dente': 'creme dental',
  'pasta de dentes': 'creme dental',
  'pasta dental': 'creme dental',
  'gel dental': 'creme dental',
  'leite moca': 'leite condensado',
  'flocos de milho': 'cuscuz',
  'flocao de milho': 'cuscuz',
  'flocao nordestino': 'cuscuz',
  'la de aco': 'esponja de aco',
  'creme de pentear': 'creme pentear',
};

/// Palavra por palavra. Cobre abreviação de cupom, marca que virou nome
/// genérico e sinônimo regional.
const productTokenSynonyms = <String, String>{
  // abreviações do cupom que não são prefixo da palavra inteira
  'mac': 'macarrao',
  'macarr': 'macarrao',
  'acuc': 'acucar',
  'choc': 'chocolate',
  'marg': 'margarina',
  'det': 'detergente',
  'desod': 'desodorante',
  'amac': 'amaciante',
  'cond': 'condensado',
  'integ': 'integral',
  'trad': 'tradicional',
  'hig': 'higienico',
  'pap': 'papel',
  'sab': 'sabao',
  'sabon': 'sabonete',
  'bisc': 'biscoito',
  'rech': 'recheado',
  'refri': 'refrigerante',

  // bolacha e biscoito são a mesma coisa em boa parte do Brasil
  'bolacha': 'biscoito',
  'rosquinha': 'biscoito',
  'wafer': 'biscoito',

  // sinônimos regionais
  'flocao': 'cuscuz',
  'macaxeira': 'mandioca',
  'aipim': 'mandioca',
  'jerimum': 'abobora',
  'colorau': 'corante',

  // marca que o cupom usa em vez do nome do produto
  'nescau': 'achocolatado',
  'toddy': 'achocolatado',
  'ovomaltine': 'achocolatado',
  'ype': 'detergente',
  'limpol': 'detergente',
  'qboa': 'sanitaria',
  'candida': 'sanitaria',
  'downy': 'amaciante',
  'comfort': 'amaciante',
  'colgate': 'dental',
  'sorriso': 'dental',
  'maizena': 'amido',
  'sazon': 'tempero',
  'knorr': 'caldo',
  'maggi': 'caldo',
  'doriana': 'margarina',
  'qualy': 'margarina',
  'catchup': 'ketchup',
  'coca': 'refrigerante',
  'pepsi': 'refrigerante',
  'fanta': 'refrigerante',
  'sprite': 'refrigerante',

  // formatos de macarrão
  'parafuso': 'macarrao',
  'penne': 'macarrao',
  'talharim': 'macarrao',
  'espaguete': 'macarrao',
  'spaghetti': 'macarrao',
};
