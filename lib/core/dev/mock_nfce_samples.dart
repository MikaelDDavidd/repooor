class MockNfceSample {
  const MockNfceSample({
    required this.uf,
    required this.label,
    required this.chave,
    required this.html,
  });

  final String uf;
  final String label;
  final String chave;
  final String html;
}

String _row(
  String name,
  String code,
  String qty,
  String unit,
  String price,
  String total,
) {
  return '''
  <tr>
    <td class="txtTit">
      <span class="txtTit2">$name</span>
      (Código: $code)
    </td>
    <td>Qtde.: $qty UN: $unit Vl. Unit.: $price</td>
    <td class="txtTit">Vl. Total $total</td>
  </tr>''';
}

String _doc({
  required String emitente,
  required String cnpj,
  required String cidade,
  required String emissao,
  required List<String> rows,
  required String total,
}) {
  return '''
<!DOCTYPE html>
<html>
<head><title>DANFE NFC-e</title></head>
<body>
<div id="u20">
  <span class="txtTopo">$emitente</span>
  <div class="text">CNPJ: $cnpj</div>
  <div class="text">$cidade</div>
</div>
<ul class="ui-Page">
  <li><strong>Emissão:</strong> $emissao - Via Consumidor</li>
</ul>
<table id="tabResult">
${rows.join('\n')}
</table>
<div id="totalNota"><strong>Valor a pagar R\$:</strong> $total</div>
</body>
</html>''';
}

final mockNfceSamples = <MockNfceSample>[
  MockNfceSample(
    uf: 'PE',
    label: 'PE · Nota real (16 itens) ⭐',
    chave: '26030353824400011005002000222868904283530200',
    html: _doc(
      emitente: 'MERCADO PERNAMBUCANO',
      cnpj: '03.538.244/0001-10',
      cidade: 'Pernambuco/PE',
      emissao: '04/03/2026 13:51:41',
      rows: [
        _row('APRESUNTADO FATIADO', '000059', '0,228', 'KG', '20,65', '4,71'),
        _row(
          'POLPA MAROMBA MIX ACAI+BAN 200G',
          '7898551490202',
          '2',
          'UN',
          '3,30',
          '6,60',
        ),
        _row(
          'POLPA GUARANA ACAI 200G',
          '7898551490028',
          '4',
          'UN',
          '3,30',
          '13,20',
        ),
        _row('SALSICHA HOTDOG', '000238', '0,984', 'KG', '10,75', '10,58'),
        _row('CARNE MOIDA FRESCA', '000178', '0,524', 'KG', '41,60', '21,80'),
        _row(
          'FILE DE PEITO TEMPERADO KG',
          '000323',
          '1,018',
          'KG',
          '26,25',
          '26,72',
        ),
        _row(
          'COXAO MOLE REFRIADO FRIBOI',
          '000049',
          '1,400',
          'KG',
          '51,30',
          '71,82',
        ),
        _row('FIGADO BOVINO', '000063', '0,590', 'KG', '18,55', '10,94'),
        _row('LING CALABRESA SADIA', '000120', '0,432', 'KG', '34,35', '14,84'),
        _row(
          'AGUA SANITARIA BRILUX MULTI 1,8L',
          '7896013106364',
          '1',
          'UN',
          '8,60',
          '8,60',
        ),
        _row(
          'MAIONESE HELLMANNS POUCH 200G',
          '7894000030470',
          '2',
          'UN',
          '6,30',
          '12,60',
        ),
        _row(
          'DESO REXO AERO ACTIVE EMOTION 150ML',
          '7791293032443',
          '2',
          'UN',
          '16,50',
          '33,00',
        ),
        _row(
          'SABAO YPE NEUTRO C/5 180G',
          '7896098905906',
          '1',
          'UN',
          '12,50',
          '12,50',
        ),
        _row(
          'PAPEL HIG FAMILIAR SUPR FD 12X20M',
          '7898969556088',
          '1',
          'UN',
          '12,99',
          '12,99',
        ),
        _row(
          'PEDRA SANIT Q ODOR LAVANDA',
          '7898681061822',
          '4',
          'UN',
          '2,95',
          '11,80',
        ),
        _row(
          'SACO LIXO TUBARAO PRETO 50L',
          '7896013103172',
          '1',
          'UN',
          '5,90',
          '5,90',
        ),
      ],
      total: '278,60',
    ),
  ),
  MockNfceSample(
    uf: 'PE',
    label: 'PE · Supermercado (6 itens)',
    chave: '26240612345678901234567890123456789012345678',
    html: _doc(
      emitente: 'SUPERMERCADO BOM PRECO LTDA',
      cnpj: '12.345.678/0001-90',
      cidade: 'Recife/PE',
      emissao: '15/05/2026 18:42:30',
      rows: [
        _row(
          'ARROZ BRANCO TIPO 1 5KG',
          '7891234567890',
          '2',
          'UN',
          '28,90',
          '57,80',
        ),
        _row('FEIJAO CARIOCA 1KG', '7892222222222', '3', 'UN', '8,50', '25,50'),
        _row(
          'LEITE INTEGRAL ITALAC 1L',
          '7893333333333',
          '6',
          'UN',
          '5,49',
          '32,94',
        ),
        _row('BANANA PRATA', '0000000000001', '1,235', 'KG', '5,99', '7,39'),
        _row(
          'DETERGENTE YPE NEUTRO 500ML',
          '7894444444444',
          '4',
          'UN',
          '2,79',
          '11,16',
        ),
        _row(
          'BISCOITO XYZ MARCA NOVA RECHEADO',
          '7895555555555',
          '2',
          'PCT',
          '4,29',
          '8,58',
        ),
      ],
      total: '143,37',
    ),
  ),
  MockNfceSample(
    uf: 'PB',
    label: 'PB · Mercadinho (4 itens)',
    chave: '25240612345678901234567890123456789012345678',
    html: _doc(
      emitente: 'MERCADINHO PARAIBA LTDA',
      cnpj: '98.765.432/0001-21',
      cidade: 'João Pessoa/PB',
      emissao: '10/05/2026 11:15:00',
      rows: [
        _row(
          'AGUA MINERAL CRYSTAL 1.5L',
          '7890000000001',
          '6',
          'UN',
          '3,50',
          '21,00',
        ),
        _row('PAO FRANCES', '0000000000002', '0,650', 'KG', '14,90', '9,69'),
        _row('TOMATE SALADA', '0000000000003', '0,524', 'KG', '8,99', '4,71'),
        _row('CAFE PILAO 500G', '7890000000004', '1', 'UN', '18,99', '18,99'),
      ],
      total: '54,39',
    ),
  ),
  MockNfceSample(
    uf: 'AL',
    label: 'AL · Conveniência (4 itens)',
    chave: '27240612345678901234567890123456789012345678',
    html: _doc(
      emitente: 'SUPERMERCADO MACEIO LTDA',
      cnpj: '11.222.333/0001-44',
      cidade: 'Maceió/AL',
      emissao: '08/05/2026 19:05:12',
      rows: [
        _row('COCA-COLA 2L', '7894900010019', '3', 'UN', '9,99', '29,97'),
        _row('SABONETE DOVE 90G', '7891150042001', '4', 'UN', '3,49', '13,96'),
        _row(
          'MACARRAO ESPAGUETE GALO 500G',
          '7891000000001',
          '5',
          'PCT',
          '4,49',
          '22,45',
        ),
        _row(
          'FRANGO INTEIRO CONGELADO',
          '0000000000004',
          '1,800',
          'KG',
          '15,90',
          '28,62',
        ),
      ],
      total: '95,00',
    ),
  ),
];
