import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repooor/domain/entities/nfce/imported_item_match.dart';
import 'package:repooor/domain/entities/nfce/match_type.dart';
import 'package:repooor/domain/entities/nfce/nfce_raw_item.dart';
import 'package:repooor/presentation/nfce/widgets/nfce_item_review_card.dart';

void main() {
  const longRawName =
      'BISCOITO ROSQUINHA SKIN CHOCOLATE 400G EMBALAGEM ECONOMICA';

  ImportedItemMatch buildMatch(MatchType type) {
    return const ImportedItemMatch(
      source: NfceRawItem(
        rawName: longRawName,
        quantity: 1,
        unitRaw: 'UN',
        unitPrice: 4.45,
      ),
      type: MatchType.fuzzyLow,
      resolvedQuantity: 1,
      resolvedUnit: 'un',
      resolvedUnitPrice: 4.45,
      newProductName: 'Chocolate',
    ).copyWith(type: type);
  }

  Future<void> pumpCard(WidgetTester tester, MatchType type) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: NfceItemReviewCard(
            match: buildMatch(type),
            onChangeMatch: () {},
          ),
        ),
      ),
    );
  }

  testWidgets('does not overflow with a long raw name', (tester) async {
    await pumpCard(tester, MatchType.fuzzyLow);
    expect(tester.takeException(), isNull);
  });

  testWidgets('does not overflow for a new product', (tester) async {
    await pumpCard(tester, MatchType.willCreateNew);
    expect(tester.takeException(), isNull);
  });

  testWidgets('hides the raw name when the match is exact', (tester) async {
    await pumpCard(tester, MatchType.exact);
    expect(tester.takeException(), isNull);
    expect(find.textContaining('da nota:'), findsNothing);
  });

  testWidgets('shows the raw name when the match is not exact', (tester) async {
    await pumpCard(tester, MatchType.fuzzyLow);
    expect(find.textContaining('da nota:'), findsOneWidget);
  });
}
