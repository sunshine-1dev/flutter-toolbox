import 'package:flutter/material.dart';
import 'dart:math';

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({super.key});

  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  String _display = '0';
  String _expression = '';
  double _result = 0;
  bool _isNewNumber = true;
  String _operator = '';
  double _firstOperand = 0;
  bool _isScientific = false;
  bool _hasDecimal = false;

  void _onDigit(String digit) {
    setState(() {
      if (_isNewNumber) {
        _display = digit;
        _isNewNumber = false;
        _hasDecimal = false;
      } else {
        _display += digit;
      }
    });
  }

  void _onDecimal() {
    if (_hasDecimal) return;
    setState(() {
      if (_isNewNumber) {
        _display = '0.';
        _isNewNumber = false;
      } else {
        _display += '.';
      }
      _hasDecimal = true;
    });
  }

  void _onOperator(String op) {
    setState(() {
      _firstOperand = double.tryParse(_display) ?? 0;
      _operator = op;
      _expression = '$_display $op';
      _isNewNumber = true;
      _hasDecimal = false;
    });
  }

  void _onEquals() {
    if (_operator.isEmpty) return;
    final second = double.tryParse(_display) ?? 0;
    double result = 0;

    switch (_operator) {
      case '+':
        result = _firstOperand + second;
        break;
      case '-':
        result = _firstOperand - second;
        break;
      case '×':
        result = _firstOperand * second;
        break;
      case '÷':
        result = second != 0 ? _firstOperand / second : double.infinity;
        break;
      case '%':
        result = _firstOperand % second;
        break;
      case '^':
        result = pow(_firstOperand, second).toDouble();
        break;
    }

    setState(() {
      _expression = '$_expression $_display =';
      _result = result;
      _display = _formatNumber(result);
      _operator = '';
      _isNewNumber = true;
      _hasDecimal = false;
    });
  }

  void _onClear() {
    setState(() {
      _display = '0';
      _expression = '';
      _result = 0;
      _isNewNumber = true;
      _operator = '';
      _firstOperand = 0;
      _hasDecimal = false;
    });
  }

  void _onBackspace() {
    setState(() {
      if (_display.length > 1) {
        if (_display.endsWith('.')) _hasDecimal = false;
        _display = _display.substring(0, _display.length - 1);
      } else {
        _display = '0';
        _isNewNumber = true;
      }
    });
  }

  void _onNegate() {
    setState(() {
      if (_display != '0') {
        if (_display.startsWith('-')) {
          _display = _display.substring(1);
        } else {
          _display = '-$_display';
        }
      }
    });
  }

  void _onScientific(String func) {
    final value = double.tryParse(_display) ?? 0;
    double result = 0;

    switch (func) {
      case 'sin':
        result = sin(value * pi / 180);
        break;
      case 'cos':
        result = cos(value * pi / 180);
        break;
      case 'tan':
        result = tan(value * pi / 180);
        break;
      case '√':
        result = sqrt(value);
        break;
      case 'ln':
        result = log(value);
        break;
      case 'log':
        result = log(value) / ln10;
        break;
      case 'x²':
        result = value * value;
        break;
      case 'x!':
        result = _factorial(value.toInt()).toDouble();
        break;
      case 'π':
        result = pi;
        break;
      case 'e':
        result = e;
        break;
      case '1/x':
        result = value != 0 ? 1 / value : double.infinity;
        break;
      case '|x|':
        result = value.abs();
        break;
    }

    setState(() {
      _expression = '$func($_display)';
      _display = _formatNumber(result);
      _isNewNumber = true;
    });
  }

  int _factorial(int n) {
    if (n < 0) return 0;
    if (n <= 1) return 1;
    int result = 1;
    for (int i = 2; i <= n; i++) {
      result *= i;
    }
    return result;
  }

  String _formatNumber(double num) {
    if (num == num.toInt().toDouble() && !num.isInfinite && !num.isNaN) {
      return num.toInt().toString();
    }
    return num.toStringAsFixed(10).replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('计算器'),
        actions: [
          IconButton(
            icon: Icon(_isScientific ? Icons.calculate : Icons.science_outlined),
            onPressed: () => setState(() => _isScientific = !_isScientific),
            tooltip: _isScientific ? '标准模式' : '科学模式',
          ),
        ],
      ),
      body: Column(
        children: [
          // Display
          Expanded(
            flex: 2,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (_expression.isNotEmpty)
                    Text(
                      _expression,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: 8),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerRight,
                    child: Text(
                      _display,
                      style: theme.textTheme.displayMedium?.copyWith(
                        fontWeight: FontWeight.w300,
                      ),
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 1),
          // Scientific buttons
          if (_isScientific)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Wrap(
                spacing: 4,
                runSpacing: 4,
                children: ['sin', 'cos', 'tan', '√', 'ln', 'log', 'x²', 'x!', 'π', 'e', '1/x', '|x|']
                    .map((f) => SizedBox(
                          width: (MediaQuery.of(context).size.width - 56) / 6,
                          height: 40,
                          child: TextButton(
                            onPressed: () => _onScientific(f),
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              backgroundColor: colorScheme.tertiaryContainer,
                              foregroundColor: colorScheme.onTertiaryContainer,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(f, style: const TextStyle(fontSize: 13)),
                          ),
                        ))
                    .toList(),
              ),
            ),
          // Keypad
          Expanded(
            flex: _isScientific ? 3 : 4,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                children: [
                  _buildRow([
                    _CalcButton('C', onTap: _onClear, bgColor: colorScheme.errorContainer, fgColor: colorScheme.onErrorContainer),
                    _CalcButton('±', onTap: () => _onNegate(), bgColor: colorScheme.secondaryContainer, fgColor: colorScheme.onSecondaryContainer),
                    _CalcButton('%', onTap: () => _onOperator('%'), bgColor: colorScheme.secondaryContainer, fgColor: colorScheme.onSecondaryContainer),
                    _CalcButton('÷', onTap: () => _onOperator('÷'), bgColor: colorScheme.primaryContainer, fgColor: colorScheme.primary),
                  ]),
                  _buildRow([
                    _CalcButton('7', onTap: () => _onDigit('7')),
                    _CalcButton('8', onTap: () => _onDigit('8')),
                    _CalcButton('9', onTap: () => _onDigit('9')),
                    _CalcButton('×', onTap: () => _onOperator('×'), bgColor: colorScheme.primaryContainer, fgColor: colorScheme.primary),
                  ]),
                  _buildRow([
                    _CalcButton('4', onTap: () => _onDigit('4')),
                    _CalcButton('5', onTap: () => _onDigit('5')),
                    _CalcButton('6', onTap: () => _onDigit('6')),
                    _CalcButton('-', onTap: () => _onOperator('-'), bgColor: colorScheme.primaryContainer, fgColor: colorScheme.primary),
                  ]),
                  _buildRow([
                    _CalcButton('1', onTap: () => _onDigit('1')),
                    _CalcButton('2', onTap: () => _onDigit('2')),
                    _CalcButton('3', onTap: () => _onDigit('3')),
                    _CalcButton('+', onTap: () => _onOperator('+'), bgColor: colorScheme.primaryContainer, fgColor: colorScheme.primary),
                  ]),
                  _buildRow([
                    _CalcButton('⌫', onTap: _onBackspace),
                    _CalcButton('0', onTap: () => _onDigit('0')),
                    _CalcButton('.', onTap: _onDecimal),
                    _CalcButton('=', onTap: _onEquals, bgColor: colorScheme.primary, fgColor: colorScheme.onPrimary),
                  ]),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(List<_CalcButton> buttons) {
    return Expanded(
      child: Row(
        children: buttons.map((btn) {
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.all(3),
              child: SizedBox.expand(
                child: FilledButton(
                  onPressed: btn.onTap,
                  style: FilledButton.styleFrom(
                    backgroundColor: btn.bgColor ?? Theme.of(context).colorScheme.surfaceContainerHigh,
                    foregroundColor: btn.fgColor ?? Theme.of(context).colorScheme.onSurface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: EdgeInsets.zero,
                  ),
                  child: Text(
                    btn.label,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _CalcButton {
  final String label;
  final VoidCallback? onTap;
  final Color? bgColor;
  final Color? fgColor;

  _CalcButton(this.label, {this.onTap, this.bgColor, this.fgColor});
}
