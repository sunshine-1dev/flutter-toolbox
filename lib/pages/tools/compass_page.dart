import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'package:flutter_compass/flutter_compass.dart';

class CompassPage extends StatefulWidget {
  const CompassPage({super.key});

  @override
  State<CompassPage> createState() => _CompassPageState();
}

class _CompassPageState extends State<CompassPage> {
  double _heading = 0;
  StreamSubscription? _compassSubscription;
  bool _hasCompass = true;

  @override
  void initState() {
    super.initState();
    _initCompass();
  }

  void _initCompass() {
    try {
      _compassSubscription = FlutterCompass.events?.listen((event) {
        if (mounted && event.heading != null) {
          setState(() => _heading = event.heading!);
        }
      }, onError: (_) {
        setState(() => _hasCompass = false);
      });
    } catch (_) {
      _hasCompass = false;
    }
  }

  String _getDirection(double heading) {
    if (heading >= 337.5 || heading < 22.5) return '北 N';
    if (heading < 67.5) return '东北 NE';
    if (heading < 112.5) return '东 E';
    if (heading < 157.5) return '东南 SE';
    if (heading < 202.5) return '南 S';
    if (heading < 247.5) return '西南 SW';
    if (heading < 292.5) return '西 W';
    return '西北 NW';
  }

  @override
  void dispose() {
    _compassSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('指南针')),
      body: Center(
        child: !_hasCompass
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.explore_off, size: 80,
                      color: theme.colorScheme.error),
                  const SizedBox(height: 16),
                  Text('此设备不支持指南针', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text('需要磁力传感器',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      )),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Direction text
                  Text(
                    _getDirection(_heading),
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${_heading.toStringAsFixed(1)}°',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Compass widget
                  SizedBox(
                    width: 300,
                    height: 300,
                    child: CustomPaint(
                      painter: _CompassPainter(
                        heading: _heading,
                        primaryColor: theme.colorScheme.primary,
                        onSurfaceColor: theme.colorScheme.onSurface,
                        surfaceColor: theme.colorScheme.surfaceContainerHighest,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  Text(
                    '请远离金属和电子设备以获得准确读数',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _CompassPainter extends CustomPainter {
  final double heading;
  final Color primaryColor;
  final Color onSurfaceColor;
  final Color surfaceColor;

  _CompassPainter({
    required this.heading,
    required this.primaryColor,
    required this.onSurfaceColor,
    required this.surfaceColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;

    // Background circle
    final bgPaint = Paint()
      ..color = surfaceColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, bgPaint);

    // Border
    final borderPaint = Paint()
      ..color = onSurfaceColor.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, radius, borderPaint);

    // Rotate for heading
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(-heading * pi / 180);

    // Draw tick marks
    for (int i = 0; i < 360; i += 5) {
      final isCardinal = i % 90 == 0;
      final isMajor = i % 30 == 0;
      final tickLength = isCardinal ? 20.0 : (isMajor ? 12.0 : 6.0);

      final paint = Paint()
        ..color = isCardinal ? primaryColor : onSurfaceColor.withOpacity(0.4)
        ..strokeWidth = isCardinal ? 3 : (isMajor ? 2 : 1);

      final angle = i * pi / 180;
      final outer = Offset(
        (radius - 5) * sin(angle),
        -(radius - 5) * cos(angle),
      );
      final inner = Offset(
        (radius - 5 - tickLength) * sin(angle),
        -(radius - 5 - tickLength) * cos(angle),
      );
      canvas.drawLine(outer, inner, paint);
    }

    // Cardinal direction labels
    final directions = {'N': 0, 'E': 90, 'S': 180, 'W': 270};
    for (final entry in directions.entries) {
      final angle = entry.value * pi / 180;
      final pos = Offset(
        (radius - 40) * sin(angle),
        -(radius - 40) * cos(angle),
      );

      final textPainter = TextPainter(
        text: TextSpan(
          text: entry.key,
          style: TextStyle(
            color: entry.key == 'N' ? Colors.red : onSurfaceColor,
            fontSize: entry.key == 'N' ? 24 : 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      canvas.save();
      canvas.translate(pos.dx, pos.dy);
      canvas.rotate(heading * pi / 180);
      textPainter.paint(
        canvas,
        Offset(-textPainter.width / 2, -textPainter.height / 2),
      );
      canvas.restore();
    }

    canvas.restore();

    // North indicator (red triangle at top)
    final northPaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;
    final path = Path()
      ..moveTo(center.dx, center.dy - radius + 2)
      ..lineTo(center.dx - 8, center.dy - radius + 18)
      ..lineTo(center.dx + 8, center.dy - radius + 18)
      ..close();
    canvas.drawPath(path, northPaint);

    // Center dot
    canvas.drawCircle(center, 6, Paint()..color = primaryColor);
    canvas.drawCircle(center, 3, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant _CompassPainter oldDelegate) =>
      oldDelegate.heading != heading;
}
