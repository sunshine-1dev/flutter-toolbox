import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class WordCounterPage extends StatefulWidget {
  const WordCounterPage({super.key});

  @override
  State<WordCounterPage> createState() => _WordCounterPageState();
}

class _WordCounterPageState extends State<WordCounterPage> {
  final _textController = TextEditingController();

  Map<String, int> get _stats {
    final text = _textController.text;
    if (text.isEmpty) {
      return {
        '总字符数': 0,
        '不含空格字符数': 0,
        '中文字数': 0,
        '英文单词数': 0,
        '数字个数': 0,
        '标点符号': 0,
        '行数': 0,
        '段落数': 0,
        '空格数': 0,
      };
    }

    // Chinese characters
    final chineseRegex = RegExp(r'[\u4e00-\u9fff\u3400-\u4dbf]');
    final chineseCount = chineseRegex.allMatches(text).length;

    // English words
    final englishWordRegex = RegExp(r'[a-zA-Z]+');
    final englishWordCount = englishWordRegex.allMatches(text).length;

    // Numbers
    final numberRegex = RegExp(r'\d+');
    final numberCount = numberRegex.allMatches(text).length;

    // Punctuation
    final punctRegex = RegExp(r'[^\w\s\u4e00-\u9fff\u3400-\u4dbf]');
    final punctCount = punctRegex.allMatches(text).length;

    // Lines
    final lineCount = text.isEmpty ? 0 : text.split('\n').length;

    // Paragraphs
    final paragraphs = text.split(RegExp(r'\n\s*\n'));
    final paragraphCount = paragraphs.where((p) => p.trim().isNotEmpty).length;

    // Spaces
    final spaceCount = RegExp(r'\s').allMatches(text).length;

    return {
      '总字符数': text.length,
      '不含空格字符数': text.replaceAll(RegExp(r'\s'), '').length,
      '中文字数': chineseCount,
      '英文单词数': englishWordCount,
      '数字个数': numberCount,
      '标点符号': punctCount,
      '行数': lineCount,
      '段落数': paragraphCount > 0 ? paragraphCount : (text.trim().isEmpty ? 0 : 1),
      '空格数': spaceCount,
    };
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final stats = _stats;

    return Scaffold(
      appBar: AppBar(
        title: const Text('字数统计'),
        actions: [
          IconButton(
            icon: const Icon(Icons.content_paste),
            onPressed: () async {
              final data = await Clipboard.getData(Clipboard.kTextPlain);
              if (data?.text != null) {
                _textController.text = data!.text!;
                setState(() {});
              }
            },
            tooltip: '从剪贴板粘贴',
          ),
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              _textController.clear();
              setState(() {});
            },
            tooltip: '清除',
          ),
        ],
      ),
      body: Column(
        children: [
          // Input area
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: TextField(
                controller: _textController,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                decoration: const InputDecoration(
                  hintText: '在此输入或粘贴文本...',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                onChanged: (_) => setState(() {}),
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Stats grid
          Expanded(
            flex: 2,
            child: Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: GridView.count(
                crossAxisCount: 3,
                padding: const EdgeInsets.all(16),
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 1.4,
                children: stats.entries.map((e) {
                  return Card(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            e.value.toString(),
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            e.key,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
