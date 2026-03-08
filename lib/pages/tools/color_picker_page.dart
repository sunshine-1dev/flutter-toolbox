import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class ColorPickerPage extends StatefulWidget {
  const ColorPickerPage({super.key});

  @override
  State<ColorPickerPage> createState() => _ColorPickerPageState();
}

class _ColorPickerPageState extends State<ColorPickerPage> {
  Color _currentColor = const Color(0xFF6750A4);
  final List<Color> _savedColors = [];
  final _hexController = TextEditingController();

  String get _hexString =>
      '#${_currentColor.value.toRadixString(16).substring(2).toUpperCase()}';

  String get _rgbString =>
      'RGB(${_currentColor.red}, ${_currentColor.green}, ${_currentColor.blue})';

  String get _hslString {
    final hsl = HSLColor.fromColor(_currentColor);
    return 'HSL(${hsl.hue.toStringAsFixed(0)}, ${(hsl.saturation * 100).toStringAsFixed(0)}%, ${(hsl.lightness * 100).toStringAsFixed(0)}%)';
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('已复制: $text'), duration: const Duration(seconds: 1)),
    );
  }

  void _saveColor() {
    if (!_savedColors.contains(_currentColor)) {
      setState(() => _savedColors.add(_currentColor));
    }
  }

  @override
  void dispose() {
    _hexController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('颜色提取'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save_outlined),
            onPressed: _saveColor,
            tooltip: '保存当前颜色',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Color preview
            Container(
              width: double.infinity,
              height: 120,
              decoration: BoxDecoration(
                color: _currentColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: _currentColor.withOpacity(0.4),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  _hexString,
                  style: TextStyle(
                    color: _currentColor.computeLuminance() > 0.5
                        ? Colors.black
                        : Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Color values
            Row(
              children: [
                Expanded(child: _ColorValueChip(
                  label: 'HEX',
                  value: _hexString,
                  onTap: () => _copyToClipboard(_hexString),
                )),
                const SizedBox(width: 8),
                Expanded(child: _ColorValueChip(
                  label: 'RGB',
                  value: _rgbString,
                  onTap: () => _copyToClipboard(_rgbString),
                )),
                const SizedBox(width: 8),
                Expanded(child: _ColorValueChip(
                  label: 'HSL',
                  value: _hslString,
                  onTap: () => _copyToClipboard(_hslString),
                )),
              ],
            ),
            const SizedBox(height: 20),

            // Color picker
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: ColorPicker(
                  pickerColor: _currentColor,
                  onColorChanged: (color) => setState(() => _currentColor = color),
                  enableAlpha: false,
                  hexInputBar: true,
                  labelTypes: const [],
                  pickerAreaHeightPercent: 0.5,
                  displayThumbColor: true,
                  pickerAreaBorderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Saved colors
            if (_savedColors.isNotEmpty) ...[
              Row(
                children: [
                  Text('保存的颜色', style: theme.textTheme.titleSmall),
                  const Spacer(),
                  TextButton(
                    onPressed: () => setState(() => _savedColors.clear()),
                    child: const Text('清空'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _savedColors.map((color) {
                  final hex =
                      '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
                  return GestureDetector(
                    onTap: () => setState(() => _currentColor = color),
                    onLongPress: () => _copyToClipboard(hex),
                    child: Tooltip(
                      message: hex,
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: theme.colorScheme.outlineVariant,
                            width: color == _currentColor ? 3 : 1,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],

            const SizedBox(height: 16),
            // Material palette
            Text('Material 调色板', style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                Colors.red,
                Colors.pink,
                Colors.purple,
                Colors.deepPurple,
                Colors.indigo,
                Colors.blue,
                Colors.lightBlue,
                Colors.cyan,
                Colors.teal,
                Colors.green,
                Colors.lightGreen,
                Colors.lime,
                Colors.yellow,
                Colors.amber,
                Colors.orange,
                Colors.deepOrange,
                Colors.brown,
                Colors.grey,
                Colors.blueGrey,
              ].map((color) {
                return GestureDetector(
                  onTap: () => setState(() => _currentColor = color),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _ColorValueChip extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;

  const _ColorValueChip({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(label, style: Theme.of(context).textTheme.labelSmall),
            const SizedBox(height: 2),
            FittedBox(
              child: Text(
                value,
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 2),
            Icon(Icons.copy, size: 12, color: Theme.of(context).colorScheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}
