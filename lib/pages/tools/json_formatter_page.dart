import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';

class JsonFormatterPage extends StatefulWidget {
  const JsonFormatterPage({super.key});

  @override
  State<JsonFormatterPage> createState() => _JsonFormatterPageState();
}

class _JsonFormatterPageState extends State<JsonFormatterPage> {
  final _inputController = TextEditingController();
  final _outputController = TextEditingController();
  String _error = '';
  int _indentSize = 2;

  void _format() {
    try {
      final decoded = json.decode(_inputController.text);
      final encoder = JsonEncoder.withIndent(' ' * _indentSize);
      setState(() {
        _outputController.text = encoder.convert(decoded);
        _error = '';
      });
    } catch (e) {
      setState(() {
        _error = '无效的 JSON: ${e.toString().split(':').last.trim()}';
        _outputController.clear();
      });
    }
  }

  void _compress() {
    try {
      final decoded = json.decode(_inputController.text);
      setState(() {
        _outputController.text = json.encode(decoded);
        _error = '';
      });
    } catch (e) {
      setState(() {
        _error = '无效的 JSON: ${e.toString().split(':').last.trim()}';
        _outputController.clear();
      });
    }
  }

  void _validate() {
    try {
      json.decode(_inputController.text);
      setState(() => _error = '');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ JSON 格式正确'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() => _error = '无效的 JSON: ${e.toString().split(':').last.trim()}');
    }
  }

  void _swap() {
    setState(() {
      _inputController.text = _outputController.text;
      _outputController.clear();
      _error = '';
    });
  }

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
        title: const Text('JSON 格式化'),
        actions: [
          IconButton(
            icon: const Icon(Icons.content_paste),
            onPressed: () async {
              final data = await Clipboard.getData(Clipboard.kTextPlain);
              if (data?.text != null) {
                _inputController.text = data!.text!;
                _format();
              }
            },
            tooltip: '粘贴',
          ),
        ],
      ),
      body: Column(
        children: [
          // Action bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                FilledButton.icon(
                  onPressed: _format,
                  icon: const Icon(Icons.format_align_left, size: 18),
                  label: const Text('美化'),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: _compress,
                  icon: const Icon(Icons.compress, size: 18),
                  label: const Text('压缩'),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: _validate,
                  icon: const Icon(Icons.check_circle_outline, size: 18),
                  label: const Text('验证'),
                ),
                const Spacer(),
                // Indent size
                DropdownButton<int>(
                  value: _indentSize,
                  underline: const SizedBox(),
                  items: [2, 4].map((s) => DropdownMenuItem(
                    value: s,
                    child: Text('${s}空格'),
                  )).toList(),
                  onChanged: (v) {
                    setState(() => _indentSize = v!);
                    if (_outputController.text.isNotEmpty) _format();
                  },
                ),
              ],
            ),
          ),

          // Error display
          if (_error.isNotEmpty)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: theme.colorScheme.error, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _error,
                      style: TextStyle(color: theme.colorScheme.error, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),

          // Input
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: TextField(
                controller: _inputController,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
                decoration: InputDecoration(
                  hintText: '在此输入 JSON...',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear, size: 18),
                    onPressed: () {
                      _inputController.clear();
                      _outputController.clear();
                      setState(() => _error = '');
                    },
                  ),
                ),
              ),
            ),
          ),

          // Swap button
          IconButton(
            onPressed: _swap,
            icon: const Icon(Icons.swap_vert),
            tooltip: '将输出移到输入',
          ),

          // Output
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: TextField(
                controller: _outputController,
                maxLines: null,
                expands: true,
                readOnly: true,
                textAlignVertical: TextAlignVertical.top,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
                decoration: InputDecoration(
                  hintText: '格式化结果...',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.copy, size: 18),
                    onPressed: () {
                      if (_outputController.text.isNotEmpty) {
                        Clipboard.setData(ClipboardData(text: _outputController.text));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('已复制到剪贴板')),
                        );
                      }
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
