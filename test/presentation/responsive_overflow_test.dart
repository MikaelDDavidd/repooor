import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repooor/domain/entities/category.dart';
import 'package:repooor/domain/entities/nfce/imported_item_match.dart';
import 'package:repooor/domain/entities/nfce/match_type.dart';
import 'package:repooor/domain/entities/nfce/nfce_invoice.dart';
import 'package:repooor/domain/entities/nfce/nfce_raw_item.dart';
import 'package:repooor/domain/entities/product.dart';
import 'package:repooor/domain/entities/projection/market_projection.dart';
import 'package:repooor/domain/entities/projection/projected_item.dart';
import 'package:repooor/domain/entities/purchase_item.dart';
import 'package:repooor/core/theme/app_theme.dart';
import 'package:repooor/presentation/nfce/widgets/nfce_item_review_card.dart';
import 'package:repooor/presentation/nfce/widgets/nfce_review_header.dart';
import 'package:repooor/presentation/projection/widgets/projected_item_card.dart';
import 'package:repooor/presentation/projection/widgets/projection_summary_header.dart';
import 'package:repooor/presentation/purchase/widgets/purchase_item_price_label.dart';
import 'package:repooor/presentation/purchase/widgets/purchase_plan_summary.dart';
import 'package:repooor/presentation/purchase/widgets/purchase_total_chip.dart';
import 'package:repooor/presentation/shared/widgets/app_dialog.dart';
import 'package:repooor/presentation/shared/widgets/app_empty_state.dart';
import 'package:repooor/presentation/shared/widgets/app_error_state.dart';
import 'package:repooor/presentation/shared/widgets/app_sheet.dart';
import 'package:repooor/presentation/shared/widgets/category_section_header.dart';
import 'package:repooor/presentation/shared/widgets/confirm_dialog.dart';
import 'package:repooor/presentation/shared/widgets/pick_check_button.dart';
import 'package:repooor/presentation/shared/widgets/slide_to_confirm.dart';

/// Larguras reais: iPhone SE, Android comum, iPhone padrão,
/// iPhone Pro Max, iPad retrato, iPad paisagem.
const widths = <(double, String)>[
  (320, 'iPhone SE'),
  (360, 'Android comum'),
  (375, 'iPhone padrão'),
  (430, 'iPhone Pro Max'),
  (768, 'iPad retrato'),
  (1024, 'iPad paisagem'),
];

/// Escala de texto do sistema. 1.3 e 2.0 cobrem Dynamic Type / Fonte grande,
/// que é a principal causa de overflow no mundo real.
const textScales = <double>[1.0, 1.3, 2.0];

const longName =
    'BISCOITO ROSQUINHA SKIN CHOCOLATE 400G EMBALAGEM ECONOMICA FAMILIA';

const category = Category(
  id: 'c1',
  name: 'Mercearia e Cereais Integrais',
  icon: 0xe25a,
  color: 0xFF53B175,
);

const productLongName = Product(
  id: 'p1',
  name: longName,
  categoryId: 'c1',
  unit: 'pacote',
);

PurchaseItem purchaseItem({double? planned, double? plannedPrice}) =>
    PurchaseItem(
      id: 'i1',
      purchaseId: 'c1',
      productId: 'p1',
      quantity: 1234.567,
      unitPrice: 9876.54,
      plannedQuantity: planned,
      plannedUnitPrice: plannedPrice,
    );

ImportedItemMatch match(MatchType type) => ImportedItemMatch(
  source: const NfceRawItem(
    rawName: longName,
    quantity: 1234.5,
    unitRaw: 'PACOTE',
    unitPrice: 9876.54,
  ),
  type: type,
  matchedProduct: productLongName,
  resolvedQuantity: 1234.5,
  resolvedUnit: 'pacote',
  resolvedUnitPrice: 9876.54,
);

/// Cada caso é um widget com conteúdo hostil: nome longo, valor alto,
/// unidade comprida. Se cabe aqui, cabe no uso real.
final cases = <String, Widget>{
  'ProjectedItemCard (a pegar)': ProjectedItemCard(
    item: const ProjectedItem(
      product: productLongName,
      quantity: 1234.5,
      currentQuantity: 987.5,
      idealQuantity: 2222.0,
      unitPrice: 9876.54,
    ),
    category: category,
    onIncrement: () {},
    onDecrement: () {},
    onRemove: () {},
    onTogglePicked: () {},
  ),
  'ProjectedItemCard (no carrinho)': ProjectedItemCard(
    item: const ProjectedItem(
      product: productLongName,
      quantity: 1234.5,
      currentQuantity: 987.5,
      idealQuantity: 2222.0,
      unitPrice: 9876.54,
      picked: true,
    ),
    category: category,
    onIncrement: () {},
    onDecrement: () {},
    onRemove: () {},
    onTogglePicked: () {},
  ),
  'ProjectedItemCard (sem preço)': ProjectedItemCard(
    item: const ProjectedItem(
      product: productLongName,
      quantity: 3,
      currentQuantity: 1,
      idealQuantity: 4,
    ),
    category: category,
    onIncrement: () {},
    onDecrement: () {},
    onRemove: () {},
    onTogglePicked: () {},
  ),
  'ProjectionSummaryHeader': const ProjectionSummaryHeader(
    projection: MarketProjection(
      items: [
        ProjectedItem(
          product: productLongName,
          quantity: 1234.5,
          currentQuantity: 1,
          idealQuantity: 2,
          unitPrice: 9876.54,
          picked: true,
        ),
        ProjectedItem(
          product: productLongName,
          quantity: 2,
          currentQuantity: 0,
          idealQuantity: 2,
        ),
      ],
    ),
  ),
  'PurchasePlanSummary (conciliado)': PurchasePlanSummary(
    items: [purchaseItem(planned: 1000, plannedPrice: 1234.56)],
  ),
  'PurchaseItemPriceLabel': const PurchaseItemPriceLabel(
    quantity: 1234.567,
    unit: 'pacote',
    unitPrice: 9876.54,
  ),
  'PurchaseTotalChip (parcial)': const PurchaseTotalChip(
    total: 98765.43,
    partial: true,
  ),
  'NfceItemReviewCard (parecido)': NfceItemReviewCard(
    match: match(MatchType.fuzzyLow),
    onChangeMatch: () {},
  ),
  'NfceItemReviewCard (novo)': NfceItemReviewCard(
    match: match(MatchType.willCreateNew),
    onChangeMatch: () {},
  ),
  'NfceReviewHeader': NfceReviewHeader(
    invoice: NfceInvoice(
      chave: '26260741797488000107650010000587661002268142',
      issuedAt: DateTime(2026, 7, 26, 18, 45),
      emitenteNome: 'JOSE JAILSON DE ALBUQUERQUE COMERCIAL BRASIL LTDA ME',
      emitenteCnpj: '41.797.488/0001-07',
      uf: 'PE',
      items: const [
        NfceRawItem(
          rawName: longName,
          quantity: 1,
          unitRaw: 'UN',
          unitPrice: 9876.54,
        ),
      ],
    ),
  ),
  'CategorySectionHeader': const CategorySectionHeader(category: category),
  'AppEmptyState': const AppEmptyState(
    icon: Icons.kitchen_outlined,
    title: 'Nenhum item na despensa por enquanto',
    subtitle:
        'Adicione produtos para controlar seu estoque e projetar o mercado do mês com estimativa de gasto',
  ),
  'AppErrorState': const AppErrorState(
    message:
        'Não foi possível carregar a despensa agora. Verifique sua conexão e tente de novo em alguns instantes.',
  ),
  'AppDialog': const AppDialog(
    title: 'Confirmar a importação desta nota fiscal?',
    message:
        'Os valores reais da nota entram no lugar dos projetados, e o que você projetou fica guardado para comparação depois.',
    icon: Icons.receipt_long,
    primaryAction: AppDialogAction(label: 'Importar agora'),
    secondaryAction: AppDialogAction(label: 'Cancelar'),
  ),
  'ConfirmDialog (destrutivo)': const ConfirmDialog(
    title: 'Remover este produto da despensa?',
    content:
        'Essa ação não pode ser desfeita e o histórico de compras do produto continua registrado.',
    isDestructive: true,
    confirmLabel: 'Remover mesmo assim',
  ),
  'AppSheet': const AppSheet(
    title: 'Escolha o que fazer com a despensa',
    subtitle: 'Cadastrar um produto novo ou projetar o mercado do mês',
    child: Text('conteúdo'),
  ),
  'SlideToConfirm': SlideToConfirm(
    label: 'Arraste para desmarcar este item do carrinho',
    onConfirmed: () {},
  ),
  'PickCheckButton': PickCheckButton(
    picked: true,
    onPressed: () {},
    fallbackIcon: Icons.category,
    fallbackColor: const Color(0xFF53B175),
  ),
};

void main() {
  for (final entry in widths) {
    final width = entry.$1;
    final device = entry.$2;

    for (final scale in textScales) {
      group('$device (${width.toInt()}px) · texto ${scale}x', () {
        for (final testCase in cases.entries) {
          testWidgets('${testCase.key} não estoura', (tester) async {
            tester.view.physicalSize = Size(width, 1400);
            tester.view.devicePixelRatio = 1;
            addTearDown(tester.view.resetPhysicalSize);
            addTearDown(tester.view.resetDevicePixelRatio);

            await tester.pumpWidget(
              MediaQuery(
                data: MediaQueryData(textScaler: TextScaler.linear(scale)),
                child: MaterialApp(
                  theme: AppTheme.light,
                  home: Scaffold(
                    body: SingleChildScrollView(child: testCase.value),
                  ),
                ),
              ),
            );
            await tester.pump();

            expect(
              tester.takeException(),
              isNull,
              reason: '${testCase.key} estourou em $device com texto ${scale}x',
            );
          });
        }
      });
    }
  }
}
