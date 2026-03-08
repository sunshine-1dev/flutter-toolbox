import 'package:flutter/material.dart';
import 'dart:math';

class BmiCalculatorPage extends StatefulWidget {
  const BmiCalculatorPage({super.key});

  @override
  State<BmiCalculatorPage> createState() => _BmiCalculatorPageState();
}

class _BmiCalculatorPageState extends State<BmiCalculatorPage> {
  double _height = 170;
  double _weight = 65;
  bool _isMale = true;
  int _age = 25;

  double get _bmi => _weight / pow(_height / 100, 2);

  String get _bmiCategory {
    final bmi = _bmi;
    if (bmi < 18.5) return '偏瘦';
    if (bmi < 24.0) return '正常';
    if (bmi < 28.0) return '偏胖';
    return '肥胖';
  }

  Color get _bmiColor {
    final bmi = _bmi;
    if (bmi < 18.5) return Colors.blue;
    if (bmi < 24.0) return Colors.green;
    if (bmi < 28.0) return Colors.orange;
    return Colors.red;
  }

  String get _healthAdvice {
    final bmi = _bmi;
    if (bmi < 18.5) return '您的体重偏低，建议增加营养摄入，适当增重。';
    if (bmi < 24.0) return '您的体重正常，请继续保持健康的生活方式！';
    if (bmi < 28.0) return '您的体重偏重，建议控制饮食，增加运动量。';
    return '您的体重超标，建议及时调整饮食和运动习惯，必要时就医。';
  }

  double get _idealWeightMin => 18.5 * pow(_height / 100, 2);
  double get _idealWeightMax => 24.0 * pow(_height / 100, 2);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('BMI 计算器')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Gender selection
            Row(
              children: [
                Expanded(
                  child: _GenderCard(
                    icon: Icons.male,
                    label: '男',
                    isSelected: _isMale,
                    onTap: () => setState(() => _isMale = true),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _GenderCard(
                    icon: Icons.female,
                    label: '女',
                    isSelected: !_isMale,
                    onTap: () => setState(() => _isMale = false),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Height slider
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text('身高', style: theme.textTheme.labelLarge),
                    const SizedBox(height: 4),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: _height.toInt().toString(),
                            style: theme.textTheme.displaySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextSpan(
                            text: ' cm',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Slider(
                      value: _height,
                      min: 100,
                      max: 220,
                      divisions: 120,
                      onChanged: (v) => setState(() => _height = v),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Weight and age row
            Row(
              children: [
                Expanded(
                  child: _ValueCard(
                    label: '体重 (kg)',
                    value: _weight,
                    onAdd: () => setState(() => _weight = (_weight + 0.5).clamp(20, 300)),
                    onMinus: () => setState(() => _weight = (_weight - 0.5).clamp(20, 300)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ValueCard(
                    label: '年龄',
                    value: _age.toDouble(),
                    onAdd: () => setState(() => _age = (_age + 1).clamp(1, 120)),
                    onMinus: () => setState(() => _age = (_age - 1).clamp(1, 120)),
                    isInt: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Result
            Card(
              color: _bmiColor.withOpacity(0.15),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Text('您的 BMI', style: theme.textTheme.labelLarge),
                    const SizedBox(height: 8),
                    Text(
                      _bmi.toStringAsFixed(1),
                      style: theme.textTheme.displayLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: _bmiColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: _bmiColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _bmiCategory,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // BMI bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: SizedBox(
                        height: 12,
                        child: Row(
                          children: [
                            Expanded(flex: 185, child: Container(color: Colors.blue)),
                            Expanded(flex: 55, child: Container(color: Colors.green)),
                            Expanded(flex: 40, child: Container(color: Colors.orange)),
                            Expanded(flex: 120, child: Container(color: Colors.red)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('偏瘦\n<18.5', style: theme.textTheme.labelSmall, textAlign: TextAlign.center),
                        Text('正常\n18.5-24', style: theme.textTheme.labelSmall, textAlign: TextAlign.center),
                        Text('偏胖\n24-28', style: theme.textTheme.labelSmall, textAlign: TextAlign.center),
                        Text('肥胖\n>28', style: theme.textTheme.labelSmall, textAlign: TextAlign.center),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _healthAdvice,
                      style: theme.textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '理想体重范围: ${_idealWeightMin.toStringAsFixed(1)} - ${_idealWeightMax.toStringAsFixed(1)} kg',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GenderCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _GenderCard({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      color: isSelected ? theme.colorScheme.primaryContainer : null,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Icon(icon, size: 48, color: isSelected ? theme.colorScheme.primary : null),
              const SizedBox(height: 8),
              Text(label, style: theme.textTheme.titleMedium),
            ],
          ),
        ),
      ),
    );
  }
}

class _ValueCard extends StatelessWidget {
  final String label;
  final double value;
  final VoidCallback onAdd;
  final VoidCallback onMinus;
  final bool isInt;

  const _ValueCard({
    required this.label,
    required this.value,
    required this.onAdd,
    required this.onMinus,
    this.isInt = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(label, style: theme.textTheme.labelLarge),
            const SizedBox(height: 8),
            Text(
              isInt ? value.toInt().toString() : value.toStringAsFixed(1),
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton.filled(
                  onPressed: onMinus,
                  icon: const Icon(Icons.remove),
                  iconSize: 20,
                ),
                const SizedBox(width: 12),
                IconButton.filled(
                  onPressed: onAdd,
                  icon: const Icon(Icons.add),
                  iconSize: 20,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
