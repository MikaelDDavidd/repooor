import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/di/nfce_providers.dart';
import '../../domain/entities/nfce/imported_item_match.dart';
import '../../domain/entities/nfce/nfce_import_draft.dart';
import '../../domain/entities/nfce/nfce_invoice.dart';
import '../../domain/entities/nfce/nfce_qr_payload.dart';
import '../../domain/entities/purchase.dart';
import '../../domain/exceptions/nfce_exception.dart';
import 'pantry_providers.dart';
import 'purchase_providers.dart';

sealed class NfceImportState {
  const NfceImportState();
}

class NfceIdle extends NfceImportState {
  const NfceIdle();
}

class NfceFetching extends NfceImportState {
  const NfceFetching(this.payload);
  final NfceQrPayload payload;
}

class NfceMatching extends NfceImportState {
  const NfceMatching(this.invoice);
  final NfceInvoice invoice;
}

class NfceReviewing extends NfceImportState {
  const NfceReviewing(this.draft);
  final NfceImportDraft draft;
}

class NfceImporting extends NfceImportState {
  const NfceImporting(this.draft);
  final NfceImportDraft draft;
}

class NfceDone extends NfceImportState {
  const NfceDone({
    required this.purchaseId,
    required this.draft,
    this.reconciled = false,
  });
  final String purchaseId;
  final NfceImportDraft draft;
  final bool reconciled;
}

class NfceFailure extends NfceImportState {
  const NfceFailure(this.exception);
  final NfceException exception;
}

class NfceImportNotifier extends Notifier<NfceImportState> {
  String? _reconcileTargetId;

  @override
  NfceImportState build() => const NfceIdle();

  String? get reconcileTargetId => _reconcileTargetId;

  bool get isReconciling => _reconcileTargetId != null;

  void startReconciliation(String purchaseId) {
    _reconcileTargetId = purchaseId;
    state = const NfceIdle();
  }

  Future<void> onQrDetected(String raw) async {
    final parse = ref.read(parseNfceQrPayloadProvider);
    final NfceQrPayload payload;
    try {
      payload = parse(raw);
    } on NfceException catch (e) {
      state = NfceFailure(e);
      return;
    }
    state = NfceFetching(payload);
    try {
      final invoice = await ref.read(fetchNfceInvoiceProvider).call(payload);
      state = NfceMatching(invoice);
      final matches = await ref
          .read(matchProductsForImportProvider)
          .call(invoice);
      state = NfceReviewing(
        NfceImportDraft(invoice: invoice, matches: matches),
      );
    } on NfceException catch (e) {
      state = NfceFailure(e);
    } catch (_) {
      state = const NfceFailure(NfceParseException());
    }
  }

  void updateMatch(int index, ImportedItemMatch newMatch) {
    final current = state;
    if (current is! NfceReviewing) return;
    final updated = [...current.draft.matches]..[index] = newMatch;
    state = NfceReviewing(current.draft.copyWith(matches: updated));
  }

  void changeTargetType(PurchaseType type) {
    final current = state;
    if (current is! NfceReviewing) return;
    state = NfceReviewing(current.draft.copyWith(targetType: type));
  }

  Future<void> confirmImport() async {
    final current = state;
    if (current is! NfceReviewing) return;
    if (!current.draft.isReadyToImport) return;
    state = NfceImporting(current.draft);
    try {
      final targetId = _reconcileTargetId;
      final purchaseId = targetId == null
          ? await ref.read(importNfceAsPurchaseProvider).call(current.draft)
          : await ref
                .read(reconcilePurchaseWithNfceProvider)
                .call(targetId, current.draft);
      ref.invalidate(purchasesProvider);
      ref.invalidate(pantryProvider);
      if (targetId != null) ref.invalidate(purchaseItemsProvider(targetId));
      state = NfceDone(
        purchaseId: purchaseId,
        draft: current.draft,
        reconciled: targetId != null,
      );
    } on NfceException catch (e) {
      state = NfceFailure(e);
    } catch (e) {
      state = NfceFailure(NfceImportException(e.toString()));
    }
  }

  Future<void> loadMockHtml({
    required String uf,
    required String chave,
    required String html,
  }) async {
    final payload = NfceQrPayload(
      chave: chave,
      uf: uf,
      rawUrl: 'mock://nfce/$uf',
    );
    state = NfceFetching(payload);
    try {
      final invoice = ref
          .read(nfceParserRepositoryProvider)
          .parse(html, payload);
      state = NfceMatching(invoice);
      final matches = await ref
          .read(matchProductsForImportProvider)
          .call(invoice);
      state = NfceReviewing(
        NfceImportDraft(invoice: invoice, matches: matches),
      );
    } on NfceException catch (e) {
      state = NfceFailure(e);
    } catch (_) {
      state = const NfceFailure(NfceParseException());
    }
  }

  Future<void> retry() async {
    final current = state;
    if (current is NfceFetching) {
      await onQrDetected(current.payload.rawUrl);
    }
  }

  void reset() {
    _reconcileTargetId = null;
    state = const NfceIdle();
  }
}

final nfceImportProvider =
    NotifierProvider<NfceImportNotifier, NfceImportState>(
      NfceImportNotifier.new,
    );
