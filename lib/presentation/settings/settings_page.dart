import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/di/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../providers/category_providers.dart';
import '../providers/pantry_providers.dart';
import '../providers/product_providers.dart';
import '../providers/purchase_providers.dart';
import '../shared/widgets/confirm_dialog.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.backgroundSecondary,
      appBar: AppBar(title: const Text('Configuracoes')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionLabel('Dados'),
          const SizedBox(height: 8),
          _buildDataSection(context, ref),
          const SizedBox(height: 24),
          _buildSectionLabel('Sobre'),
          const SizedBox(height: 8),
          _buildAboutSection(),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: AppTextStyles.bodySecondary.copyWith(fontWeight: FontWeight.w600),
    );
  }

  Widget _buildDataSection(BuildContext context, WidgetRef ref) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          _buildTile(
            icon: Icons.category_outlined,
            title: 'Gerenciar categorias',
            onTap: () => context.push('/categories'),
          ),
          const Divider(height: 1),
          _buildTile(
            icon: Icons.upload_outlined,
            title: 'Exportar dados',
            onTap: () => _exportData(context, ref),
          ),
          const Divider(height: 1),
          _buildTile(
            icon: Icons.download_outlined,
            title: 'Importar dados',
            onTap: () => _importData(context, ref),
          ),
          const Divider(height: 1),
          _buildTile(
            icon: Icons.delete_forever_outlined,
            title: 'Limpar todos os dados',
            iconColor: AppColors.error,
            titleColor: AppColors.error,
            onTap: () => _clearAllData(context, ref),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          ListTile(
            title: Text('Repooor', style: AppTextStyles.body),
            subtitle: Text(
              'Gestao de despensa domestica',
              style: AppTextStyles.caption,
            ),
          ),
          const Divider(height: 1),
          ListTile(
            title: Text('Versao', style: AppTextStyles.body),
            trailing: Text('1.0.0', style: AppTextStyles.bodySecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? iconColor,
    Color? titleColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor ?? AppColors.textPrimary),
      title: Text(
        title,
        style: AppTextStyles.body.copyWith(color: titleColor),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: iconColor ?? AppColors.textSecondary,
      ),
      onTap: onTap,
    );
  }

  Future<void> _exportData(BuildContext context, WidgetRef ref) async {
    try {
      final data = await ref.read(exportDataProvider).call();
      final jsonString = jsonEncode(data);
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/repooor_backup.json');
      await file.writeAsString(jsonString);
      await Share.shareXFiles([XFile(file.path)], subject: 'Repooor Backup');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Dados exportados com sucesso')),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao exportar dados')),
        );
      }
    }
  }

  Future<void> _importData(BuildContext context, WidgetRef ref) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );
      if (result == null || result.files.single.path == null) return;

      final file = File(result.files.single.path!);
      final content = await file.readAsString();
      final data = jsonDecode(content) as Map<String, dynamic>;

      if (!context.mounted) return;
      final confirmed = await ConfirmDialog.show(
        context,
        title: 'Importar dados',
        content: 'Isso ira substituir todos os dados atuais. Deseja continuar?',
        confirmLabel: 'Importar',
        isDestructive: true,
      );
      if (confirmed != true) return;

      await ref.read(importDataProvider).call(data);
      _invalidateAllProviders(ref);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Dados importados com sucesso')),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao importar dados')),
        );
      }
    }
  }

  Future<void> _clearAllData(BuildContext context, WidgetRef ref) async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Limpar todos os dados',
      content: 'Essa acao ira apagar todos os produtos, itens da despensa e compras. Nao pode ser desfeita.',
      confirmLabel: 'Limpar tudo',
      isDestructive: true,
    );
    if (confirmed != true) return;

    try {
      await ref.read(clearAllDataProvider).call();
      _invalidateAllProviders(ref);
      if (context.mounted) {
        context.go('/home');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Todos os dados foram apagados')),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao limpar dados')),
        );
      }
    }
  }

  void _invalidateAllProviders(WidgetRef ref) {
    ref.invalidate(productsProvider);
    ref.invalidate(categoriesProvider);
    ref.invalidate(pantryProvider);
    ref.invalidate(purchasesProvider);
  }
}
