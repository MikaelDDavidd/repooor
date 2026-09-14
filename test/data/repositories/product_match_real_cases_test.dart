import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:repooor/domain/entities/nfce/match_type.dart';
import 'package:repooor/domain/entities/nfce/nfce_raw_item.dart';
import 'package:repooor/domain/entities/product.dart';
import 'package:repooor/domain/repositories/product_repository.dart';
import 'package:repooor/domain/usecases/nfce/suggest_category_for_name.dart';
import 'package:repooor/data/repositories/product_match_repository_impl.dart';

class _MockProductRepository extends Mock implements ProductRepository {}

class _MockSuggestCategory extends Mock implements SuggestCategoryForName {}

const realProductNames = [
  'ALICATE CUTICULA MERHEJE AZUL',
  'Amaciante',
  'Arroz',
  'Azeitona',
  'Açúcar',
  'Barra de Chocolate',
  'Batata Palha',
  'Biscoito Maria Tradicional',
  'Biscoito Recheado',
  'Biscoito Rosuuinha Skin Coco 400 A',
  'Biscoito Vitamassa Vitaresco 390g',
  'Bolacha',
  'Café',
  'CUADOR BELLY TEXTIL PEQUENO',
  'Calabresa',
  'Carne',
  'Catchup',
  'Chocolate',
  'Creme de Leite',
  'Cuscuz',
  'Desod Aerosol Rexona',
  'Doce de Goiaba',
  'Doce de Leite',
  'Esponja Scotch-brite Extrema',
  'Esponja Scoth Brite 3m Nao Risca*',
  'Farinha',
  'Farinha de trigo',
  'Feijão',
  'Leite',
  'Leite condensado',
  'Macarrão',
  'Maionese',
  'MILHO PIPOCA',
  'Milho',
  'Molho de Alho',
  'Molho de tomate',
  'Nescau',
  'Ovo',
  'Palito de Dente',
  'Pasta de dente',
  'Personal Vip',
  'Queijo Cheddar',
  'Queijo Mussarela',
  'Sabonete',
  'Sabão em barra',
  'Sabão em pó',
  'Saco de lixo 30L',
  'Saco de lixo 50l',
  'Sal',
  'Salsicha',
  'Sardinha',
  'Suco de Pacote',
  'Vinagre Molhito',
  'Água Sanitária',
  'Óleo',
];

/// Casos extraídos da NFC-e real de 25/07/2026 (60 itens).
/// `expected` null significa que criar um produto novo é o resultado correto.
const casesThatMustNotRegress = <String, String?>{
  // o matcher antigo mandava estes para o produto errado
  'CREME DE LEITE ITALAC 200GR': 'Creme de Leite',
  'LEITE COND PIRACANJUBA TP 395G': 'Leite condensado',
  'FARINHA DE TRIGO BOA SORTE TRAD.': 'Farinha de trigo',
  'SARDINHA CORQUEIRO OLEO': 'Sardinha',
  'BISCOITO VITAMASSA RECHEADO': 'Biscoito Recheado',
  'MILHO PARA PIPOCA SAO BRAZ 20 X 400G': 'MILHO PIPOCA',
  // estes o matcher antigo acertava e precisam continuar acertando
  'ARROZ POP PARBOILIZADO': 'Arroz',
  'ACUCAR CRISTAL TAI 1KG': 'Açúcar',
  'CAFE 3 CORACOES TRADCIONAL 250G': 'Café',
  'FEIJAO IMPERIAL': 'Feijão',
  'SAL MOIDO RN C/ 1 KG': 'Sal',
  'OLEO DE SOJA SOYA 900ML': 'Óleo',
  'SALSICHA': 'Salsicha',
  'ESPONJA SCOTCH-BRITE EXTREMA': 'Esponja Scotch-brite Extrema',
  'AZEITONA VERDE VALE FERTIL SACHE 150G': 'Azeitona',
  'BATATA PALHA SCRUSCH 105G': 'Batata Palha',
  'MAIONESE HELLMANN\'S SACHET DOY PACK 400GR': 'Maionese',
  'MOLHO DE ALHO TAMBAU 750ML': 'Molho de Alho',
  'SABAO EM BARRA AZUL- 5 UNID.': 'Sabão em barra',
  'ALICATE CUTICULA MERHEJE AZUL': 'ALICATE CUTICULA MERHEJE AZUL',
  'VINAGRE MOLHITO': 'Vinagre Molhito',
  'doce de leite': 'Doce de Leite',
  'Palito de dente Parana menta': 'Palito de Dente',
  'SACO PARA LIXO ECON 30l': 'Saco de lixo 30L',
  'ovos cascavel': 'Ovo',
  // abreviações do cupom precisam casar com a palavra inteira
  'BISC TOBOGA CHOCOLATE C/3 RECH 390G': 'Biscoito Recheado',
  // sinônimo: rosquinha e bolacha são biscoito
  'rosquinha skin banana': 'Bolacha',
  // absurdos que precisam virar produto novo em vez de match errado
  'MARGARINA PRIMOR 1 KG': null,
  'CUADOR BELLY TEXTIL PEQUENO': 'CUADOR BELLY TEXTIL PEQUENO',
};

void main() {
  late ProductMatchRepositoryImpl repository;

  final products = [
    for (var i = 0; i < realProductNames.length; i++)
      Product(
        id: 'p$i',
        name: realProductNames[i],
        categoryId: 'c1',
        unit: 'un',
      ),
  ];

  setUp(() {
    final productRepo = _MockProductRepository();
    final suggest = _MockSuggestCategory();
    when(() => productRepo.getAll()).thenAnswer((_) async => products);
    when(() => suggest.call(any())).thenAnswer((_) async => 'c1');
    repository = ProductMatchRepositoryImpl(productRepo, suggest);
  });

  Future<String?> matchedNameFor(String rawName) async {
    final match = await repository.findMatch(
      NfceRawItem(rawName: rawName, quantity: 1, unitRaw: 'UN', unitPrice: 1),
    );
    if (match.type == MatchType.willCreateNew) return null;
    return match.matchedProduct?.name;
  }

  group('casos reais da NFC-e', () {
    casesThatMustNotRegress.forEach((rawName, expected) {
      test('"$rawName" -> ${expected ?? 'produto novo'}', () async {
        expect(await matchedNameFor(rawName), expected);
      });
    });
  });

  group('base de sinônimos', () {
    test('marca vira o produto genérico', () async {
      expect(await matchedNameFor('TODDY ORIGINAL SACHE 300g'), 'Nescau');
      expect(
        await matchedNameFor('CREME DENTAL COLGATE TOTAL 12'),
        'Pasta de dente',
      );
    });

    test('sinônimo regional casa com o nome usado na despensa', () async {
      expect(await matchedNameFor('FLOCAO NORDESTINO 500G'), 'Cuscuz');
      expect(await matchedNameFor('FLOCOS DE MILHO 500G'), 'Cuscuz');
    });

    test('abreviação do cupom que não é prefixo', () async {
      expect(await matchedNameFor('MAC PARAFUSO VITARELLA 400G'), 'Macarrão');
      expect(await matchedNameFor('ACUC REFINADO UNIAO'), 'Açúcar');
    });

    test('bolacha e biscoito são tratados como a mesma coisa', () async {
      expect(await matchedNameFor('BOLACHA MARIA'), isNotNull);
      expect(await matchedNameFor('WAFER MORANGO'), isNotNull);
    });

    test('prefere a marca certa quando ela existe na despensa', () async {
      expect(await matchedNameFor('NESCAU 2.0 ACHOCOLATADO 370G'), 'Nescau');
    });

    test(
      'não inventa match para o que não tem sinônimo nem palavra comum',
      () async {
        expect(await matchedNameFor('PILHA AAA DURACELL'), isNull);
        expect(await matchedNameFor('CABO USB TIPO C'), isNull);
      },
    );
  });

  group('regras que sustentam os casos acima', () {
    test('prefere o candidato mais específico ao mais genérico', () async {
      expect(await matchedNameFor('CREME DE LEITE ITALAC'), 'Creme de Leite');
      expect(await matchedNameFor('LEITE INTEGRAL'), 'Leite');
    });

    test('exige alguma palavra em comum para casar', () async {
      expect(await matchedNameFor('DETERGENTE YPE NEUTRO'), isNull);
      expect(await matchedNameFor('PILHA AAA DURACELL'), isNull);
    });

    test('ignora gramatura e unidade ao comparar', () async {
      expect(await matchedNameFor('ARROZ 5KG'), 'Arroz');
      expect(await matchedNameFor('ARROZ 1 KG PCT'), 'Arroz');
    });

    test('trata plural e singular', () async {
      expect(await matchedNameFor('ovos'), 'Ovo');
      expect(await matchedNameFor('OVOS BRANCOS GRANDES'), 'Ovo');
    });

    test('casa nome idêntico ignorando caixa e acento', () async {
      expect(await matchedNameFor('agua sanitaria'), 'Água Sanitária');
      expect(await matchedNameFor('ÁGUA SANITÁRIA'), 'Água Sanitária');
    });
  });
}
