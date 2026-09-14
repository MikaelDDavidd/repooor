import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/nfce_remote_ds.dart';
import '../../data/nfce/parsers/al_nfce_parser.dart';
import '../../data/nfce/parsers/nfce_parser.dart';
import '../../data/nfce/parsers/nfce_parser_factory.dart';
import '../../data/nfce/parsers/pb_nfce_parser.dart';
import '../../data/nfce/parsers/pe_nfce_parser.dart';
import '../../data/nfce/parsers/nfce_xml_parser.dart';
import '../../data/repositories/nfce_fetch_repository_impl.dart';
import '../../data/repositories/nfce_parser_repository_impl.dart';
import '../../data/repositories/product_match_repository_impl.dart';
import '../../domain/repositories/nfce_fetch_repository.dart';
import '../../domain/repositories/nfce_parser_repository.dart';
import '../../domain/repositories/product_match_repository.dart';
import '../../domain/usecases/nfce/fetch_nfce_invoice.dart';
import '../../domain/usecases/nfce/ensure_matched_products.dart';
import '../../domain/usecases/nfce/import_nfce_as_purchase.dart';
import '../../domain/usecases/projection/reconcile_purchase_with_nfce.dart';
import '../../domain/usecases/nfce/match_products_for_import.dart';
import '../../domain/usecases/nfce/parse_nfce_qr_payload.dart';
import '../../domain/usecases/nfce/suggest_category_for_name.dart';
import 'providers.dart';

final parseNfceQrPayloadProvider = Provider((_) => const ParseNfceQrPayload());

final nfceParsersProvider = Provider<List<NfceParser>>(
  (_) => const [PeNfceParser(), PbNfceParser(), AlNfceParser()],
);

final nfceParserFactoryProvider = Provider<NfceParserFactory>(
  (ref) => NfceParserFactory(ref.watch(nfceParsersProvider)),
);

final nfceXmlParserProvider = Provider<NfceXmlParser>(
  (_) => const NfceXmlParser(),
);

final nfceRemoteDsProvider = Provider<NfceRemoteDs>((_) => NfceRemoteDs());

final nfceFetchRepositoryProvider = Provider<NfceFetchRepository>(
  (ref) => NfceFetchRepositoryImpl(ref.watch(nfceRemoteDsProvider)),
);

final nfceParserRepositoryProvider = Provider<NfceParserRepository>(
  (ref) => NfceParserRepositoryImpl(
    ref.watch(nfceParserFactoryProvider),
    ref.watch(nfceXmlParserProvider),
  ),
);

final fetchNfceInvoiceProvider = Provider(
  (ref) => FetchNfceInvoice(
    ref.watch(nfceFetchRepositoryProvider),
    ref.watch(nfceParserRepositoryProvider),
  ),
);

final suggestCategoryForNameProvider = Provider(
  (ref) => SuggestCategoryForName(ref.watch(categoryRepositoryProvider)),
);

final productMatchRepositoryProvider = Provider<ProductMatchRepository>(
  (ref) => ProductMatchRepositoryImpl(
    ref.watch(productRepositoryProvider),
    ref.watch(suggestCategoryForNameProvider),
  ),
);

final matchProductsForImportProvider = Provider(
  (ref) => MatchProductsForImport(ref.watch(productMatchRepositoryProvider)),
);

final ensureMatchedProductsProvider = Provider(
  (ref) => EnsureMatchedProducts(ref.watch(productRepositoryProvider)),
);

final importNfceAsPurchaseProvider = Provider(
  (ref) => ImportNfceAsPurchase(
    ref.watch(ensureMatchedProductsProvider),
    ref.watch(purchaseRepositoryProvider),
    ref.watch(purchaseItemRepositoryProvider),
  ),
);

final reconcilePurchaseWithNfceProvider = Provider(
  (ref) => ReconcilePurchaseWithNfce(
    ref.watch(ensureMatchedProductsProvider),
    ref.watch(purchaseRepositoryProvider),
    ref.watch(purchaseItemRepositoryProvider),
  ),
);
