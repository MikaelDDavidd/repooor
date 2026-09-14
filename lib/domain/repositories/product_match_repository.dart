import '../entities/nfce/imported_item_match.dart';
import '../entities/nfce/nfce_raw_item.dart';
import '../entities/product.dart';

abstract class ProductMatchRepository {
  Future<ImportedItemMatch> findMatch(NfceRawItem item);
  Future<List<Product>> searchSuggestions(String query, {int limit = 5});
}
