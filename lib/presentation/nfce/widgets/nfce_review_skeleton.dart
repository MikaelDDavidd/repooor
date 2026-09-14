import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../../domain/entities/nfce/imported_item_match.dart';
import '../../../domain/entities/nfce/match_type.dart';
import '../../../domain/entities/nfce/nfce_invoice.dart';
import '../../../domain/entities/nfce/nfce_raw_item.dart';
import 'nfce_item_review_card.dart';
import 'nfce_review_header.dart';

class NfceReviewSkeleton extends StatelessWidget {
  const NfceReviewSkeleton({super.key});

  static final NfceInvoice _dummyInvoice = NfceInvoice(
    chave: '00000000000000000000000000000000000000000000',
    issuedAt: DateTime(2026, 1, 1, 12),
    emitenteNome: 'Estabelecimento exemplo Ltda',
    emitenteCnpj: '00.000.000/0001-00',
    uf: 'PE',
    items: const [],
  );

  static const List<ImportedItemMatch> _dummyMatches = [
    ImportedItemMatch(
      source: NfceRawItem(
        rawName: 'Produto exemplo um',
        quantity: 2,
        unitRaw: 'UN',
        unitPrice: 9.99,
      ),
      type: MatchType.exact,
      resolvedQuantity: 2,
      resolvedUnit: 'un',
      resolvedUnitPrice: 9.99,
    ),
    ImportedItemMatch(
      source: NfceRawItem(
        rawName: 'Produto exemplo dois',
        quantity: 1,
        unitRaw: 'KG',
        unitPrice: 19.99,
      ),
      type: MatchType.fuzzyHigh,
      resolvedQuantity: 1,
      resolvedUnit: 'kg',
      resolvedUnitPrice: 19.99,
    ),
    ImportedItemMatch(
      source: NfceRawItem(
        rawName: 'Produto exemplo três',
        quantity: 3,
        unitRaw: 'UN',
        unitPrice: 4.5,
      ),
      type: MatchType.willCreateNew,
      resolvedQuantity: 3,
      resolvedUnit: 'un',
      resolvedUnitPrice: 4.5,
    ),
    ImportedItemMatch(
      source: NfceRawItem(
        rawName: 'Produto exemplo quatro',
        quantity: 5,
        unitRaw: 'UN',
        unitPrice: 2.5,
      ),
      type: MatchType.fuzzyLow,
      resolvedQuantity: 5,
      resolvedUnit: 'un',
      resolvedUnitPrice: 2.5,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: true,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          NfceReviewHeader(invoice: _dummyInvoice),
          const SizedBox(height: 16),
          for (final match in _dummyMatches)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: NfceItemReviewCard(match: match, onChangeMatch: () {}),
            ),
        ],
      ),
    );
  }
}
