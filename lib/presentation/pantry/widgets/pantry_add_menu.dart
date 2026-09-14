import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../projection/market_projection_page.dart';
import '../../shared/widgets/app_sheet.dart';
import '../pantry_add_page.dart';

class PantryAddMenu extends StatelessWidget {
  const PantryAddMenu({super.key});

  static Future<void> show(BuildContext context) {
    return AppSheet.show<void>(context, builder: (_) => const PantryAddMenu());
  }

  void _open(BuildContext context, Widget page) {
    Navigator.of(context).pop();
    Navigator.of(
      context,
      rootNavigator: true,
    ).push(MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    return AppSheet(
      padding: EdgeInsets.zero,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _MenuTile(
            icon: Icons.add_shopping_cart_outlined,
            title: 'Adicionar à despensa',
            subtitle: 'Cadastrar um produto no seu estoque',
            onTap: () => _open(context, const PantryAddPage()),
          ),
          _MenuTile(
            icon: Icons.query_stats_outlined,
            title: 'Projetar mercado',
            subtitle:
                'Estimar o gasto para repor tudo que está abaixo do ideal',
            onTap: () => _open(context, const MarketProjectionPage()),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.primaryLight,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: AppColors.primaryStrong),
      ),
      title: Text(title, style: AppTextStyles.body),
      subtitle: Text(subtitle, style: AppTextStyles.caption),
    );
  }
}
