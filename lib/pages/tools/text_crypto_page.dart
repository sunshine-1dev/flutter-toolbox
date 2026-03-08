import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

class TextCryptoPage extends StatefulWidget {
  const TextCryptoPage({super.key});

  @override
  State<TextCryptoPage> createState() => _TextCryptoPageState();
}

class _TextCryptoPageState extends State<TextCryptoPage> {
  final _inputController = TextEditingController();
  final _outputController = TextEditingController();
  String _selectedMode = 'Base64 编码';

  final List<String> _modes = [
    'Base64 编码',
    'Base64 解码',
    'URL 编码',
    'URL 解码',
    'MD5',
    'SHA-1',
    'SHA-256',
    'SHA-512',
    'Unicode 编码',
    'Unicode 解码',
  ];

  void _convert() {
    final input = _inputController.text;
    if (input.isEmpty) {
      setState(() => _outputController.text = '');
      return;
    }

    String result;
    try {
      switch (_selectedMode) {
        case 'Base64 编码':
          result = base64Encode(utf8.encode(input));
          break;
        case 'Base64 解码':
          result = utf8.decode(base64Decode(input));
          break;
        case 'URL 编码':
          result = Uri.encodeComponent(input);
          break;
        case 'URL 解码':
          result = Uri.decodeComponent(input);
          break;
        case 'MD5':
          result = md5.convert(utf8.encode(input)).toString();
          break;
        case 'SHA-1':
          result = sha1.convert(utf8.encode(input)).toString();
          break;
        case 'SHA-256':
          result = sha256.convert(utf8.encode(input)).toString();
          break;
        case 'SHA-512':
          result = sha512.convert(utf8.encode(input)).toString();
          break;
        case 'Unicode 编码':
          result = input.codeUnits
              .map((c) => '\\u${c.toRadixString(16).padLeft(4, '0')}')
              .join();
          break;
        case 'Unicode 解码':
          result = input.replaceAllMapped(
            RegExp(r'\\u([0-9a-fA-F]{4})'),
            (m) => String.fromCharCode(int.parse(m.group(1)!, radix: 16)),
          );
          break;
        default:
          result = input;
      }
    } catch (e) {
      result = '转换错误: $e';
    }

    setState(() => _outputController.text = result);
  }

  bool get _isHashMode =>
      _selectedMode == 'MD5' || _selectedMode.startsWith('SHA');

  @override
  void dispose() {
    _inputController.dispose();
    _outputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('文本加解密'),
        actions: [
          IconButton(
            icon: const Icon(Icons.content_paste),
            onPressed: () async {
              final data = await Clipboard.getData(Clipboard.kTextPlain);
              if (data?.text != null) {
                _inputController.text = data!.text!;
                _convert();
              }
            },
            tooltip: '粘贴',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Mode selector
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: _modes.map((mode) {
                final isSelected = mode == _selectedMode;
                return ChoiceChip(
                  label: Text(mode, style: const TextStyle(fontSize: 12)),
                  selected: isSelected,
                  onSelected: (_) {
                    setState(() => _selectedMode = mode);
                    _convert();
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Hash info
            if (_isHashMode)
              Card(
                color: theme.colorScheme.tertiaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline,
                          size: 18,
                          color: theme.colorScheme.onTertiaryContainer),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '哈希算法是单向的，无法解码',
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.colorScheme.onTertiaryContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 12),

            // Input
            TextField(
              controller: _inputController,
              maxLines: 6,
              decoration: InputDecoration(
                labelText: '输入文本',
                hintText: '请输入要转换的文本...',
                alignLabelWithHint: true,
                border: const OutlineInputBorder(),
                suffixIcon: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () {
                        _inputController.clear();
                        _outputController.clear();
                        setState(() {});
                      },
                    ),
                  ],
                ),
              ),
              onChanged: (_) => _convert(),
            ),
            const SizedBox(height: 16),

            // Convert button
            FilledButton.icon(
              onPressed: _convert,
              icon: const Icon(Icons.transform),
              label: Text(_selectedMode),
            ),
            const SizedBox(height: 16),

            // Output
            TextField(
              controller: _outputController,
              maxLines: 6,
              readOnly: true,
              decoration: InputDecoration(
                labelText: '输出结果',
                alignLabelWithHint: true,
                border: const OutlineInputBorder(),
                suffixIcon: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.copy, size: 18),
                      onPressed: () {
                        if (_outputController.text.isNotEmpty) {
                          Clipboard.setData(
                              ClipboardData(text: _outputController.text));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('已复制到剪贴板')),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Quick test strings
            Text('快捷测试', style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                'Hello World',
                '你好世界',
                'test@example.com',
                'https://example.com?q=测试&lang=zh',
                '{"name":"test"}',
              ]
                  .map((text) => ActionChip(
                        label: Text(text, style: const TextStyle(fontSize: 11)),
                        onPressed: () {
                          _inputController.text = text;
                          _convert();
                        },
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}
