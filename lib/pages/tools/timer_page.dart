import 'package:flutter/material.dart';
import 'dart:async';

class TimerPage extends StatefulWidget {
  const TimerPage({super.key});

  @override
  State<TimerPage> createState() => _TimerPageState();
}

class _TimerPageState extends State<TimerPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('计时器'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.timer), text: '秒表'),
            Tab(icon: Icon(Icons.hourglass_empty), text: '倒计时'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _StopwatchTab(),
          _CountdownTab(),
        ],
      ),
    );
  }
}

// ========== Stopwatch Tab ==========
class _StopwatchTab extends StatefulWidget {
  const _StopwatchTab();

  @override
  State<_StopwatchTab> createState() => _StopwatchTabState();
}

class _StopwatchTabState extends State<_StopwatchTab> {
  final Stopwatch _stopwatch = Stopwatch();
  Timer? _timer;
  final List<Duration> _laps = [];

  void _start() {
    _stopwatch.start();
    _timer = Timer.periodic(const Duration(milliseconds: 30), (_) {
      if (mounted) setState(() {});
    });
  }

  void _stop() {
    _stopwatch.stop();
    _timer?.cancel();
    setState(() {});
  }

  void _reset() {
    _stopwatch.reset();
    _timer?.cancel();
    setState(() => _laps.clear());
  }

  void _lap() {
    setState(() => _laps.insert(0, _stopwatch.elapsed));
  }

  String _formatDuration(Duration d) {
    final hours = d.inHours;
    final minutes = d.inMinutes.remainder(60);
    final seconds = d.inSeconds.remainder(60);
    final millis = d.inMilliseconds.remainder(1000) ~/ 10;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}.${millis.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}.${millis.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final elapsed = _stopwatch.elapsed;
    final isRunning = _stopwatch.isRunning;

    return Column(
      children: [
        // Display
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 48),
          child: Text(
            _formatDuration(elapsed),
            style: theme.textTheme.displayLarge?.copyWith(
              fontWeight: FontWeight.w200,
              fontFamily: 'monospace',
              letterSpacing: 2,
            ),
          ),
        ),
        // Controls
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isRunning) ...[
              FloatingActionButton(
                heroTag: 'lap',
                onPressed: _lap,
                backgroundColor: theme.colorScheme.secondaryContainer,
                child: const Icon(Icons.flag),
              ),
              const SizedBox(width: 24),
              FloatingActionButton.large(
                heroTag: 'stop',
                onPressed: _stop,
                backgroundColor: theme.colorScheme.errorContainer,
                child: Icon(Icons.pause, color: theme.colorScheme.error),
              ),
            ] else ...[
              if (_stopwatch.elapsedMilliseconds > 0)
                FloatingActionButton(
                  heroTag: 'reset',
                  onPressed: _reset,
                  backgroundColor: theme.colorScheme.errorContainer,
                  child: Icon(Icons.refresh, color: theme.colorScheme.error),
                ),
              if (_stopwatch.elapsedMilliseconds > 0) const SizedBox(width: 24),
              FloatingActionButton.large(
                heroTag: 'start',
                onPressed: _start,
                backgroundColor: theme.colorScheme.primaryContainer,
                child: Icon(Icons.play_arrow, color: theme.colorScheme.primary, size: 36),
              ),
            ],
          ],
        ),
        const SizedBox(height: 24),
        // Laps
        if (_laps.isNotEmpty) ...[
          const Divider(),
          Expanded(
            child: ListView.builder(
              itemCount: _laps.length,
              itemBuilder: (context, index) {
                final lapNum = _laps.length - index;
                final lapTime = _laps[index];
                final diff = index < _laps.length - 1
                    ? _laps[index] - _laps[index + 1]
                    : _laps[index];
                return ListTile(
                  leading: CircleAvatar(
                    radius: 16,
                    child: Text('$lapNum', style: const TextStyle(fontSize: 12)),
                  ),
                  title: Text(_formatDuration(lapTime)),
                  trailing: Text(
                    '+${_formatDuration(diff)}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                );
              },
            ),
          ),
        ] else
          const Spacer(),
      ],
    );
  }
}

// ========== Countdown Tab ==========
class _CountdownTab extends StatefulWidget {
  const _CountdownTab();

  @override
  State<_CountdownTab> createState() => _CountdownTabState();
}

class _CountdownTabState extends State<_CountdownTab> {
  int _hours = 0;
  int _minutes = 5;
  int _seconds = 0;
  Duration _remaining = Duration.zero;
  Duration _total = Duration.zero;
  Timer? _timer;
  bool _isRunning = false;

  void _start() {
    if (_remaining == Duration.zero) {
      _total = Duration(hours: _hours, minutes: _minutes, seconds: _seconds);
      _remaining = _total;
    }
    if (_remaining.inSeconds <= 0) return;

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        _remaining -= const Duration(seconds: 1);
        if (_remaining.inSeconds <= 0) {
          _remaining = Duration.zero;
          _timer?.cancel();
          _isRunning = false;
          _showFinishDialog();
        }
      });
    });
    setState(() => _isRunning = true);
  }

  void _pause() {
    _timer?.cancel();
    setState(() => _isRunning = false);
  }

  void _reset() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _remaining = Duration.zero;
      _total = Duration.zero;
    });
  }

  void _showFinishDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.alarm, size: 48),
        title: const Text('时间到！'),
        content: const Text('倒计时已完成'),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  double get _progress {
    if (_total.inSeconds == 0) return 0;
    return _remaining.inSeconds / _total.inSeconds;
  }

  String _formatDuration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    final s = d.inSeconds.remainder(60);
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isActive = _remaining.inSeconds > 0 || _isRunning;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          if (!isActive) ...[
            // Time pickers
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _TimeScrollPicker(
                  label: '时',
                  value: _hours,
                  max: 23,
                  onChanged: (v) => setState(() => _hours = v),
                ),
                const Text(':', style: TextStyle(fontSize: 32)),
                _TimeScrollPicker(
                  label: '分',
                  value: _minutes,
                  max: 59,
                  onChanged: (v) => setState(() => _minutes = v),
                ),
                const Text(':', style: TextStyle(fontSize: 32)),
                _TimeScrollPicker(
                  label: '秒',
                  value: _seconds,
                  max: 59,
                  onChanged: (v) => setState(() => _seconds = v),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Quick presets
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _PresetChip('1 分钟', () => setState(() { _hours = 0; _minutes = 1; _seconds = 0; })),
                _PresetChip('3 分钟', () => setState(() { _hours = 0; _minutes = 3; _seconds = 0; })),
                _PresetChip('5 分钟', () => setState(() { _hours = 0; _minutes = 5; _seconds = 0; })),
                _PresetChip('10 分钟', () => setState(() { _hours = 0; _minutes = 10; _seconds = 0; })),
                _PresetChip('30 分钟', () => setState(() { _hours = 0; _minutes = 30; _seconds = 0; })),
                _PresetChip('1 小时', () => setState(() { _hours = 1; _minutes = 0; _seconds = 0; })),
              ],
            ),
          ] else ...[
            // Countdown display
            const SizedBox(height: 32),
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 250,
                  height: 250,
                  child: CircularProgressIndicator(
                    value: _progress,
                    strokeWidth: 8,
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                    strokeCap: StrokeCap.round,
                  ),
                ),
                Text(
                  _formatDuration(_remaining),
                  style: theme.textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.w200,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 40),
          // Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isActive)
                FloatingActionButton(
                  heroTag: 'cd_reset',
                  onPressed: _reset,
                  backgroundColor: theme.colorScheme.errorContainer,
                  child: Icon(Icons.stop, color: theme.colorScheme.error),
                ),
              if (isActive) const SizedBox(width: 24),
              FloatingActionButton.large(
                heroTag: 'cd_toggle',
                onPressed: _isRunning ? _pause : _start,
                backgroundColor: _isRunning
                    ? theme.colorScheme.errorContainer
                    : theme.colorScheme.primaryContainer,
                child: Icon(
                  _isRunning ? Icons.pause : Icons.play_arrow,
                  size: 36,
                  color: _isRunning
                      ? theme.colorScheme.error
                      : theme.colorScheme.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TimeScrollPicker extends StatelessWidget {
  final String label;
  final int value;
  final int max;
  final ValueChanged<int> onChanged;

  const _TimeScrollPicker({
    required this.label,
    required this.value,
    required this.max,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: Theme.of(context).textTheme.labelSmall),
        SizedBox(
          width: 80,
          height: 120,
          child: ListWheelScrollView.useDelegate(
            itemExtent: 40,
            physics: const FixedExtentScrollPhysics(),
            controller: FixedExtentScrollController(initialItem: value),
            onSelectedItemChanged: onChanged,
            childDelegate: ListWheelChildBuilderDelegate(
              builder: (context, index) {
                if (index < 0 || index > max) return null;
                return Center(
                  child: Text(
                    index.toString().padLeft(2, '0'),
                    style: TextStyle(
                      fontSize: index == value ? 28 : 20,
                      fontWeight: index == value ? FontWeight.bold : FontWeight.normal,
                      color: index == value
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                );
              },
              childCount: max + 1,
            ),
          ),
        ),
      ],
    );
  }
}

class _PresetChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _PresetChip(this.label, this.onTap);

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text(label),
      onPressed: onTap,
    );
  }
}
