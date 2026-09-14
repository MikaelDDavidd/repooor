import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/dev/sample_data_seeder.dart';
import '../../core/di/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../providers/auth_providers.dart';
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
          _buildSectionLabel('Conta'),
          const SizedBox(height: 8),
          _buildAccountSection(context, ref),
          const SizedBox(height: 24),
          _buildSectionLabel('Dados'),
          const SizedBox(height: 8),
          _buildDataSection(context, ref),
          if (kDebugMode) ...[
            const SizedBox(height: 24),
            _buildSectionLabel('Desenvolvimento'),
            const SizedBox(height: 8),
            _buildDevSection(context, ref),
          ],
          const SizedBox(height: 24),
          _buildSectionLabel('Sobre'),
          const SizedBox(height: 8),
          _buildAboutSection(),
        ],
      ),
    );
  }

  Widget _buildDevSection(BuildContext context, WidgetRef ref) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: _buildTile(
        icon: Icons.science_outlined,
        title: 'Popular dados de exemplo',
        onTap: () => _seedSampleData(context, ref),
      ),
    );
  }

  Future<void> _seedSampleData(BuildContext context, WidgetRef ref) async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Popular dados de exemplo',
      content:
          'Vai adicionar 12 produtos, 6 itens na despensa e 4 compras (incluindo preços). Útil para testar a UI. Continuar?',
      confirmLabel: 'Popular',
    );
    if (confirmed != true) return;
    try {
      final result = await SampleDataSeeder.seed(ref);
      _invalidateAllProviders(ref);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${result.productCount} produtos e ${result.purchaseCount} compras adicionados',
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro ao popular dados: $e')));
      }
    }
  }

  Widget _buildAccountSection(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).valueOrNull;
    final name = user?.name ?? '';
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          ListTile(
            leading: const Icon(
              Icons.person_outline,
              color: AppColors.textPrimary,
            ),
            title: Text(
              name.isEmpty ? 'Conta' : name,
              style: AppTextStyles.body,
            ),
            subtitle: Text(user?.email ?? '', style: AppTextStyles.caption),
          ),
          const Divider(height: 1),
          _buildTile(
            icon: Icons.logout_outlined,
            title: 'Sair da conta',
            onTap: () => _signOut(context, ref),
          ),
        ],
      ),
    );
  }

  Future<void> _signOut(BuildContext context, WidgetRef ref) async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Sair da conta',
      content:
          'Seus dados continuam salvos neste aparelho. Você vai precisar entrar de novo para sincronizar.',
      confirmLabel: 'Sair',
    );
    if (confirmed != true) return;

    final failure = await ref.read(authControllerProvider.notifier).signOut();
    if (!context.mounted) return;
    if (failure == null) {
      context.go('/login');
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(failure.message)));
    }
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
      title: Text(title, style: AppTextStyles.body.copyWith(color: titleColor)),
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Erro ao exportar dados')));
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Erro ao importar dados')));
      }
    }
  }

  Future<void> _clearAllData(BuildContext context, WidgetRef ref) async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Limpar todos os dados',
      content:
          'Essa acao ira apagar todos os produtos, itens da despensa e compras. Nao pode ser desfeita.',
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Erro ao limpar dados')));
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
