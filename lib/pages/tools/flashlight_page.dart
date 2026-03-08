import 'package:flutter/material.dart';
import 'package:torch_light/torch_light.dart';

class FlashlightPage extends StatefulWidget {
  const FlashlightPage({super.key});

  @override
  State<FlashlightPage> createState() => _FlashlightPageState();
}

class _FlashlightPageState extends State<FlashlightPage>
    with SingleTickerProviderStateMixin {
  bool _isOn = false;
  bool _isSOS = false;
  bool _isAvailable = true;
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
    _checkAvailability();
  }

  Future<void> _checkAvailability() async {
    try {
      _isAvailable = await TorchLight.isTorchAvailable();
    } catch (_) {
      _isAvailable = false;
    }
    if (mounted) setState(() {});
  }

  Future<void> _toggle() async {
    try {
      if (_isOn) {
        await TorchLight.disableTorch();
        _animController.reverse();
      } else {
        await TorchLight.enableTorch();
        _animController.forward();
      }
      setState(() => _isOn = !_isOn);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('手电筒操作失败: $e')),
        );
      }
    }
  }

  Future<void> _toggleSOS() async {
    setState(() => _isSOS = !_isSOS);
    if (_isSOS) {
      _playSOS();
    }
  }

  Future<void> _playSOS() async {
    // SOS: ... --- ...
    final pattern = [
      // S: short short short
      200, 200, 200, 200, 200, 400,
      // O: long long long
      600, 200, 600, 200, 600, 400,
      // S: short short short
      200, 200, 200, 200, 200, 800,
    ];

    for (int i = 0; i < pattern.length && _isSOS; i++) {
      if (i % 2 == 0) {
        try {
          await TorchLight.enableTorch();
          setState(() => _isOn = true);
        } catch (_) {}
      } else {
        try {
          await TorchLight.disableTorch();
          setState(() => _isOn = false);
        } catch (_) {}
      }
      await Future.delayed(Duration(milliseconds: pattern[i]));
    }

    if (_isSOS && mounted) {
      _playSOS(); // Loop
    }
  }

  @override
  void dispose() {
    _isSOS = false;
    if (_isOn) {
      TorchLight.disableTorch();
    }
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('手电筒')),
      body: Container(
        decoration: BoxDecoration(
          gradient: _isOn
              ? LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.yellow.withOpacity(0.3),
                    Colors.transparent,
                  ],
                )
              : null,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!_isAvailable) ...[
                Icon(Icons.flashlight_off, size: 80, color: theme.colorScheme.error),
                const SizedBox(height: 16),
                Text('此设备不支持手电筒', style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                Text('请在带有闪光灯的设备上使用',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    )),
              ] else ...[
                // Main flashlight button
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: GestureDetector(
                    onTap: _toggle,
                    child: Container(
                      width: 180,
                      height: 180,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _isOn
                            ? Colors.yellow.shade700
                            : theme.colorScheme.surfaceContainerHighest,
                        boxShadow: _isOn
                            ? [
                                BoxShadow(
                                  color: Colors.yellow.withOpacity(0.5),
                                  blurRadius: 40,
                                  spreadRadius: 10,
                                ),
                              ]
                            : null,
                      ),
                      child: Icon(
                        _isOn ? Icons.flashlight_on : Icons.flashlight_off,
                        size: 72,
                        color: _isOn ? Colors.white : theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  _isOn ? '已开启' : '已关闭',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '点击圆形按钮开关手电筒',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 48),
                // SOS button
                OutlinedButton.icon(
                  onPressed: _toggleSOS,
                  icon: Icon(_isSOS ? Icons.stop : Icons.sos),
                  label: Text(_isSOS ? '停止 SOS' : 'SOS 模式'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _isSOS ? theme.colorScheme.error : null,
                    side: _isSOS
                        ? BorderSide(color: theme.colorScheme.error)
                        : null,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
