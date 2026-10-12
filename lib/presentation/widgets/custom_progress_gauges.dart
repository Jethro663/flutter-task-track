import 'dart:math' as math;
import 'package:flutter/material.dart';

class SemiCircleGauge extends StatelessWidget {
  final double percentage;
  final double size;
  final Color activeColor;
  final Color trackColor;

  const SemiCircleGauge({
    super.key,
    required this.percentage,
    this.size = 90,
    this.activeColor = const Color(0xFF1B381E),
    this.trackColor = const Color(0x331B381E),
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size * 0.6,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: percentage.clamp(0.0, 100.0) / 100.0),
            duration: const Duration(milliseconds: 1200),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return CustomPaint(
                size: Size(size, size * 0.6),
                painter: _SemiCirclePainter(
                  progress: value,
                  activeColor: activeColor,
                  trackColor: trackColor,
                ),
              );
            },
          ),
          Positioned(
            bottom: 0,
            child: Text(
              "${percentage.toInt()}%",
              style: TextStyle(
                fontSize: size * 0.22,
                fontWeight: FontWeight.w900,
                color: activeColor,
                letterSpacing: -0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SemiCirclePainter extends CustomPainter {
  final double progress;
  final Color activeColor;
  final Color trackColor;

  _SemiCirclePainter({
    required this.progress,
    required this.activeColor,
    required this.trackColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height);
    final radius = size.width / 2 - 6;

    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    final activePaint = Paint()
      ..color = activeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi,
      math.pi,
      false,
      trackPaint,
    );

    if (progress > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        math.pi,
        math.pi * progress,
        false,
        activePaint,
      );
    }

    final int tickCount = 28;
    final tickPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    for (int i = 0; i <= tickCount; i++) {
      final t = i / tickCount;
      final angle = math.pi + (math.pi * t);
      final isFilled = t <= progress;

      tickPaint.color = isFilled ? activeColor.withValues(alpha: 0.8) : trackColor.withValues(alpha: 0.4);

      final innerR = radius - 14;
      final outerR = radius - 4;

      final p1 = Offset(center.dx + innerR * math.cos(angle), center.dy + innerR * math.sin(angle));
      final p2 = Offset(center.dx + outerR * math.cos(angle), center.dy + outerR * math.sin(angle));
      canvas.drawLine(p1, p2, tickPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _SemiCirclePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.activeColor != activeColor ||
        oldDelegate.trackColor != trackColor;
  }
}

class CircularProgressBadge extends StatelessWidget {
  final double percentage;
  final double size;
  final Color activeColor;
  final Color trackColor;
  final Color textColor;

  const CircularProgressBadge({
    super.key,
    required this.percentage,
    this.size = 52,
    this.activeColor = const Color(0xFF1E1E24),
    this.trackColor = const Color(0x221E1E24),
    this.textColor = const Color(0xFF1E1E24),
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: percentage.clamp(0.0, 100.0) / 100.0),
      duration: const Duration(milliseconds: 1000),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: Size(size, size),
                painter: _CircularProgressPainter(
                  progress: value,
                  activeColor: activeColor,
                  trackColor: trackColor,
                ),
              ),
              Text(
                "${percentage.toInt()}%",
                style: TextStyle(
                  fontSize: size * 0.28,
                  fontWeight: FontWeight.w800,
                  color: textColor,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CircularProgressPainter extends CustomPainter {
  final double progress;
  final Color activeColor;
  final Color trackColor;

  _CircularProgressPainter({
    required this.progress,
    required this.activeColor,
    required this.trackColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - 4;

    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.5
      ..strokeCap = StrokeCap.round;

    final activePaint = Paint()
      ..color = activeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.5
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    if (progress > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        2 * math.pi * progress,
        false,
        activePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _CircularProgressPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.activeColor != activeColor ||
        oldDelegate.trackColor != trackColor;
  }
}

class MultiSegmentProgressBar extends StatelessWidget {
  final double completedPercent;
  final double inProgressPercent;
  final double onHoldPercent;

  const MultiSegmentProgressBar({
    super.key,
    required this.completedPercent,
    required this.inProgressPercent,
    required this.onHoldPercent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 14,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(10),
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        children: [
          if (completedPercent > 0)
            Expanded(
              flex: (completedPercent * 100).toInt().clamp(1, 10000),
              child: Container(color: const Color(0xFF48BB78)),
            ),
          if (inProgressPercent > 0)
            Expanded(
              flex: (inProgressPercent * 100).toInt().clamp(1, 10000),
              child: Container(color: const Color(0xFF9F7AEA)),
            ),
          if (onHoldPercent > 0)
            Expanded(
              flex: (onHoldPercent * 100).toInt().clamp(1, 10000),
              child: Container(color: const Color(0xFFECC94B)),
            ),
          Expanded(
            flex: ((100 - (completedPercent + inProgressPercent + onHoldPercent)) * 100).toInt().clamp(0, 10000),
            child: Container(color: Colors.grey.shade300),
          ),
        ],
      ),
    );
  }
}

class InteractiveWeeklyBarChart extends StatefulWidget {
  final List<double> dayHeights;
  final Color barColor;
  final Color activeBarColor;

  const InteractiveWeeklyBarChart({
    super.key,
    required this.dayHeights,
    this.barColor = const Color(0x8848BB78),
    this.activeBarColor = const Color(0xFF22C55E),
  });

  @override
  State<InteractiveWeeklyBarChart> createState() => _InteractiveWeeklyBarChartState();
}

class _InteractiveWeeklyBarChartState extends State<InteractiveWeeklyBarChart> {
  int _selectedIndex = 3;

  final List<String> days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 120,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(7, (index) {
              final isSelected = _selectedIndex == index;
              final heightFraction = index < widget.dayHeights.length ? widget.dayHeights[index] : 0.4;
              final barHeight = 25.0 + (heightFraction * 80.0);

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedIndex = index;
                  });
                },
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 20.0, end: barHeight),
                  duration: Duration(milliseconds: 600 + (index * 60)),
                  curve: Curves.easeOutBack,
                  builder: (context, animHeight, child) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          width: isSelected ? 28 : 22,
                          height: isSelected ? animHeight + 6 : animHeight,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFF1B381E)
                                : const Color(0xFF1B381E).withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: const Color(0xFF1B381E).withValues(alpha: 0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    )
                                  ]
                                : null,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(7, (index) {
            final isSelected = _selectedIndex == index;
            return GestureDetector(
              onTap: () => setState(() => _selectedIndex = index),
              child: SizedBox(
                width: 28,
                child: Text(
                  days[index],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected ? const Color(0xFF1B381E) : const Color(0x991B381E),
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class AvatarStack extends StatelessWidget {
  final int count;
  final double size;

  const AvatarStack({
    super.key,
    required this.count,
    this.size = 28,
  });

  static const List<Color> avatarColors = [
    Color(0xFFFFB4A2),
    Color(0xFFB5E2FA),
    Color(0xFFE2C2FF),
    Color(0xFFFFE599),
  ];

  static const List<String> avatarInitials = ["A", "J", "E", "M"];

  @override
  Widget build(BuildContext context) {
    final displayCount = math.min(count, 3);
    return SizedBox(
      height: size,
      width: size + (displayCount - 1) * (size * 0.65),
      child: Stack(
        children: List.generate(displayCount, (index) {
          return Positioned(
            left: index * (size * 0.65),
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: avatarColors[index % avatarColors.length],
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Text(
                avatarInitials[index % avatarInitials.length],
                style: TextStyle(
                  fontSize: size * 0.42,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF212121),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
