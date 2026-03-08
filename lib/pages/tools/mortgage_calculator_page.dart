import 'package:flutter/material.dart';
import 'dart:math';

class MortgageCalculatorPage extends StatefulWidget {
  const MortgageCalculatorPage({super.key});

  @override
  State<MortgageCalculatorPage> createState() => _MortgageCalculatorPageState();
}

class _MortgageCalculatorPageState extends State<MortgageCalculatorPage> {
  final _loanController = TextEditingController(text: '100');
  final _rateController = TextEditingController(text: '3.85');
  int _years = 30;
  int _method = 0; // 0 = 等额本息, 1 = 等额本金

  double get _loanAmount => (double.tryParse(_loanController.text) ?? 0) * 10000;
  double get _annualRate => (double.tryParse(_rateController.text) ?? 0) / 100;
  double get _monthlyRate => _annualRate / 12;
  int get _totalMonths => _years * 12;

  // 等额本息
  double get _equalPayment {
    if (_monthlyRate == 0 || _totalMonths == 0) return 0;
    final r = _monthlyRate;
    final n = _totalMonths;
    return _loanAmount * r * pow(1 + r, n) / (pow(1 + r, n) - 1);
  }

  double get _equalTotalPayment => _equalPayment * _totalMonths;
  double get _equalTotalInterest => _equalTotalPayment - _loanAmount;

  // 等额本金 - 第一个月
  double get _principalFirstPayment {
    if (_totalMonths == 0) return 0;
    final monthlyPrincipal = _loanAmount / _totalMonths;
    return monthlyPrincipal + _loanAmount * _monthlyRate;
  }

  // 等额本金 - 最后一个月
  double get _principalLastPayment {
    if (_totalMonths == 0) return 0;
    final monthlyPrincipal = _loanAmount / _totalMonths;
    return monthlyPrincipal + monthlyPrincipal * _monthlyRate;
  }

  double get _principalTotalInterest {
    if (_totalMonths == 0 || _monthlyRate == 0) return 0;
    final monthlyPrincipal = _loanAmount / _totalMonths;
    double total = 0;
    for (int i = 0; i < _totalMonths; i++) {
      total += (_loanAmount - monthlyPrincipal * i) * _monthlyRate;
    }
    return total;
  }

  double get _principalTotalPayment => _loanAmount + _principalTotalInterest;

  String _formatMoney(double value) {
    if (value >= 10000) {
      return '${(value / 10000).toStringAsFixed(2)} 万';
    }
    return '${value.toStringAsFixed(2)} 元';
  }

  @override
  void dispose() {
    _loanController.dispose();
    _rateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('房贷计算器')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Input section
            TextField(
              controller: _loanController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: '贷款金额',
                suffixText: '万元',
                prefixIcon: Icon(Icons.payments_outlined),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _rateController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: '年利率',
                suffixText: '%',
                prefixIcon: Icon(Icons.percent),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),

            // Loan period
            Text('贷款期限: $_years 年', style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            Slider(
              value: _years.toDouble(),
              min: 1,
              max: 30,
              divisions: 29,
              label: '$_years 年',
              onChanged: (v) => setState(() => _years = v.toInt()),
            ),
            // Quick period selection
            Wrap(
              spacing: 8,
              children: [5, 10, 15, 20, 25, 30].map((y) {
                return ChoiceChip(
                  label: Text('$y年'),
                  selected: _years == y,
                  onSelected: (_) => setState(() => _years = y),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Method toggle
            SegmentedButton<int>(
              segments: const [
                ButtonSegment(value: 0, label: Text('等额本息'), icon: Icon(Icons.balance)),
                ButtonSegment(value: 1, label: Text('等额本金'), icon: Icon(Icons.trending_down)),
              ],
              selected: {_method},
              onSelectionChanged: (s) => setState(() => _method = s.first),
            ),
            const SizedBox(height: 24),

            // Results
            if (_loanAmount > 0) ...[
              if (_method == 0) _buildEqualPaymentResult(theme, colorScheme),
              if (_method == 1) _buildPrincipalPaymentResult(theme, colorScheme),
            ],

            const SizedBox(height: 16),
            // Quick rate reference
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('参考利率', style: theme.textTheme.titleSmall),
                    const SizedBox(height: 8),
                    _buildRateRow('公积金贷款 (5年以上)', '3.10%'),
                    _buildRateRow('商业贷款 (LPR)', '3.85%'),
                    _buildRateRow('首套房 (参考)', '3.85%'),
                    _buildRateRow('二套房 (参考)', '4.35%'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEqualPaymentResult(ThemeData theme, ColorScheme colorScheme) {
    return Card(
      color: colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text('等额本息', style: theme.textTheme.titleMedium?.copyWith(
              color: colorScheme.onPrimaryContainer,
            )),
            Text('每月还款额固定', style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onPrimaryContainer.withOpacity(0.7),
            )),
            const SizedBox(height: 16),
            Text(
              '${_equalPayment.toStringAsFixed(2)} 元/月',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onPrimaryContainer,
              ),
            ),
            const Divider(height: 32),
            _buildResultRow('贷款总额', _formatMoney(_loanAmount), colorScheme.onPrimaryContainer),
            _buildResultRow('还款总额', _formatMoney(_equalTotalPayment), colorScheme.onPrimaryContainer),
            _buildResultRow('利息总额', _formatMoney(_equalTotalInterest), colorScheme.error),
            _buildResultRow('还款期数', '$_totalMonths 期', colorScheme.onPrimaryContainer),
          ],
        ),
      ),
    );
  }

  Widget _buildPrincipalPaymentResult(ThemeData theme, ColorScheme colorScheme) {
    return Card(
      color: colorScheme.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text('等额本金', style: theme.textTheme.titleMedium?.copyWith(
              color: colorScheme.onSecondaryContainer,
            )),
            Text('每月递减', style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSecondaryContainer.withOpacity(0.7),
            )),
            const SizedBox(height: 16),
            Text(
              '首月 ${_principalFirstPayment.toStringAsFixed(2)} 元',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSecondaryContainer,
              ),
            ),
            Text(
              '末月 ${_principalLastPayment.toStringAsFixed(2)} 元',
              style: theme.textTheme.titleMedium?.copyWith(
                color: colorScheme.onSecondaryContainer.withOpacity(0.8),
              ),
            ),
            const Divider(height: 32),
            _buildResultRow('贷款总额', _formatMoney(_loanAmount), colorScheme.onSecondaryContainer),
            _buildResultRow('还款总额', _formatMoney(_principalTotalPayment), colorScheme.onSecondaryContainer),
            _buildResultRow('利息总额', _formatMoney(_principalTotalInterest), colorScheme.error),
            _buildResultRow('还款期数', '$_totalMonths 期', colorScheme.onSecondaryContainer),
            const SizedBox(height: 8),
            Text(
              '比等额本息少付 ${_formatMoney(_equalTotalInterest - _principalTotalInterest)} 利息',
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.green,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultRow(String label, String value, Color textColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: textColor.withOpacity(0.8))),
          Text(value, style: TextStyle(fontWeight: FontWeight.w600, color: textColor)),
        ],
      ),
    );
  }

  Widget _buildRateRow(String label, String rate) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          InkWell(
            onTap: () {
              _rateController.text = rate.replaceAll('%', '');
              setState(() {});
            },
            child: Text(
              rate,
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
