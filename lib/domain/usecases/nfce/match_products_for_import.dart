import '../../entities/nfce/imported_item_match.dart';
import '../../entities/nfce/nfce_invoice.dart';
import '../../repositories/product_match_repository.dart';

class MatchProductsForImport {
  const MatchProductsForImport(this._repository);

  final ProductMatchRepository _repository;

  Future<List<ImportedItemMatch>> call(NfceInvoice invoice) async {
    final matches = <ImportedItemMatch>[];
    for (final item in invoice.items) {
      matches.add(await _repository.findMatch(item));
    }
    return matches;
  }
}
