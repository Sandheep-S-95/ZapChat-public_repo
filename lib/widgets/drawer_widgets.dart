import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../utilities/neon_theme.dart';

class DrawerHeaderBackground extends StatefulWidget {
  final Widget child;
  const DrawerHeaderBackground({super.key, required this.child});

  @override
  State<DrawerHeaderBackground> createState() => _DrawerHeaderBackgroundState();
}

class _DrawerHeaderBackgroundState extends State<DrawerHeaderBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Base solid sea color
        Positioned.fill(
          child: Container(color: const Color(0xFF4DD0E1)),
        ),
        // Animated Waves
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return CustomPaint(
                painter: _WaterWavePainter(_controller.value),
              );
            },
          ),
        ),
        // Content on top
        widget.child,
      ],
    );
  }
}

class _WaterWavePainter extends CustomPainter {
  final double progress;
  _WaterWavePainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint1 = Paint()
      ..color = const Color(0xFFB2EBF2).withValues(alpha: 0.4)
      ..style = PaintingStyle.fill;
    
    final paint2 = Paint()
      ..color = const Color(0xFF80DEEA).withValues(alpha: 0.5)
      ..style = PaintingStyle.fill;

    final paint3 = Paint()
      ..color = const Color(0xFF26C6DA).withValues(alpha: 0.6)
      ..style = PaintingStyle.fill;

    _drawWave(canvas, size, paint3, 1.0, 0.15, progress * 2 * math.pi);
    _drawWave(canvas, size, paint2, 1.2, 0.40, (progress + 0.3) * 2 * math.pi * -1.2);
    _drawWave(canvas, size, paint1, 1.5, 0.65, (progress + 0.6) * 2 * math.pi);
  }

  void _drawWave(Canvas canvas, Size size, Paint paint, double frequency, double heightPercent, double phase) {
    final path = Path();
    final yBase = size.height * heightPercent;
    path.moveTo(0, size.height);
    path.lineTo(0, yBase);
    
    for (double i = 0; i <= size.width; i++) {
      final y = yBase + math.sin((i / size.width) * 2 * math.pi * frequency + phase) * 15;
      path.lineTo(i, y);
    }
    path.lineTo(size.width, size.height);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_WaterWavePainter old) => old.progress != progress;
}

class RevolvingAvatar extends StatefulWidget {
  final String imageUrl;
  final String initial;
  final double size;

  const RevolvingAvatar({
    super.key,
    required this.imageUrl,
    required this.initial,
    this.size = 64,
  });

  @override
  State<RevolvingAvatar> createState() => _RevolvingAvatarState();
}

class _RevolvingAvatarState extends State<RevolvingAvatar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size * 1.5,
      height: widget.size * 1.5,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Orbiting balls
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return CustomPaint(
                size: Size(widget.size * 1.5, widget.size * 1.5),
                painter: _OrbitPainter(_controller.value, widget.size / 2 + 10),
              );
            },
          ),
          // Central Avatar
          Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: CircleAvatar(
              backgroundColor: ZapColors.accentPurple,
              backgroundImage: widget.imageUrl.isNotEmpty
                  ? NetworkImage(widget.imageUrl)
                  : null,
              child: widget.imageUrl.isEmpty
                  ? Text(
                      widget.initial,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: widget.size * 0.4,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}

class _OrbitPainter extends CustomPainter {
  final double progress;
  final double radius;
  _OrbitPainter(this.progress, this.radius);

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    final blurFilter = const MaskFilter.blur(BlurStyle.normal, 5.0);

    final paint1 = Paint()..color = Colors.white;
    final glow1 = Paint()
      ..color = Colors.white.withValues(alpha: 0.8)
      ..maskFilter = blurFilter;

    final paint2 = Paint()..color = const Color(0xFF00E5FF);
    final glow2 = Paint()
      ..color = const Color(0xFF00E5FF).withValues(alpha: 0.8)
      ..maskFilter = blurFilter;

    final paint3 = Paint()..color = const Color(0xFF0050B0);
    final glow3 = Paint()
      ..color = const Color(0xFF0050B0).withValues(alpha: 0.8)
      ..maskFilter = blurFilter;

    // 3 balls offset by 120 degrees (2*pi/3)
    final angle1 = progress * 2 * math.pi;
    final angle2 = angle1 + (2 * math.pi / 3);
    final angle3 = angle1 + (4 * math.pi / 3);

    // Ball sizes
    const ballRadius = 4.0;
    const glowRadius = 9.0;

    final offset1 = Offset(cx + radius * math.cos(angle1), cy + radius * math.sin(angle1));
    canvas.drawCircle(offset1, glowRadius, glow1);
    canvas.drawCircle(offset1, ballRadius, paint1);

    final offset2 = Offset(cx + radius * math.cos(angle2), cy + radius * math.sin(angle2));
    canvas.drawCircle(offset2, glowRadius, glow2);
    canvas.drawCircle(offset2, ballRadius, paint2);

    final offset3 = Offset(cx + radius * math.cos(angle3), cy + radius * math.sin(angle3));
    canvas.drawCircle(offset3, glowRadius, glow3);
    canvas.drawCircle(offset3, ballRadius, paint3);
  }

  @override
  bool shouldRepaint(_OrbitPainter old) => old.progress != progress;
}
