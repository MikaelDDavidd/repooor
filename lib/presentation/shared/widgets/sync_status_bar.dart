import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/sync/sync_status.dart';
import '../../providers/sync_providers.dart';

// Some quando não há nada a dizer: em dia e sem pendência não vira ruído.
class SyncStatusBar extends ConsumerWidget {
  const SyncStatusBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(syncStatusProvider).valueOrNull;
    if (status == null) return const SizedBox.shrink();

    final label = _labelFor(status);
    if (label == null) return const SizedBox.shrink();

    final isProblem = status.phase == SyncPhase.error;
    final color = isProblem ? AppColors.error : AppColors.textSecondary;

    return Container(
      width: double.infinity,
      color: AppColors.backgroundSecondary,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _leading(status, color),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              label,
              style: AppTextStyles.caption.copyWith(color: color),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _leading(SyncStatus status, Color color) {
    if (status.phase == SyncPhase.syncing) {
      return SizedBox(
        height: 12,
        width: 12,
        child: CircularProgressIndicator(strokeWidth: 2, color: color),
      );
    }
    return Icon(_iconFor(status.phase), size: 14, color: color);
  }

  IconData _iconFor(SyncPhase phase) => switch (phase) {
    SyncPhase.error => Icons.error_outline,
    SyncPhase.waitingConnection => Icons.cloud_off_outlined,
    _ => Icons.cloud_queue,
  };

  String? _labelFor(SyncStatus status) {
    return switch (status.phase) {
      SyncPhase.syncing => 'Sincronizando',
      SyncPhase.waitingConnection =>
        status.pending > 0
            ? 'Sem conexão. ${_itemLabel(status.pending)} para enviar'
            : 'Sem conexão',
      SyncPhase.error =>
        status.rejected > 0
            ? '${_itemLabel(status.rejected)} não sincronizaram'
            : 'Falha ao sincronizar',
      SyncPhase.idle =>
        status.pending > 0 ? '${_itemLabel(status.pending)} para enviar' : null,
    };
  }

  String _itemLabel(int count) =>
      count == 1 ? '1 alteração' : '$count alterações';
}
