import 'package:flutter/material.dart';
import '../models/tool_item.dart';
import '../widgets/tool_card.dart';
import 'tools/calculator_page.dart';
import 'tools/unit_converter_page.dart';
import 'tools/currency_converter_page.dart';
import 'tools/bmi_calculator_page.dart';
import 'tools/mortgage_calculator_page.dart';
import 'tools/qr_code_page.dart';
import 'tools/word_counter_page.dart';
import 'tools/json_formatter_page.dart';
import 'tools/text_crypto_page.dart';
import 'tools/flashlight_page.dart';
import 'tools/compass_page.dart';
import 'tools/noise_meter_page.dart';
import 'tools/color_picker_page.dart';
import 'tools/timer_page.dart';
import 'tools/random_number_page.dart';
import 'tools/password_generator_page.dart';

class HomePage extends StatefulWidget {
  final VoidCallback onToggleTheme;
  final ThemeMode themeMode;

  const HomePage({
    super.key,
    required this.onToggleTheme,
    required this.themeMode,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _selectedCategory = '全部';
  String _searchQuery = '';

  final List<ToolItem> _tools = [
    // 计算工具
    ToolItem(
      name: '计算器',
      description: '标准科学计算器',
      icon: Icons.calculate_outlined,
      color: Colors.blue,
      category: '计算',
      pageBuilder: (_) => const CalculatorPage(),
    ),
    ToolItem(
      name: '单位换算',
      description: '长度/重量/温度/面积/体积',
      icon: Icons.swap_horiz_outlined,
      color: Colors.teal,
      category: '计算',
      pageBuilder: (_) => const UnitConverterPage(),
    ),
    ToolItem(
      name: '汇率换算',
      description: '主要货币换算',
      icon: Icons.currency_exchange_outlined,
      color: Colors.green,
      category: '计算',
      pageBuilder: (_) => const CurrencyConverterPage(),
    ),
    ToolItem(
      name: 'BMI 计算',
      description: '身体质量指数',
      icon: Icons.monitor_weight_outlined,
      color: Colors.orange,
      category: '计算',
      pageBuilder: (_) => const BmiCalculatorPage(),
    ),
    ToolItem(
      name: '房贷计算',
      description: '等额本息/等额本金',
      icon: Icons.house_outlined,
      color: Colors.indigo,
      category: '计算',
      pageBuilder: (_) => const MortgageCalculatorPage(),
    ),
    // 文本工具
    ToolItem(
      name: '二维码',
      description: '生成和扫描二维码',
      icon: Icons.qr_code_2_outlined,
      color: Colors.purple,
      category: '文本',
      pageBuilder: (_) => const QrCodePage(),
    ),
    ToolItem(
      name: '字数统计',
      description: '中英文字数/字符数/行数',
      icon: Icons.text_fields_outlined,
      color: Colors.cyan,
      category: '文本',
      pageBuilder: (_) => const WordCounterPage(),
    ),
    ToolItem(
      name: 'JSON 格式化',
      description: 'JSON 美化和压缩',
      icon: Icons.data_object_outlined,
      color: Colors.amber,
      category: '文本',
      pageBuilder: (_) => const JsonFormatterPage(),
    ),
    ToolItem(
      name: '文本加解密',
      description: 'Base64/MD5/URL 编码',
      icon: Icons.enhanced_encryption_outlined,
      color: Colors.red,
      category: '文本',
      pageBuilder: (_) => const TextCryptoPage(),
    ),
    // 生活工具
    ToolItem(
      name: '手电筒',
      description: '调用闪光灯',
      icon: Icons.flashlight_on_outlined,
      color: Colors.yellow.shade800,
      category: '生活',
      pageBuilder: (_) => const FlashlightPage(),
    ),
    ToolItem(
      name: '指南针',
      description: '方向指示',
      icon: Icons.explore_outlined,
      color: Colors.brown,
      category: '生活',
      pageBuilder: (_) => const CompassPage(),
    ),
    ToolItem(
      name: '噪音检测',
      description: '分贝测量',
      icon: Icons.mic_outlined,
      color: Colors.pink,
      category: '生活',
      pageBuilder: (_) => const NoiseMeterPage(),
    ),
    ToolItem(
      name: '颜色提取',
      description: '调色板 + HEX/RGB',
      icon: Icons.palette_outlined,
      color: Colors.deepPurple,
      category: '生活',
      pageBuilder: (_) => const ColorPickerPage(),
    ),
    ToolItem(
      name: '计时器',
      description: '倒计时/秒表',
      icon: Icons.timer_outlined,
      color: Colors.lightBlue,
      category: '生活',
      pageBuilder: (_) => const TimerPage(),
    ),
    ToolItem(
      name: '随机数',
      description: '自定义范围随机数',
      icon: Icons.casino_outlined,
      color: Colors.deepOrange,
      category: '生活',
      pageBuilder: (_) => const RandomNumberPage(),
    ),
    ToolItem(
      name: '密码生成',
      description: '可定制长度和复杂度',
      icon: Icons.password_outlined,
      color: Colors.blueGrey,
      category: '生活',
      pageBuilder: (_) => const PasswordGeneratorPage(),
    ),
  ];

  final List<String> _categories = ['全部', '计算', '文本', '生活'];

  List<ToolItem> get _filteredTools {
    return _tools.where((tool) {
      final matchesCategory =
          _selectedCategory == '全部' || tool.category == _selectedCategory;
      final matchesSearch = _searchQuery.isEmpty ||
          tool.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          tool.description.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.build_outlined, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            const Text('工具箱'),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              widget.themeMode == ThemeMode.dark
                  ? Icons.light_mode_outlined
                  : Icons.dark_mode_outlined,
            ),
            onPressed: widget.onToggleTheme,
            tooltip: '切换主题',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: '搜索工具...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(28),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20),
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),
          // Category chips
          SizedBox(
            height: 48,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final cat = _categories[index];
                final isSelected = cat == _selectedCategory;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: FilterChip(
                    label: Text(cat),
                    selected: isSelected,
                    onSelected: (_) => setState(() => _selectedCategory = cat),
                    showCheckmark: false,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          // Tool grid
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 0.85,
              ),
              itemCount: _filteredTools.length,
              itemBuilder: (context, index) {
                return ToolCard(tool: _filteredTools[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}
