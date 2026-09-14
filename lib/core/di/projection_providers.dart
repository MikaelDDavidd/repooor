import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/usecases/projection/build_market_projection.dart';
import '../../domain/usecases/projection/create_purchase_from_projection.dart';
import '../../domain/usecases/projection/get_last_prices.dart';
import 'providers.dart';

final getLastPricesProvider = Provider(
  (ref) => GetLastPrices(ref.watch(purchaseRepositoryProvider)),
);

final buildMarketProjectionProvider = Provider(
  (ref) => BuildMarketProjection(
    ref.watch(pantryRepositoryProvider),
    ref.watch(productRepositoryProvider),
    ref.watch(getLastPricesProvider),
  ),
);

final createPurchaseFromProjectionProvider = Provider(
  (ref) => CreatePurchaseFromProjection(
    ref.watch(purchaseRepositoryProvider),
    ref.watch(purchaseItemRepositoryProvider),
  ),
);
