import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/nfce/nfce_import_draft.dart';
import '../../domain/exceptions/nfce_exception.dart';
import '../providers/nfce_providers.dart';
import '../purchase/purchase_detail_page.dart';
import '../shared/widgets/app_empty_state.dart';
import '../shared/widgets/app_error_state.dart';
import '../shared/widgets/confirm_dialog.dart';
import 'widgets/import_progress_indicator.dart';
import 'widgets/import_summary_sheet.dart';
import 'widgets/nfce_exception_message.dart';
import 'widgets/nfce_import_fab_actions.dart';
import 'widgets/nfce_item_review_card.dart';
import 'widgets/nfce_review_header.dart';
import 'widgets/nfce_review_skeleton.dart';
import 'widgets/product_match_picker_dialog.dart';

class NfceImportReviewPage extends ConsumerStatefulWidget {
  const NfceImportReviewPage({super.key});

  @override
  ConsumerState<NfceImportReviewPage> createState() =>
      _NfceImportReviewPageState();
}

class _NfceImportReviewPageState extends ConsumerState<NfceImportReviewPage> {
  bool _summaryShown = false;

  @override
  Widget build(BuildContext context) {
    ref.listen(nfceImportProvider, (_, next) {
      if (next is NfceDone && !_summaryShown) {
        _summaryShown = true;
        _showSummary(next);
      }
    });
    final state = ref.watch(nfceImportProvider);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        await _handleExit();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Revisar importação'),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: _handleExit,
          ),
        ),
        body: switch (state) {
          NfceIdle() => const _EmptyState(),
          NfceFetching() => const NfceReviewSkeleton(),
          NfceMatching() => const NfceReviewSkeleton(),
          NfceReviewing(:final draft) => _Reviewing(draft: draft),
          NfceImporting(:final draft) => ImportProgressIndicator(draft: draft),
          NfceDone(:final draft) => ImportProgressIndicator(draft: draft),
          NfceFailure(:final exception) => _Failure(exception: exception),
        },
        bottomNavigationBar: state is NfceReviewing
            ? NfceImportFabActions(draft: state.draft)
            : null,
      ),
    );
  }

  Future<void> _handleExit() async {
    final current = ref.read(nfceImportProvider);
    final shouldConfirm =
        current is NfceFetching ||
        current is NfceMatching ||
        current is NfceReviewing;
    if (shouldConfirm) {
      final confirmed = await ConfirmDialog.show(
        context,
        title: 'Descartar importação?',
        content:
            'Os dados desta nota serão perdidos. Você pode escanear de novo a qualquer momento.',
        confirmLabel: 'Descartar',
        cancelLabel: 'Continuar',
        isDestructive: true,
      );
      if (confirmed != true) return;
    }
    ref.read(nfceImportProvider.notifier).reset();
    if (mounted) context.go('/purchases');
  }

  Future<void> _showSummary(NfceDone done) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => ImportSummarySheet(
        draft: done.draft,
        reconciled: done.reconciled,
        onViewPurchase: () {
          Navigator.of(context).pop();
          ref.read(nfceImportProvider.notifier).reset();
          context.go('/purchases');
          Navigator.of(context, rootNavigator: true).push(
            MaterialPageRoute(
              builder: (_) => PurchaseDetailPage(purchaseId: done.purchaseId),
            ),
          );
        },
        onDone: () {
          Navigator.of(context).pop();
          ref.read(nfceImportProvider.notifier).reset();
          context.go('/purchases');
        },
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return AppEmptyState(
      icon: Icons.qr_code_scanner,
      title: 'Nenhuma nota carregada',
      subtitle: 'Volte e escaneie um cupom fiscal.',
      action: ElevatedButton(
        onPressed: () => context.go('/nfce/scan'),
        child: const Text('Escanear'),
      ),
    );
  }
}

class _Reviewing extends ConsumerWidget {
  const _Reviewing({required this.draft});

  final NfceImportDraft draft;

  Future<void> _openPicker(
    BuildContext context,
    WidgetRef ref,
    int index,
  ) async {
    final updated = await ProductMatchPickerDialog.show(
      context,
      draft.matches[index],
    );
    if (updated != null) {
      ref.read(nfceImportProvider.notifier).updateMatch(index, updated);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        NfceReviewHeader(invoice: draft.invoice),
        const SizedBox(height: 16),
        for (var i = 0; i < draft.matches.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: NfceItemReviewCard(
              match: draft.matches[i],
              onChangeMatch: () => _openPicker(context, ref, i),
            ),
          ),
        const SizedBox(height: 80),
      ],
    );
  }
}

class _Failure extends ConsumerWidget {
  const _Failure({required this.exception});

  final NfceException exception;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppErrorState(
      message: nfceExceptionToUserMessage(exception),
      onRetry: () => ref.read(nfceImportProvider.notifier).retry(),
    );
  }
}
