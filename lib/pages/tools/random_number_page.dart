import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';

class RandomNumberPage extends StatefulWidget {
  const RandomNumberPage({super.key});

  @override
  State<RandomNumberPage> createState() => _RandomNumberPageState();
}

class _RandomNumberPageState extends State<RandomNumberPage>
    with SingleTickerProviderStateMixin {
  final _minController = TextEditingController(text: '1');
  final _maxController = TextEditingController(text: '100');
  final _countController = TextEditingController(text: '1');
  bool _allowDuplicates = true;
  List<int> _results = [];
  bool _isAnimating = false;
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
  }

  void _generate() {
    final minVal = int.tryParse(_minController.text) ?? 0;
    final maxVal = int.tryParse(_maxController.text) ?? 100;
    final count = int.tryParse(_countController.text) ?? 1;

    if (minVal > maxVal) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('最小值不能大于最大值')),
      );
      return;
    }

    if (!_allowDuplicates && count > (maxVal - minVal + 1)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('不允许重复时，数量不能超过范围大小')),
      );
      return;
    }

    final random = Random();
    List<int> numbers;

    if (_allowDuplicates) {
      numbers = List.generate(count, (_) => minVal + random.nextInt(maxVal - minVal + 1));
    } else {
      final pool = List.generate(maxVal - minVal + 1, (i) => minVal + i);
      pool.shuffle(random);
      numbers = pool.take(count).toList();
    }

    setState(() {
      _results = numbers;
      _isAnimating = true;
    });

    _animController.forward(from: 0).then((_) {
      setState(() => _isAnimating = false);
    });

    HapticFeedback.mediumImpact();
  }

  @override
  void dispose() {
    _minController.dispose();
    _maxController.dispose();
    _countController.dispose();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('随机数生成器')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Range inputs
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _minController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: '最小值',
                      prefixIcon: Icon(Icons.first_page),
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text('~', style: TextStyle(fontSize: 24)),
                ),
                Expanded(
                  child: TextField(
                    controller: _maxController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: '最大值',
                      prefixIcon: Icon(Icons.last_page),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Count
            TextField(
              controller: _countController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: '生成个数',
                prefixIcon: Icon(Icons.format_list_numbered),
              ),
            ),
            const SizedBox(height: 12),

            // Options
            SwitchListTile(
              title: const Text('允许重复'),
              subtitle: const Text('是否允许生成重复的数字'),
              value: _allowDuplicates,
              onChanged: (v) => setState(() => _allowDuplicates = v),
            ),
            const SizedBox(height: 16),

            // Generate button
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _generate,
                icon: const Icon(Icons.casino),
                label: const Text('生成随机数', style: TextStyle(fontSize: 16)),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Quick buttons
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _QuickBtn('1-6 (骰子)', () {
                  _minController.text = '1';
                  _maxController.text = '6';
                  _countController.text = '1';
                  _generate();
                }),
                _QuickBtn('1-10', () {
                  _minController.text = '1';
                  _maxController.text = '10';
                  _countController.text = '1';
                  _generate();
                }),
                _QuickBtn('抛硬币', () {
                  _minController.text = '0';
                  _maxController.text = '1';
                  _countController.text = '1';
                  _generate();
                }),
                _QuickBtn('彩票 (7个)', () {
                  _minController.text = '1';
                  _maxController.text = '35';
                  _countController.text = '7';
                  setState(() => _allowDuplicates = false);
                  _generate();
                }),
              ],
            ),
            const SizedBox(height: 24),

            // Results
            if (_results.isNotEmpty) ...[
              Card(
                color: theme.colorScheme.primaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Text('生成结果', style: theme.textTheme.labelLarge?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                      )),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        alignment: WrapAlignment.center,
                        children: _results.map((n) {
                          return AnimatedBuilder(
                            animation: _animController,
                            builder: (context, child) {
                              return Transform.scale(
                                scale: _isAnimating
                                    ? Curves.elasticOut.transform(_animController.value)
                                    : 1.0,
                                child: child,
                              );
                            },
                            child: Container(
                              width: _results.length == 1 ? 120 : 64,
                              height: _results.length == 1 ? 120 : 64,
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary,
                                borderRadius: BorderRadius.circular(
                                  _results.length == 1 ? 60 : 16,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  '$n',
                                  style: TextStyle(
                                    color: theme.colorScheme.onPrimary,
                                    fontSize: _results.length == 1 ? 40 : 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      if (_results.length == 1 && _minController.text == '0' && _maxController.text == '1')
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Text(
                            _results[0] == 0 ? '🪙 反面' : '🪙 正面',
                            style: theme.textTheme.titleMedium,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Copy results
              OutlinedButton.icon(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: _results.join(', ')));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('已复制到剪贴板')),
                  );
                },
                icon: const Icon(Icons.copy),
                label: const Text('复制结果'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _QuickBtn extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _QuickBtn(this.label, this.onTap);

  @override
  Widget build(BuildContext context) {
    return ActionChip(label: Text(label), onPressed: onTap);
  }
}
