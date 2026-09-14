import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_text_styles.dart';
import '../shared/widgets/app_empty_state.dart';

class NfceUnsupportedStatePage extends StatelessWidget {
  const NfceUnsupportedStatePage({super.key, required this.uf});

  final String uf;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Estado não suportado')),
      body: AppEmptyState(
        icon: Icons.location_off_outlined,
        title: 'NFC-e de $uf ainda não suportada',
        subtitle:
            'No momento aceitamos cupons fiscais de PE, PB e AL. Você pode registrar essa compra manualmente.',
        action: Column(
          children: [
            ElevatedButton(
              onPressed: () => context.go('/purchases'),
              child: const Text('Criar compra manualmente'),
            ),
            const SizedBox(height: 12),
            Text(
              'Vamos expandir gradualmente para os demais estados.',
              style: AppTextStyles.caption,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
