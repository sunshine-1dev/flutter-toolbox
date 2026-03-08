import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';

class PasswordGeneratorPage extends StatefulWidget {
  const PasswordGeneratorPage({super.key});

  @override
  State<PasswordGeneratorPage> createState() => _PasswordGeneratorPageState();
}

class _PasswordGeneratorPageState extends State<PasswordGeneratorPage> {
  int _length = 16;
  bool _uppercase = true;
  bool _lowercase = true;
  bool _numbers = true;
  bool _symbols = true;
  bool _excludeAmbiguous = false;
  String _password = '';
  final List<String> _history = [];

  static const _uppercaseChars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  static const _lowercaseChars = 'abcdefghijklmnopqrstuvwxyz';
  static const _numberChars = '0123456789';
  static const _symbolChars = '!@#\$%^&*()_+-=[]{}|;:,.<>?';
  static const _ambiguousChars = 'Il1O0';

  void _generate() {
    String chars = '';
    if (_uppercase) chars += _uppercaseChars;
    if (_lowercase) chars += _lowercaseChars;
    if (_numbers) chars += _numberChars;
    if (_symbols) chars += _symbolChars;

    if (chars.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请至少选择一种字符类型')),
      );
      return;
    }

    if (_excludeAmbiguous) {
      chars = chars.split('').where((c) => !_ambiguousChars.contains(c)).join();
    }

    final random = Random.secure();
    final password = List.generate(_length, (_) => chars[random.nextInt(chars.length)]).join();

    setState(() {
      _password = password;
      _history.insert(0, password);
      if (_history.length > 20) _history.removeLast();
    });

    HapticFeedback.lightImpact();
  }

  double get _strength {
    if (_password.isEmpty) return 0;
    double score = 0;
    if (_password.length >= 8) score += 0.2;
    if (_password.length >= 12) score += 0.1;
    if (_password.length >= 16) score += 0.1;
    if (RegExp(r'[A-Z]').hasMatch(_password)) score += 0.15;
    if (RegExp(r'[a-z]').hasMatch(_password)) score += 0.15;
    if (RegExp(r'[0-9]').hasMatch(_password)) score += 0.15;
    if (RegExp(r'[!@#$%^&*()_+\-=\[\]{}|;:,.<>?]').hasMatch(_password)) score += 0.15;
    return score.clamp(0, 1);
  }

  String get _strengthLabel {
    final s = _strength;
    if (s < 0.3) return '弱';
    if (s < 0.6) return '中等';
    if (s < 0.8) return '强';
    return '非常强';
  }

  Color get _strengthColor {
    final s = _strength;
    if (s < 0.3) return Colors.red;
    if (s < 0.6) return Colors.orange;
    if (s < 0.8) return Colors.blue;
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('密码生成器'),
        actions: [
          if (_history.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.history),
              onPressed: _showHistory,
              tooltip: '历史记录',
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Password display
            Card(
              color: theme.colorScheme.surfaceContainerHighest,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    SelectableText(
                      _password.isEmpty ? '点击生成密码' : _password,
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: _password.length > 24 ? 16 : 22,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.5,
                        color: _password.isEmpty
                            ? theme.colorScheme.onSurfaceVariant
                            : null,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (_password.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      // Strength indicator
                      LinearProgressIndicator(
                        value: _strength,
                        backgroundColor: theme.colorScheme.surfaceContainerLow,
                        valueColor: AlwaysStoppedAnimation(_strengthColor),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '强度: $_strengthLabel',
                        style: TextStyle(
                          color: _strengthColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          FilledButton.tonalIcon(
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: _password));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('密码已复制')),
                              );
                            },
                            icon: const Icon(Icons.copy, size: 18),
                            label: const Text('复制'),
                          ),
                          const SizedBox(width: 8),
                          OutlinedButton.icon(
                            onPressed: _generate,
                            icon: const Icon(Icons.refresh, size: 18),
                            label: const Text('重新生成'),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Length slider
            Text('密码长度: $_length', style: theme.textTheme.titleSmall),
            Row(
              children: [
                const Text('4'),
                Expanded(
                  child: Slider(
                    value: _length.toDouble(),
                    min: 4,
                    max: 64,
                    divisions: 60,
                    label: '$_length',
                    onChanged: (v) => setState(() => _length = v.toInt()),
                  ),
                ),
                const Text('64'),
              ],
            ),

            // Quick length
            Wrap(
              spacing: 8,
              children: [8, 12, 16, 20, 24, 32].map((l) {
                return ChoiceChip(
                  label: Text('$l'),
                  selected: _length == l,
                  onSelected: (_) => setState(() => _length = l),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Character options
            Text('字符类型', style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            _buildSwitch('大写字母 (A-Z)', _uppercase, (v) => setState(() => _uppercase = v)),
            _buildSwitch('小写字母 (a-z)', _lowercase, (v) => setState(() => _lowercase = v)),
            _buildSwitch('数字 (0-9)', _numbers, (v) => setState(() => _numbers = v)),
            _buildSwitch('特殊符号 (!@#\$%...)', _symbols, (v) => setState(() => _symbols = v)),
            _buildSwitch('排除易混淆字符 (I,l,1,O,0)', _excludeAmbiguous,
                (v) => setState(() => _excludeAmbiguous = v)),

            const SizedBox(height: 24),

            // Generate button
            FilledButton.icon(
              onPressed: _generate,
              icon: const Icon(Icons.vpn_key),
              label: const Text('生成密码', style: TextStyle(fontSize: 16)),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitch(String label, bool value, ValueChanged<bool> onChanged) {
    return SwitchListTile(
      title: Text(label, style: const TextStyle(fontSize: 14)),
      value: value,
      onChanged: onChanged,
      dense: true,
      contentPadding: EdgeInsets.zero,
    );
  }

  void _showHistory() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('历史记录', style: Theme.of(context).textTheme.titleMedium),
            const Divider(),
            ..._history.map((pwd) {
              return ListTile(
                title: Text(pwd,
                    style: const TextStyle(fontFamily: 'monospace', fontSize: 14)),
                trailing: IconButton(
                  icon: const Icon(Icons.copy, size: 20),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: pwd));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('已复制')),
                    );
                  },
                ),
                onTap: () {
                  setState(() => _password = pwd);
                  Navigator.pop(context);
                },
              );
            }),
          ],
        );
      },
    );
  }
}
