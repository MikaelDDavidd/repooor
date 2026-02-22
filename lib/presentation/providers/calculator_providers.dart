import 'package:flutter_riverpod/flutter_riverpod.dart';

class CalculatorState {
  final String display;
  final String expression;
  final List<String> history;
  final bool shouldResetOnNextInput;

  const CalculatorState({
    this.display = '0',
    this.expression = '',
    this.history = const [],
    this.shouldResetOnNextInput = false,
  });

  CalculatorState copyWith({
    String? display,
    String? expression,
    List<String>? history,
    bool? shouldResetOnNextInput,
  }) {
    return CalculatorState(
      display: display ?? this.display,
      expression: expression ?? this.expression,
      history: history ?? this.history,
      shouldResetOnNextInput:
          shouldResetOnNextInput ?? this.shouldResetOnNextInput,
    );
  }
}

class CalculatorNotifier extends Notifier<CalculatorState> {
  double? _firstOperand;
  String? _pendingOperation;

  @override
  CalculatorState build() => const CalculatorState();

  void inputDigit(String digit) {
    if (state.display.replaceAll('-', '').replaceAll('.', '').length >= 12 &&
        !state.shouldResetOnNextInput) {
      return;
    }

    if (state.shouldResetOnNextInput) {
      state = state.copyWith(
        display: digit,
        shouldResetOnNextInput: false,
      );
      return;
    }

    final newDisplay = state.display == '0' ? digit : '${state.display}$digit';
    state = state.copyWith(display: newDisplay);
  }

  void inputDecimal() {
    if (state.shouldResetOnNextInput) {
      state = state.copyWith(
        display: '0.',
        shouldResetOnNextInput: false,
      );
      return;
    }

    if (state.display.contains('.')) return;
    state = state.copyWith(display: '${state.display}.');
  }

  void inputOperation(String op) {
    final current = double.tryParse(state.display);
    if (current == null) return;

    if (_firstOperand != null && _pendingOperation != null && !state.shouldResetOnNextInput) {
      final result = _evaluate(_firstOperand!, current, _pendingOperation!);
      if (result == null) {
        state = state.copyWith(
          display: 'Erro',
          expression: '',
          shouldResetOnNextInput: true,
        );
        _firstOperand = null;
        _pendingOperation = null;
        return;
      }
      _firstOperand = result;
      state = state.copyWith(
        display: _formatNumber(result),
        expression: '${_formatNumber(result)} $op',
        shouldResetOnNextInput: true,
      );
    } else {
      _firstOperand = current;
      state = state.copyWith(
        expression: '${state.display} $op',
        shouldResetOnNextInput: true,
      );
    }

    _pendingOperation = op;
  }

  void calculate() {
    if (_firstOperand == null || _pendingOperation == null) return;

    final current = double.tryParse(state.display);
    if (current == null) return;

    final result = _evaluate(_firstOperand!, current, _pendingOperation!);
    final expressionStr =
        '${state.expression} ${state.display}';

    if (result == null) {
      state = state.copyWith(
        display: 'Erro',
        expression: '',
        history: ['$expressionStr = Erro', ...state.history],
        shouldResetOnNextInput: true,
      );
    } else {
      state = state.copyWith(
        display: _formatNumber(result),
        expression: '',
        history: [
          '$expressionStr = ${_formatNumber(result)}',
          ...state.history,
        ],
        shouldResetOnNextInput: true,
      );
    }

    _firstOperand = null;
    _pendingOperation = null;
  }

  void clear() {
    state = state.copyWith(
      display: '0',
      expression: '',
      shouldResetOnNextInput: false,
    );
    _firstOperand = null;
    _pendingOperation = null;
  }

  void clearAll() {
    state = const CalculatorState();
    _firstOperand = null;
    _pendingOperation = null;
  }

  void backspace() {
    if (state.shouldResetOnNextInput || state.display == 'Erro') {
      state = state.copyWith(display: '0', shouldResetOnNextInput: false);
      return;
    }

    if (state.display.length <= 1 ||
        (state.display.length == 2 && state.display.startsWith('-'))) {
      state = state.copyWith(display: '0');
      return;
    }

    state = state.copyWith(
      display: state.display.substring(0, state.display.length - 1),
    );
  }

  void toggleSign() {
    if (state.display == '0' || state.display == 'Erro') return;

    if (state.display.startsWith('-')) {
      state = state.copyWith(display: state.display.substring(1));
    } else {
      state = state.copyWith(display: '-${state.display}');
    }
  }

  void percentage() {
    final current = double.tryParse(state.display);
    if (current == null) return;

    final result = current / 100;
    state = state.copyWith(
      display: _formatNumber(result),
      shouldResetOnNextInput: true,
    );
  }

  double? _evaluate(double a, double b, String op) {
    return switch (op) {
      '+' => a + b,
      '-' => a - b,
      '\u00d7' => a * b,
      '\u00f7' => b == 0 ? null : a / b,
      _ => null,
    };
  }

  String _formatNumber(double value) {
    if (value == value.truncateToDouble() && !value.isInfinite && !value.isNaN) {
      return value.toInt().toString();
    }
    final str = value.toStringAsFixed(8);
    return str.contains('.') ? str.replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '') : str;
  }
}

final calculatorProvider =
    NotifierProvider<CalculatorNotifier, CalculatorState>(
  CalculatorNotifier.new,
);
