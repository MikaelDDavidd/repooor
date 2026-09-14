import '../purchase.dart';
import 'imported_item_match.dart';
import 'match_type.dart';
import 'nfce_invoice.dart';

class NfceImportDraft {
  const NfceImportDraft({
    required this.invoice,
    required this.matches,
    this.targetType = PurchaseType.midMonth,
  });

  final NfceInvoice invoice;
  final List<ImportedItemMatch> matches;
  final PurchaseType targetType;

  bool get isReadyToImport =>
      matches.isNotEmpty &&
      matches.every((m) => m.type != MatchType.unresolved);

  int get newProductCount =>
      matches.where((m) => m.type == MatchType.willCreateNew).length;

  NfceImportDraft copyWith({
    NfceInvoice? invoice,
    List<ImportedItemMatch>? matches,
    PurchaseType? targetType,
  }) {
    return NfceImportDraft(
      invoice: invoice ?? this.invoice,
      matches: matches ?? this.matches,
      targetType: targetType ?? this.targetType,
    );
  }
}
