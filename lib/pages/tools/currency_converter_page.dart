import 'package:flutter/material.dart';

class CurrencyConverterPage extends StatefulWidget {
  const CurrencyConverterPage({super.key});

  @override
  State<CurrencyConverterPage> createState() => _CurrencyConverterPageState();
}

class _CurrencyConverterPageState extends State<CurrencyConverterPage> {
  final _amountController = TextEditingController(text: '100');

  // Rates relative to USD
  final Map<String, _CurrencyInfo> _currencies = {
    'USD': _CurrencyInfo('美元', '🇺🇸', 1.0),
    'CNY': _CurrencyInfo('人民币', '🇨🇳', 7.24),
    'EUR': _CurrencyInfo('欧元', '🇪🇺', 0.92),
    'GBP': _CurrencyInfo('英镑', '🇬🇧', 0.79),
    'JPY': _CurrencyInfo('日元', '🇯🇵', 149.50),
    'KRW': _CurrencyInfo('韩元', '🇰🇷', 1320.0),
    'HKD': _CurrencyInfo('港币', '🇭🇰', 7.82),
    'TWD': _CurrencyInfo('新台币', '🇹🇼', 31.50),
    'SGD': _CurrencyInfo('新加坡元', '🇸🇬', 1.34),
    'AUD': _CurrencyInfo('澳元', '🇦🇺', 1.53),
    'CAD': _CurrencyInfo('加元', '🇨🇦', 1.36),
    'CHF': _CurrencyInfo('瑞士法郎', '🇨🇭', 0.88),
    'THB': _CurrencyInfo('泰铢', '🇹🇭', 35.20),
    'INR': _CurrencyInfo('印度卢比', '🇮🇳', 83.10),
    'RUB': _CurrencyInfo('俄罗斯卢布', '🇷🇺', 91.50),
  };

  String _fromCurrency = 'USD';
  String _toCurrency = 'CNY';

  double get _convertedAmount {
    final amount = double.tryParse(_amountController.text) ?? 0;
    final fromRate = _currencies[_fromCurrency]!.rateToUsd;
    final toRate = _currencies[_toCurrency]!.rateToUsd;
    return amount / fromRate * toRate;
  }

  void _swap() {
    setState(() {
      final temp = _fromCurrency;
      _fromCurrency = _toCurrency;
      _toCurrency = temp;
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('汇率换算')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Info card
            Card(
              color: theme.colorScheme.tertiaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: theme.colorScheme.onTertiaryContainer, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '使用固定参考汇率，仅供参考',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onTertiaryContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // From currency
            _buildCurrencyCard(
              label: '从',
              currency: _fromCurrency,
              showAmount: true,
              onChanged: (v) => setState(() => _fromCurrency = v!),
            ),

            const SizedBox(height: 12),
            // Swap button
            IconButton.filled(
              onPressed: _swap,
              icon: const Icon(Icons.swap_vert),
            ),
            const SizedBox(height: 12),

            // To currency
            _buildCurrencyCard(
              label: '到',
              currency: _toCurrency,
              showAmount: false,
              onChanged: (v) => setState(() => _toCurrency = v!),
            ),

            const SizedBox(height: 32),

            // Result
            Card(
              color: theme.colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Text(
                      '${_amountController.text.isEmpty ? "0" : _amountController.text} ${_currencies[_fromCurrency]!.name}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text('=', style: theme.textTheme.titleLarge),
                    const SizedBox(height: 4),
                    FittedBox(
                      child: Text(
                        '${_convertedAmount.toStringAsFixed(2)} ${_currencies[_toCurrency]!.name}',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '1 $_fromCurrency = ${(_currencies[_toCurrency]!.rateToUsd / _currencies[_fromCurrency]!.rateToUsd).toStringAsFixed(4)} $_toCurrency',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),
            // Quick conversion list
            Text('常用汇率 (基于 1 $_fromCurrency)',
                style: theme.textTheme.titleSmall),
            const SizedBox(height: 12),
            ..._currencies.entries
                .where((e) => e.key != _fromCurrency)
                .take(8)
                .map((e) {
              final rate = e.value.rateToUsd / _currencies[_fromCurrency]!.rateToUsd;
              return ListTile(
                leading: Text(e.value.flag, style: const TextStyle(fontSize: 24)),
                title: Text('${e.key} - ${e.value.name}'),
                trailing: Text(
                  rate.toStringAsFixed(4),
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
                dense: true,
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrencyCard({
    required String label,
    required String currency,
    required bool showAmount,
    required ValueChanged<String?> onChanged,
  }) {
    final info = _currencies[currency]!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.labelMedium),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: currency,
                    decoration: InputDecoration(
                      prefixText: '${info.flag} ',
                      border: const OutlineInputBorder(),
                    ),
                    items: _currencies.entries
                        .map((e) => DropdownMenuItem(
                              value: e.key,
                              child: Text('${e.value.flag} ${e.key} - ${e.value.name}'),
                            ))
                        .toList(),
                    onChanged: onChanged,
                  ),
                ),
              ],
            ),
            if (showAmount) ...[
              const SizedBox(height: 12),
              TextField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: '金额',
                  prefixIcon: Icon(Icons.attach_money),
                ),
                onChanged: (_) => setState(() {}),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CurrencyInfo {
  final String name;
  final String flag;
  final double rateToUsd;

  const _CurrencyInfo(this.name, this.flag, this.rateToUsd);
}
