import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'package:noise_meter/noise_meter.dart';
import 'package:permission_handler/permission_handler.dart';

class NoiseMeterPage extends StatefulWidget {
  const NoiseMeterPage({super.key});

  @override
  State<NoiseMeterPage> createState() => _NoiseMeterPageState();
}

class _NoiseMeterPageState extends State<NoiseMeterPage> {
  bool _isRecording = false;
  double _currentDb = 0;
  double _maxDb = 0;
  double _minDb = double.infinity;
  double _avgDb = 0;
  final List<double> _dbHistory = [];
  NoiseMeter? _noiseMeter;
  StreamSubscription<NoiseReading>? _noiseSubscription;

  @override
  void initState() {
    super.initState();
    _noiseMeter = NoiseMeter();
  }

  String get _noiseLevel {
    if (_currentDb < 30) return '极安静';
    if (_currentDb < 50) return '安静';
    if (_currentDb < 65) return '正常';
    if (_currentDb < 80) return '较吵';
    if (_currentDb < 100) return '很吵';
    return '危险';
  }

  Color get _noiseColor {
    if (_currentDb < 30) return Colors.green.shade800;
    if (_currentDb < 50) return Colors.green;
    if (_currentDb < 65) return Colors.yellow.shade700;
    if (_currentDb < 80) return Colors.orange;
    if (_currentDb < 100) return Colors.deepOrange;
    return Colors.red;
  }

  IconData get _noiseIcon {
    if (_currentDb < 30) return Icons.volume_off;
    if (_currentDb < 50) return Icons.volume_mute;
    if (_currentDb < 80) return Icons.volume_down;
    return Icons.volume_up;
  }

  String get _noiseDescription {
    if (_currentDb < 30) return '图书馆、耳语';
    if (_currentDb < 50) return '安静的房间、轻声交谈';
    if (_currentDb < 65) return '正常交谈、办公室';
    if (_currentDb < 80) return '繁忙交通、餐厅';
    if (_currentDb < 100) return '工厂噪音，长期暴露有害';
    return '⚠️ 可能损害听力！';
  }

  Future<void> _startRecording() async {
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('需要麦克风权限')),
        );
      }
      return;
    }

    _dbHistory.clear();
    _maxDb = 0;
    _minDb = double.infinity;

    try {
      _noiseSubscription = _noiseMeter?.noise.listen(
        (NoiseReading reading) {
          if (mounted) {
            setState(() {
              _currentDb = reading.meanDecibel.clamp(0, 150);
              _dbHistory.add(_currentDb);
              if (_currentDb > _maxDb) _maxDb = _currentDb;
              if (_currentDb < _minDb) _minDb = _currentDb;
              _avgDb = _dbHistory.reduce((a, b) => a + b) / _dbHistory.length;
            });
          }
        },
        onError: (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('噪音检测错误: $e')),
            );
          }
          _stopRecording();
        },
      );
      setState(() => _isRecording = true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('启动失败: $e')),
        );
      }
    }
  }

  void _stopRecording() {
    _noiseSubscription?.cancel();
    setState(() => _isRecording = false);
  }

  void _reset() {
    setState(() {
      _currentDb = 0;
      _maxDb = 0;
      _minDb = double.infinity;
      _avgDb = 0;
      _dbHistory.clear();
    });
  }

  @override
  void dispose() {
    _noiseSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('噪音检测'),
        actions: [
          if (_dbHistory.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _reset,
              tooltip: '重置',
            ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Noise level display
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 220,
                    height: 220,
                    child: CircularProgressIndicator(
                      value: (_currentDb / 120).clamp(0, 1),
                      strokeWidth: 12,
                      backgroundColor:
                          theme.colorScheme.surfaceContainerHighest,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(_noiseColor),
                      strokeCap: StrokeCap.round,
                    ),
                  ),
                  Column(
                    children: [
                      Icon(_noiseIcon, size: 40, color: _noiseColor),
                      const SizedBox(height: 8),
                      Text(
                        '${_currentDb.toStringAsFixed(1)}',
                        style: theme.textTheme.displayMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: _noiseColor,
                        ),
                      ),
                      Text(
                        'dB',
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Level badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  color: _noiseColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _noiseColor.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    Text(
                      _noiseLevel,
                      style: TextStyle(
                        color: _noiseColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      _noiseDescription,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: _noiseColor.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Stats
              if (_dbHistory.isNotEmpty)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _StatCard(
                      label: '最小',
                      value: '${_minDb.toStringAsFixed(1)} dB',
                      icon: Icons.arrow_downward,
                      color: Colors.green,
                    ),
                    _StatCard(
                      label: '平均',
                      value: '${_avgDb.toStringAsFixed(1)} dB',
                      icon: Icons.horizontal_rule,
                      color: Colors.blue,
                    ),
                    _StatCard(
                      label: '最大',
                      value: '${_maxDb.toStringAsFixed(1)} dB',
                      icon: Icons.arrow_upward,
                      color: Colors.red,
                    ),
                  ],
                ),
              const SizedBox(height: 32),

              // Control button
              FilledButton.icon(
                onPressed: _isRecording ? _stopRecording : _startRecording,
                icon:
                    Icon(_isRecording ? Icons.stop : Icons.mic),
                label: Text(_isRecording ? '停止检测' : '开始检测'),
                style: FilledButton.styleFrom(
                  backgroundColor:
                      _isRecording ? theme.colorScheme.error : null,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
              ),

              const SizedBox(height: 24),
              // Reference scale
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('噪音参考', style: theme.textTheme.titleSmall),
                      const SizedBox(height: 8),
                      _buildRefRow('0-30 dB', '极安静 (耳语、树叶沙沙)', Colors.green.shade800),
                      _buildRefRow('30-50 dB', '安静 (图书馆、安静房间)', Colors.green),
                      _buildRefRow('50-65 dB', '正常 (交谈、办公室)', Colors.yellow.shade700),
                      _buildRefRow('65-80 dB', '较吵 (交通、餐厅)', Colors.orange),
                      _buildRefRow('80-100 dB', '很吵 (工厂、电锯)', Colors.deepOrange),
                      _buildRefRow('100+ dB', '危险 (飞机引擎)', Colors.red),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRefRow(String range, String desc, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Container(width: 12, height: 12, decoration: BoxDecoration(
            color: color, borderRadius: BorderRadius.circular(3),
          )),
          const SizedBox(width: 8),
          Text(range, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
          const SizedBox(width: 8),
          Expanded(child: Text(desc, style: const TextStyle(fontSize: 12))),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(
          fontWeight: FontWeight.bold, color: color, fontSize: 14,
        )),
        Text(label, style: Theme.of(context).textTheme.labelSmall),
      ],
    );
  }
}
