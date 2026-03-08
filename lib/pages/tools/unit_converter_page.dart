import 'package:flutter/material.dart';

class UnitConverterPage extends StatefulWidget {
  const UnitConverterPage({super.key});

  @override
  State<UnitConverterPage> createState() => _UnitConverterPageState();
}

class _UnitConverterPageState extends State<UnitConverterPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _inputController = TextEditingController();
  String _result = '';

  // Category data
  final Map<String, Map<String, double>> _unitData = {
    '长度': {
      '米 (m)': 1.0,
      '千米 (km)': 1000.0,
      '厘米 (cm)': 0.01,
      '毫米 (mm)': 0.001,
      '英里 (mi)': 1609.344,
      '英尺 (ft)': 0.3048,
      '英寸 (in)': 0.0254,
      '码 (yd)': 0.9144,
      '海里': 1852.0,
    },
    '重量': {
      '千克 (kg)': 1.0,
      '克 (g)': 0.001,
      '毫克 (mg)': 0.000001,
      '吨 (t)': 1000.0,
      '磅 (lb)': 0.453592,
      '盎司 (oz)': 0.0283495,
      '斤': 0.5,
      '两': 0.05,
    },
    '温度': {
      '摄氏度 (°C)': 0, // Special handling
      '华氏度 (°F)': 0,
      '开尔文 (K)': 0,
    },
    '面积': {
      '平方米 (m²)': 1.0,
      '平方千米 (km²)': 1000000.0,
      '公顷 (ha)': 10000.0,
      '亩': 666.667,
      '平方英尺 (ft²)': 0.092903,
      '平方英里 (mi²)': 2589988.0,
      '英亩': 4046.86,
    },
    '体积': {
      '升 (L)': 1.0,
      '毫升 (mL)': 0.001,
      '立方米 (m³)': 1000.0,
      '加仑 (gal)': 3.78541,
      '品脱 (pt)': 0.473176,
      '杯': 0.24,
      '立方厘米 (cm³)': 0.001,
    },
  };

  late List<String> _categories;
  late String _fromUnit;
  late String _toUnit;
  late List<String> _currentUnits;

  @override
  void initState() {
    super.initState();
    _categories = _unitData.keys.toList();
    _tabController = TabController(length: _categories.length, vsync: this);
    _tabController.addListener(_onTabChanged);
    _updateUnitsForTab(0);
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;
    _updateUnitsForTab(_tabController.index);
  }

  void _updateUnitsForTab(int index) {
    setState(() {
      _currentUnits = _unitData[_categories[index]]!.keys.toList();
      _fromUnit = _currentUnits[0];
      _toUnit = _currentUnits.length > 1 ? _currentUnits[1] : _currentUnits[0];
      _result = '';
      _inputController.clear();
    });
  }

  void _convert() {
    final input = double.tryParse(_inputController.text);
    if (input == null) {
      setState(() => _result = '请输入有效数字');
      return;
    }

    final category = _categories[_tabController.index];
    double result;

    if (category == '温度') {
      result = _convertTemperature(input, _fromUnit, _toUnit);
    } else {
      final fromFactor = _unitData[category]![_fromUnit]!;
      final toFactor = _unitData[category]![_toUnit]!;
      result = input * fromFactor / toFactor;
    }

    setState(() {
      _result = _formatResult(result);
    });
  }

  double _convertTemperature(double value, String from, String to) {
    // Convert to Celsius first
    double celsius;
    if (from.contains('°C')) {
      celsius = value;
    } else if (from.contains('°F')) {
      celsius = (value - 32) * 5 / 9;
    } else {
      celsius = value - 273.15;
    }

    // Convert from Celsius to target
    if (to.contains('°C')) return celsius;
    if (to.contains('°F')) return celsius * 9 / 5 + 32;
    return celsius + 273.15; // Kelvin
  }

  String _formatResult(double value) {
    if (value == value.toInt().toDouble() && value.abs() < 1e15) {
      return value.toInt().toString();
    }
    return value.toStringAsFixed(6).replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
  }

  void _swapUnits() {
    setState(() {
      final temp = _fromUnit;
      _fromUnit = _toUnit;
      _toUnit = temp;
    });
    if (_inputController.text.isNotEmpty) _convert();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _inputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('单位换算'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: _categories.map((c) => Tab(text: c)).toList(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _inputController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
              decoration: const InputDecoration(
                labelText: '输入数值',
                hintText: '请输入要换算的数值',
                prefixIcon: Icon(Icons.input),
              ),
              onChanged: (_) => _convert(),
            ),
            const SizedBox(height: 20),
            // From unit
            DropdownButtonFormField<String>(
              value: _fromUnit,
              decoration: const InputDecoration(
                labelText: '从',
                prefixIcon: Icon(Icons.arrow_forward),
              ),
              items: _currentUnits.map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
              onChanged: (v) {
                setState(() => _fromUnit = v!);
                _convert();
              },
            ),
            const SizedBox(height: 12),
            // Swap button
            IconButton.filled(
              onPressed: _swapUnits,
              icon: const Icon(Icons.swap_vert),
              tooltip: '交换',
            ),
            const SizedBox(height: 12),
            // To unit
            DropdownButtonFormField<String>(
              value: _toUnit,
              decoration: const InputDecoration(
                labelText: '到',
                prefixIcon: Icon(Icons.arrow_back),
              ),
              items: _currentUnits.map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
              onChanged: (v) {
                setState(() => _toUnit = v!);
                _convert();
              },
            ),
            const SizedBox(height: 32),
            // Result
            if (_result.isNotEmpty)
              Card(
                color: theme.colorScheme.primaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Text(
                        '换算结果',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                      const SizedBox(height: 8),
                      FittedBox(
                        child: Text(
                          '$_result $_toUnit',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
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
