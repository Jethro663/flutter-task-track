import 'dart:math' as math;
import 'package:flutter/material.dart';

class RotatingGradientBackground extends StatefulWidget {
  final Widget child;

  const RotatingGradientBackground({super.key, required this.child});

  @override
  State<RotatingGradientBackground> createState() =>
      _RotatingGradientBackgroundState();
}

class _RotatingGradientBackgroundState
    extends State<RotatingGradientBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final double angle = _controller.value * 2 * math.pi;
        final begin = Alignment(math.cos(angle), math.sin(angle));
        final end = Alignment(-math.cos(angle), -math.sin(angle));

        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: begin,
              end: end,
              colors: const [
                Color(0xFF757575),
                Color(0xFF9E9E9E),
                Color(0xFFBDBDBD),
                Color(0xFFD6D6D2),
                Color(0xFFEFEFE9),
                Color(0xFFF7F6F2),
              ],
            ),
          ),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
