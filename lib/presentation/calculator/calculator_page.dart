import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../providers/calculator_providers.dart';

class CalculatorPage extends ConsumerWidget {
  const CalculatorPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Calculadora'),
        actions: [
          TextButton(
            onPressed: () => ref.read(calculatorProvider.notifier).clearAll(),
            child: const Text('Limpar'),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const Expanded(flex: 2, child: _CalculatorDisplay()),
            const Divider(height: 1),
            const Expanded(flex: 3, child: _ButtonGrid()),
          ],
        ),
      ),
    );
  }
}

class _CalculatorDisplay extends ConsumerWidget {
  const _CalculatorDisplay();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(calculatorProvider);

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Expanded(
            child: state.history.isEmpty
                ? const SizedBox.shrink()
                : ListView.builder(
                    reverse: true,
                    itemCount: state.history.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          state.history[index],
                          style: AppTextStyles.bodySecondary,
                          textAlign: TextAlign.right,
                        ),
                      );
                    },
                  ),
          ),
          if (state.expression.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  state.expression,
                  style: AppTextStyles.bodySecondary,
                ),
              ),
            ),
          Align(
            alignment: Alignment.centerRight,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerRight,
              child: Text(
                state.display,
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w300,
                  color: AppColors.textPrimary,
                ),
                maxLines: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ButtonGrid extends ConsumerWidget {
  const _ButtonGrid();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(calculatorProvider.notifier);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildRow([
            _CalcButton(label: 'AC', type: _ButtonType.function, onTap: notifier.clear),
            _CalcButton(label: '+/-', type: _ButtonType.function, onTap: notifier.toggleSign),
            _CalcButton(label: '%', type: _ButtonType.function, onTap: notifier.percentage),
            _CalcButton(label: '\u00f7', type: _ButtonType.operation, onTap: () => notifier.inputOperation('\u00f7')),
          ]),
          const SizedBox(height: 12),
          _buildRow([
            _CalcButton(label: '7', onTap: () => notifier.inputDigit('7')),
            _CalcButton(label: '8', onTap: () => notifier.inputDigit('8')),
            _CalcButton(label: '9', onTap: () => notifier.inputDigit('9')),
            _CalcButton(label: '\u00d7', type: _ButtonType.operation, onTap: () => notifier.inputOperation('\u00d7')),
          ]),
          const SizedBox(height: 12),
          _buildRow([
            _CalcButton(label: '4', onTap: () => notifier.inputDigit('4')),
            _CalcButton(label: '5', onTap: () => notifier.inputDigit('5')),
            _CalcButton(label: '6', onTap: () => notifier.inputDigit('6')),
            _CalcButton(label: '-', type: _ButtonType.operation, onTap: () => notifier.inputOperation('-')),
          ]),
          const SizedBox(height: 12),
          _buildRow([
            _CalcButton(label: '1', onTap: () => notifier.inputDigit('1')),
            _CalcButton(label: '2', onTap: () => notifier.inputDigit('2')),
            _CalcButton(label: '3', onTap: () => notifier.inputDigit('3')),
            _CalcButton(label: '+', type: _ButtonType.operation, onTap: () => notifier.inputOperation('+')),
          ]),
          const SizedBox(height: 12),
          _buildRow([
            _CalcButton(label: '0', flex: 2, onTap: () => notifier.inputDigit('0')),
            _CalcButton(label: '.', onTap: notifier.inputDecimal),
            _CalcButton(label: '=', type: _ButtonType.operation, onTap: notifier.calculate),
          ]),
        ],
      ),
    );
  }

  Widget _buildRow(List<_CalcButton> buttons) {
    return Expanded(
      child: Row(
        children: buttons
            .expand((btn) => [
                  Expanded(flex: btn.flex, child: btn),
                  const SizedBox(width: 12),
                ])
            .toList()
          ..removeLast(),
      ),
    );
  }
}

enum _ButtonType { number, operation, function }

class _CalcButton extends StatelessWidget {
  final String label;
  final _ButtonType type;
  final VoidCallback onTap;
  final int flex;

  const _CalcButton({
    required this.label,
    this.type = _ButtonType.number,
    required this.onTap,
    this.flex = 1,
  });

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (type) {
      _ButtonType.number => (AppColors.backgroundSecondary, AppColors.textPrimary),
      _ButtonType.operation => (AppColors.primary, AppColors.onPrimary),
      _ButtonType.function => (AppColors.border, AppColors.textPrimary),
    };

    return SizedBox.expand(
      child: Material(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w500,
                color: fg,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
