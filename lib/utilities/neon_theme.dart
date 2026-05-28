import 'package:flutter/material.dart';
import 'package:mesh_gradient/mesh_gradient.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'dart:math' as math;
import 'dart:ui' as ui;

// ══════════════════════════════════════════════════════════════════════
// ZapChat Dark Neon Theme System
// ══════════════════════════════════════════════════════════════════════

class ZapColors {
  // Core palette
  static const Color deepPurple = Color(0xFF0A0820);
  static const Color darkPurple = Color(0xFF0E0C2A);
  static const Color midPurple = Color(0xFF151040);
  static const Color lightPurple = Color(0xFF251E58);
  static const Color accentPurple = Color(0xFF3D3380);

  // Neon accents
  static const Color neonCyan = Color(0xFF00E5FF);
  static const Color neonCyanDim = Color(0xFF00B8D4);
  static const Color neonCyanGlow = Color(0x4000E5FF);
  static const Color neonBlue = Color(0xFF2979FF);
  static const Color neonCyanSoft = Color(0xFF80DEEA);

  // Surface colors
  static const Color cardDark = Color(0xFF110E35);
  static const Color cardLight = Color(0xFF1A1548);
  static const Color inputBg = Color(0xFF0C0A28);
  static const Color dividerColor = Color(0xFF231E50);
  static const Color surfaceOverlay = Color(0xFF161240);

  // Text colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0B0D0);
  static const Color textMuted = Color(0xFF6868A0);

  // Status colors
  static const Color onlineGreen = Color(0xFF00E676);
  static const Color errorRed = Color(0xFFFF5252);
  static const Color warningOrange = Color(0xFFFFAB40);

  // Bubble colors — premium chat upgrade
  static const Color bubbleMe = Color(0xFF007AFF);
  static const Color bubbleMeGrad = Color(0xFF00E5FF);
  static const Color bubbleOther = Color(0xFF0F1B26);
  static const Color bubbleOtherBorder = Color(0xFF1E3040);
  // Bubble glass overlay
  static const Color bubbleOtherGlass = Color(0xFF162230);
}

class ZapGradients {
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF18104A),
      Color(0xFF0E0C2A),
      Color(0xFF070518),
    ],
  );

  static const LinearGradient appBarGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF1C1450),
      Color(0xFF100E35),
    ],
  );

  static const LinearGradient buttonGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      Color(0xFF00E5FF), // Vibrant Neon Cyan (Aqua)
      Color(0xFF00B4D8), // Bright Azure/Aqua
    ],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF171248),
      Color(0xFF100E35),
    ],
  );

  // Premium "me" bubble: vivid cyan → electric blue
  static const LinearGradient bubbleMeGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF00C8E0),
      Color(0xFF0080CC),
    ],
  );

  static const LinearGradient sectionHeaderGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      Color(0xFF1E1855),
      Color(0xFF151040),
    ],
  );
}

class ZapTextStyles {
  static const List<Shadow> _textShadow = [
    Shadow(color: Colors.black54, blurRadius: 4, offset: Offset(0, 2)),
  ];

  static const TextStyle heading = TextStyle(
    color: ZapColors.textPrimary,
    fontSize: 28,
    fontWeight: FontWeight.w800,
    letterSpacing: 1.5,
    shadows: _textShadow,
  );

  static const TextStyle subheading = TextStyle(
    color: ZapColors.textSecondary,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    shadows: _textShadow,
  );

  static const TextStyle body = TextStyle(
    color: ZapColors.textPrimary,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    shadows: _textShadow,
  );

  static const TextStyle caption = TextStyle(
    color: ZapColors.textMuted,
    fontSize: 12,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle buttonText = TextStyle(
    color: Colors.white,
    fontSize: 16,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.0,
    shadows: _textShadow,
  );

  static const TextStyle sectionLabel = TextStyle(
    color: ZapColors.neonCyan,
    fontSize: 13,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.2,
    shadows: [
      Shadow(color: Colors.black87, blurRadius: 3, offset: Offset(0, 1)),
    ],
  );
}

class ZapDecorations {
  static BoxDecoration cardDecoration = BoxDecoration(
    gradient: ZapGradients.cardGradient,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: ZapColors.dividerColor, width: 1),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.35),
        blurRadius: 14,
        offset: const Offset(0, 4),
      ),
    ],
  );

  static BoxDecoration inputDecoration = BoxDecoration(
    color: ZapColors.inputBg,
    borderRadius: BorderRadius.circular(14),
    border: Border.all(color: ZapColors.neonCyan.withOpacity(0.25), width: 1.2),
  );

  static BoxDecoration glowButton = BoxDecoration(
    gradient: ZapGradients.buttonGradient,
    borderRadius: BorderRadius.circular(14),
    boxShadow: [
      BoxShadow(
        color: ZapColors.neonCyanGlow,
        blurRadius: 20,
        spreadRadius: 1,
      ),
    ],
  );

  static BoxDecoration outlineButton = BoxDecoration(
    color: Colors.transparent,
    borderRadius: BorderRadius.circular(14),
    border: Border.all(color: ZapColors.neonCyan, width: 1.5),
  );

  static InputDecoration neonInputDecoration({
    required String hint,
    required IconData icon,
    bool isPassword = false,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: ZapColors.textMuted, fontSize: 14),
      prefixIcon: Icon(icon, color: ZapColors.neonCyan, size: 20),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: ZapColors.inputBg,
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: ZapColors.neonCyan.withOpacity(0.25)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: ZapColors.neonCyan.withOpacity(0.25)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: ZapColors.neonCyan, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: ZapColors.errorRed),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════
// Creative Lightning Animation Widget  
// A beautiful, non-electric pulsing/swirling animation
// ══════════════════════════════════════════════════════════════════════

class AnimatedLightningLogo extends StatefulWidget {
  final double size;
  const AnimatedLightningLogo({super.key, this.size = 120});

  @override
  State<AnimatedLightningLogo> createState() => _AnimatedLightningLogoState();
}

class _AnimatedLightningLogoState extends State<AnimatedLightningLogo>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rotateController;
  late AnimationController _glowController;
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);

    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3500),
    )..repeat(reverse: true);

    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotateController.dispose();
    _glowController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_pulseController, _rotateController, _glowController, _shimmerController]),
      builder: (context, child) {
        double pulse = 0.92 + (_pulseController.value * 0.08);
        double glow = 0.3 + (_glowController.value * 0.7);
        double rotate = _rotateController.value * 2 * math.pi;
        double shimmer = _shimmerController.value;

        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Outer rotating glow ring
              Transform.rotate(
                angle: rotate,
                child: Container(
                  width: widget.size * 0.92,
                  height: widget.size * 0.92,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: SweepGradient(
                      colors: [
                        ZapColors.neonCyan.withOpacity(0),
                        ZapColors.neonCyan.withOpacity(glow * 0.45),
                        ZapColors.neonBlue.withOpacity(glow * 0.3),
                        ZapColors.accentPurple.withOpacity(glow * 0.2),
                        ZapColors.neonCyan.withOpacity(0),
                      ],
                    ),
                  ),
                ),
              ),
              // Secondary counter-rotating ring
              Transform.rotate(
                angle: -rotate * 0.6,
                child: Container(
                  width: widget.size * 0.85,
                  height: widget.size * 0.85,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: SweepGradient(
                      colors: [
                        ZapColors.neonBlue.withOpacity(0),
                        ZapColors.accentPurple.withOpacity(glow * 0.25),
                        ZapColors.neonCyanSoft.withOpacity(glow * 0.15),
                        ZapColors.neonBlue.withOpacity(0),
                      ],
                    ),
                  ),
                ),
              ),
              // Inner glow sphere
              Container(
                width: widget.size * 0.72,
                height: widget.size * 0.72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: ZapColors.neonCyan.withOpacity(glow * 0.35),
                      blurRadius: 35,
                      spreadRadius: 6,
                    ),
                    BoxShadow(
                      color: ZapColors.neonBlue.withOpacity(glow * 0.15),
                      blurRadius: 55,
                      spreadRadius: 12,
                    ),
                  ],
                ),
              ),
              // The lightning bolt icon with pulse + shimmer gradient
              Transform.scale(
                scale: pulse,
                child: ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    begin: Alignment(shimmer * 2 - 1, -1),
                    end: Alignment(shimmer * 2, 1),
                    colors: [
                      ZapColors.neonCyan,
                      ZapColors.neonCyanSoft,
                      ZapColors.neonBlue,
                      ZapColors.neonCyan,
                    ],
                  ).createShader(bounds),
                  child: Icon(
                    Icons.flash_on,
                    size: widget.size * 0.48,
                    color: Colors.white,
                  ),
                ),
              ),
              // Orbiting sparkle particles
              ...List.generate(4, (i) {
                double angle = rotate + (i * 2 * math.pi / 4);
                double radius = widget.size * 0.40;
                double particleGlow = (math.sin(rotate * 2.5 + i * 1.2) + 1) / 2;
                double particleSize = 4 + particleGlow * 3;
                return Positioned(
                  left: widget.size / 2 + math.cos(angle) * radius - particleSize / 2,
                  top: widget.size / 2 + math.sin(angle) * radius - particleSize / 2,
                  child: Container(
                    width: particleSize,
                    height: particleSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: ZapColors.neonCyan.withOpacity(particleGlow * 0.9),
                      boxShadow: [
                        BoxShadow(
                          color: ZapColors.neonCyan.withOpacity(particleGlow * 0.5),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }
}

// ══════════════════════════════════════════════════════════════════════
// Small Animated Logo for AppBar
// ══════════════════════════════════════════════════════════════════════

class AnimatedLogoSmall extends StatefulWidget {
  final double size;
  const AnimatedLogoSmall({super.key, this.size = 28});

  @override
  State<AnimatedLogoSmall> createState() => _AnimatedLogoSmallState();
}

class _AnimatedLogoSmallState extends State<AnimatedLogoSmall>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
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
        double glow = 0.5 + (_controller.value * 0.5);
        return Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: ZapColors.neonCyan.withOpacity(glow * 0.4),
                blurRadius: 12,
                spreadRadius: 1,
              ),
            ],
          ),
          child: ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                ZapColors.neonCyan,
                ZapColors.neonCyanSoft,
              ],
            ).createShader(bounds),
            child: Icon(
              Icons.flash_on,
              size: widget.size,
              color: Colors.white,
            ),
          ),
        );
      },
    );
  }
}

// ══════════════════════════════════════════════════════════════════════
// Neon AppBar Builder
// ══════════════════════════════════════════════════════════════════════

PreferredSizeWidget zapAppBar({
  required String title,
  bool showLogo = false,
  List<Widget>? actions,
  Widget? leading,
  bool centerTitle = true,
  PreferredSizeWidget? bottom,
}) {
  return PreferredSize(
    preferredSize: Size.fromHeight(bottom != null ? 100 : 56),
    child: Container(
      decoration: const BoxDecoration(
        gradient: ZapGradients.appBarGradient,
        border: Border(
          bottom: BorderSide(color: ZapColors.dividerColor, width: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x50000000),
            blurRadius: 12,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: centerTitle,
        leading: leading,
        title: showLogo
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const AnimatedLogoSmall(size: 24),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: const TextStyle(
                      color: ZapColors.neonCyan,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              )
            : Text(
                title,
                style: const TextStyle(
                  color: ZapColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
        actions: actions,
        iconTheme: const IconThemeData(color: ZapColors.neonCyan),
        bottom: bottom,
      ),
    ),
  );
}

// ══════════════════════════════════════════════════════════════════════
// Neon Gradient Button
// ══════════════════════════════════════════════════════════════════════

class NeonButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isOutline;
  final bool isLoading;
  final bool isGlassmorphic;
  final IconData? icon;

  const NeonButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isOutline = false,
    this.isLoading = false,
    this.isGlassmorphic = false,
    this.icon,
  });

  @override
  State<NeonButton> createState() => _NeonButtonState();
}

class _NeonButtonState extends State<NeonButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    Widget content = Center(
      child: widget.isLoading
          ? SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: widget.isOutline ? ZapColors.neonCyan : Colors.white,
              ),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.icon != null) ...[
                  Icon(widget.icon, color: widget.isOutline ? ZapColors.neonCyan : Colors.white, size: 20),
                  const SizedBox(width: 8),
                ],
                Text(
                  widget.text,
                  style: TextStyle(
                    color: widget.isOutline ? ZapColors.neonCyan : Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.0,
                  ),
                ),
              ],
            ),
    );

    return GestureDetector(
      onTapDown: widget.isLoading ? null : (_) => setState(() => _isPressed = true),
      onTapUp: widget.isLoading ? null : (_) {
        setState(() => _isPressed = false);
        widget.onPressed();
      },
      onTapCancel: widget.isLoading ? null : () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          height: 52,
          decoration: widget.isGlassmorphic 
              ? BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    if (_isPressed || !widget.isOutline)
                      BoxShadow(
                        color: ZapColors.neonCyan.withValues(alpha: _isPressed ? 0.5 : 0.25),
                        blurRadius: _isPressed ? 20 : 12,
                        spreadRadius: _isPressed ? 2 : 0,
                      ),
                  ],
                )
              : (widget.isOutline ? ZapDecorations.outlineButton : ZapDecorations.glowButton),
          child: widget.isGlassmorphic
              ? Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: widget.isOutline ? 0.08 : 0.20),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: widget.isOutline ? 0.15 : 0.30),
                      width: 1.2,
                    ),
                  ),
                  child: content,
                )
              : content,
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════
// Neon Background Container Wrapper (Login / Register - Deep & Dark)
// ══════════════════════════════════════════════════════════════════════

class NeonBackground extends StatefulWidget {
  final Widget child;
  const NeonBackground({super.key, required this.child});

  @override
  State<NeonBackground> createState() => _NeonBackgroundState();
}

class _NeonBackgroundState extends State<NeonBackground>
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
        Positioned.fill(
          child: AnimatedMeshGradient(
            colors: const [
              Color(0xFF050A18), // Deep Midnight Blue
              Color(0xFF081530), // Dark Navy
              Color(0xFF0A0820), // Deep Purple
              Color(0xFF060D22), // Very Dark Blue
            ],
            options: AnimatedMeshGradientOptions(
              speed: 0.018,
              amplitude: 35.0,
            ),
          ),
        ),
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return CustomPaint(
                painter: _ShootingStarPainter(_controller.value),
              );
            },
          ),
        ),
        Positioned.fill(child: widget.child),
      ],
    );
  }
}

class _ShootingStarPainter extends CustomPainter {
  final double progress;
  _ShootingStarPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final stars = [
      _StarDef(-0.2, 0.1, 1.5, 0.0),
      _StarDef(0.3, -0.2, 1.2, 0.2),
      _StarDef(0.7, -0.4, 1.8, 0.5),
      _StarDef(1.2, 0.2, 2.0, 0.7),
      _StarDef(-0.5, 0.5, 1.3, 0.1),
      _StarDef(0.8, 1.1, 1.7, 0.4),
      _StarDef(1.4, -0.1, 1.1, 0.8),
      _StarDef(-0.1, 0.8, 1.6, 0.9),
    ];

    for (final star in stars) {
      final p = (progress * star.speed + star.offset) % 1.0;
      // Start slightly off screen
      final startX = size.width * star.startXRatio - 100;
      final startY = size.height * star.startYRatio - 100;
      
      final currentX = startX + p * size.width * 1.5;
      final currentY = startY + p * size.height * 1.5;

      // Shorter, sharper tail
      final length = size.width * 0.08;
      final endX = currentX - length;
      final endY = currentY - length;

      final gradientPaint = Paint()
        ..shader = ui.Gradient.linear(
          Offset(currentX, currentY),
          Offset(endX, endY),
          [
            const Color(0xFFFFFFFF), // Bright white head
            const Color(0xFF00E5FF).withValues(alpha: 0.5), // Bright cyan tail
          ],
        )
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round;

      canvas.drawLine(Offset(endX, endY), Offset(currentX, currentY), gradientPaint);
    }
  }

  @override
  bool shouldRepaint(_ShootingStarPainter old) => old.progress != progress;
}

class _StarDef {
  final double startXRatio;
  final double startYRatio;
  final double speed;
  final double offset;
  const _StarDef(this.startXRatio, this.startYRatio, this.speed, this.offset);
}

// ══════════════════════════════════════════════════════════════════════
// Home Background — Dark Mesh with Subtle Network Nodes (No Stars)
// ══════════════════════════════════════════════════════════════════════

class HomeBackground extends StatefulWidget {
  final Widget child;
  const HomeBackground({super.key, required this.child});

  @override
  State<HomeBackground> createState() => _HomeBackgroundState();
}

class _HomeBackgroundState extends State<HomeBackground>
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
    return Stack(
      children: [
        Positioned.fill(
          child: AnimatedMeshGradient(
            colors: const [
              Color(0xFF060A1A), // Very deep dark blue
              Color(0xFF08102A), // Dark navy
              Color(0xFF0A0818), // Deep space
              Color(0xFF050E22), // Deepest blue
            ],
            options: AnimatedMeshGradientOptions(
              speed: 0.01, // Must be >= 0.01
              amplitude: 20.0,
            ),
          ),
        ),
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return CustomPaint(
                painter: _NetworkNodePainter(_controller.value),
              );
            },
          ),
        ),
        Positioned.fill(child: widget.child),
      ],
    );
  }
}

class _NetworkNodePainter extends CustomPainter {
  final double progress;
  _NetworkNodePainter(this.progress);

  static const _nodes = [
    Offset(0.05, 0.12), Offset(0.25, 0.05), Offset(0.55, 0.08),
    Offset(0.85, 0.15), Offset(0.95, 0.35), Offset(0.78, 0.52),
    Offset(0.90, 0.72), Offset(0.65, 0.88), Offset(0.38, 0.92),
    Offset(0.12, 0.80), Offset(0.02, 0.55), Offset(0.18, 0.35),
    Offset(0.42, 0.22), Offset(0.68, 0.30), Offset(0.50, 0.55),
    Offset(0.30, 0.68),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = const Color(0xFF00E5FF).withValues(alpha: 0.06)
      ..strokeWidth = 0.8
      ..strokeCap = StrokeCap.round;

    final nodePaint = Paint()
      ..color = const Color(0xFF00E5FF).withValues(alpha: 0.12);

    // Animate a gentle pulse on the nodes
    final double pulse = 0.5 + 0.5 * math.sin(progress * 2 * math.pi);

    // Draw connecting lines
    for (int i = 0; i < _nodes.length; i++) {
      for (int j = i + 1; j < _nodes.length; j++) {
        final a = Offset(_nodes[i].dx * size.width, _nodes[i].dy * size.height);
        final b = Offset(_nodes[j].dx * size.width, _nodes[j].dy * size.height);
        final dist = (a - b).distance;
        if (dist < size.width * 0.38) {
          final alpha = (1 - dist / (size.width * 0.38)) * 0.07;
          canvas.drawLine(a, b, linePaint..color = Color(0xFF00E5FF).withValues(alpha: alpha));
        }
      }
    }

    // Draw nodes
    for (int i = 0; i < _nodes.length; i++) {
      final pos = Offset(_nodes[i].dx * size.width, _nodes[i].dy * size.height);
      final animatedPulse = (i % 3 == 0) ? pulse : (i % 3 == 1) ? (1 - pulse) : 0.5;
      final r = 2.0 + animatedPulse * 1.5;
      canvas.drawCircle(pos, r, nodePaint..color = const Color(0xFF00E5FF).withValues(alpha: 0.15 + animatedPulse * 0.10));
    }
  }

  @override
  bool shouldRepaint(_NetworkNodePainter old) => old.progress != progress;
}

// ══════════════════════════════════════════════════════════════════════
// Welcome Background — Water Stream Turquoise Glow Effect
// ══════════════════════════════════════════════════════════════════════

class WelcomeBackground extends StatefulWidget {
  final Widget child;
  const WelcomeBackground({super.key, required this.child});

  @override
  State<WelcomeBackground> createState() => _WelcomeBackgroundState();
}

class _WelcomeBackgroundState extends State<WelcomeBackground>
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
    return Stack(
      children: [
        // Dark base
        Positioned.fill(
          child: Container(color: const Color(0xFF040C1A)),
        ),
        // Animated water stream painter
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return CustomPaint(
                painter: _WaterStreamPainter(_controller.value),
              );
            },
          ),
        ),
        // Glow shimmer layer over streams
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return CustomPaint(
                painter: _GlowShimmerPainter(_controller.value),
              );
            },
          ),
        ),
        Positioned.fill(child: widget.child),
      ],
    );
  }
}

// Paints sinusoidal flowing water streams in deep navy/indigo/turquoise
class _WaterStreamPainter extends CustomPainter {
  final double progress;
  _WaterStreamPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final t = progress * 2 * math.pi;
    final h = size.height;

    // Stream definitions: [baseY ratio, amplitude, frequency, speed phase, colors]
    final streams = [
      _StreamDef(0.20, h * 0.07, 1.2, t * 0.9,  [const Color(0xFF040C1A), const Color(0xFF081A33)]),
      _StreamDef(0.35, h * 0.10, 0.9, t * 1.1,  [const Color(0xFF06142A), const Color(0xFF0A2240)]),
      _StreamDef(0.50, h * 0.13, 1.5, t * 0.75, [const Color(0xFF051830), const Color(0xFF0C2B52), const Color(0xFF008AA0)]),
      _StreamDef(0.65, h * 0.11, 1.0, t * 1.3,  [const Color(0xFF041020), const Color(0xFF071C38), const Color(0xFF00758C)]),
      _StreamDef(0.78, h * 0.08, 1.3, t * 0.85, [const Color(0xFF040C1A), const Color(0xFF081A33)]),
    ];

    for (final stream in streams) {
      _drawStream(canvas, size, stream, t);
    }
  }

  void _drawStream(Canvas canvas, Size size, _StreamDef stream, double t) {
    final path = Path();
    final baseY = size.height * stream.baseYRatio;
    final steps = 120;

    // Top edge of stream
    path.moveTo(0, baseY - stream.amplitude);
    for (int i = 0; i <= steps; i++) {
      final x = size.width * i / steps;
      final phase = (x / size.width) * stream.frequency * 2 * math.pi;
      final y = baseY - stream.amplitude + math.sin(phase + stream.timePhase) * stream.amplitude * 0.5;
      path.lineTo(x, y);
    }
    // Bottom edge of stream (reverse)
    for (int i = steps; i >= 0; i--) {
      final x = size.width * i / steps;
      final phase = (x / size.width) * stream.frequency * 2 * math.pi;
      final y = baseY + stream.amplitude + math.cos(phase + stream.timePhase + 1.0) * stream.amplitude * 0.4;
      path.lineTo(x, y);
    }
    path.close();

    final gradient = LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: stream.colors,
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final paint = Paint()
      ..shader = gradient
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_WaterStreamPainter old) => old.progress != progress;
}

// Paints bright glowing turquoise highlights orbiting the logo/title area
class _GlowShimmerPainter extends CustomPainter {
  final double progress;
  _GlowShimmerPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final t = progress * 2 * math.pi;
    final centerX = size.width * 0.5;
    final centerY = size.height * 0.35; // Approximate center of Logo + Title
    
    // Orbital radii (elliptical to fit screen nicely)
    final radiusX = size.width * 0.42;
    final radiusY = size.height * 0.22;

    final glowOrbits = [
      _OrbitalDef(t, 1.0, 0.0), // orb 1
      _OrbitalDef(t * 1.1, 0.85, math.pi * 2 / 3), // orb 2
      _OrbitalDef(t * 0.9, 1.15, math.pi * 4 / 3), // orb 3
    ];

    for (final orb in glowOrbits) {
      final angle = orb.timePhase + orb.offsetPhase;
      final cx = centerX + math.cos(angle) * (radiusX * orb.radiusMultiplier);
      final cy = centerY + math.sin(angle) * (radiusY * orb.radiusMultiplier);
      
      final pulse = 0.5 + 0.5 * math.sin(orb.timePhase * 3 + orb.offsetPhase);
      final radius = size.width * (0.08 + pulse * 0.04);

      final paint = Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFF00E5FF).withValues(alpha: 0.15 + pulse * 0.10),
            const Color(0xFF00B4CC).withValues(alpha: 0.05 + pulse * 0.05),
            Colors.transparent,
          ],
          stops: const [0.0, 0.45, 1.0],
        ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: radius))
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 12 + pulse * 8);
      canvas.drawCircle(Offset(cx, cy), radius, paint);
    }
  }

  @override
  bool shouldRepaint(_GlowShimmerPainter old) => old.progress != progress;
}

class _StreamDef {
  final double baseYRatio;
  final double amplitude;
  final double frequency;
  final double timePhase;
  final List<Color> colors;
  const _StreamDef(this.baseYRatio, this.amplitude, this.frequency, this.timePhase, this.colors);
}

class _OrbitalDef {
  final double timePhase;
  final double radiusMultiplier;
  final double offsetPhase;
  const _OrbitalDef(this.timePhase, this.radiusMultiplier, this.offsetPhase);
}

// ══════════════════════════════════════════════════════════════════════
// Reusable Hero Gradient Text (Welcome/Login/Signup)
// ══════════════════════════════════════════════════════════════════════

class HeroGradientText extends StatelessWidget {
  final String text;
  final double fontSize;
  final bool animate;

  const HeroGradientText({
    super.key,
    required this.text,
    this.fontSize = 52.0,
    this.animate = false,
  });

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFFFFFFFF),
          Color(0xFF80DEEA),
          Color(0xFF00E5FF),
        ],
        stops: [0.0, 0.5, 1.0],
      ).createShader(bounds),
      child: animate 
        ? AnimatedTextKit(
            animatedTexts: [
              TypewriterAnimatedText(
                text,
                textStyle: _getTextStyle(),
                speed: const Duration(milliseconds: 110),
              ),
            ],
            isRepeatingAnimation: false,
          )
        : Text(
            text,
            style: _getTextStyle(),
          ),
    );
  }

  TextStyle _getTextStyle() {
    return TextStyle(
      fontSize: fontSize,
      fontWeight: FontWeight.w900,
      color: Colors.white,
      letterSpacing: 3.0,
      shadows: const [
        Shadow(
          color: Color(0x9900E5FF),
          blurRadius: 24,
          offset: Offset(0, 0),
        ),
        Shadow(
          color: Color(0x5500B4CC),
          blurRadius: 40,
          offset: Offset(0, 4),
        ),
      ],
    );
  }
}


// ══════════════════════════════════════════════════════════════════════
// Chat Background — Animated Dark Hexagonal Grid (like the image)
// ══════════════════════════════════════════════════════════════════════

// ── Static depth-mapped hex background ──────────────────────────────
// Completely static — no AnimationController, no repaint overhead.
// The hex grid uses a depth map (distance from center) to drive subtle
// glow, giving a 3-D receding-tunnel feel without any movement.
class ChatBackground extends StatelessWidget {
  final Widget child;
  const ChatBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Ultra-dark charcoal-navy base
        Positioned.fill(child: Container(color: const Color(0xFF050C14))),
        // Static hex grid
        Positioned.fill(
          child: CustomPaint(painter: _StaticHexPainter()),
        ),
        // Radial vignette — darkens corners, keeps centre slightly visible
        Positioned.fill(
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.25,
                  colors: [
                    Colors.transparent,
                    const Color(0xFF020810).withValues(alpha: 0.72),
                  ],
                ),
              ),
            ),
          ),
        ),
        Positioned.fill(child: child),
      ],
    );
  }
}

class _StaticHexPainter extends CustomPainter {
  _StaticHexPainter();

  // Pointy-top hex: vertex 0 is at the top
  Path _hexPath(double cx, double cy, double r) {
    final path = Path();
    for (int i = 0; i < 6; i++) {
      final angle = (math.pi / 3) * i - math.pi / 2;
      final x = cx + r * math.cos(angle);
      final y = cy + r * math.sin(angle);
      i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
    }
    path.close();
    return path;
  }

  @override
  void paint(Canvas canvas, Size size) {
    const double hexR   = 34.0;  // circumradius — keeps hexes compact & crisp
    const double gap    = 3.0;   // gap between hexes in pixels
    final double innerR = hexR - gap;

    // Pointy-top grid spacing
    final double colW  = hexR * math.sqrt(3);   // horizontal distance between centers
    final double rowH  = hexR * 1.5;            // vertical distance between row centers

    final int cols = (size.width  / colW).ceil()  + 2;
    final int rows = (size.height / rowH).ceil()  + 2;

    // Canvas centre — used for depth mapping
    final double cx0 = size.width  / 2;
    final double cy0 = size.height / 2;
    // Max distance from centre to corner
    final double maxDist = math.sqrt(cx0 * cx0 + cy0 * cy0);

    // Shared paints — reused and mutated per hex for performance
    final fillPaint   = Paint()..style = PaintingStyle.fill;
    final strokePaint = Paint()..style = PaintingStyle.stroke..strokeWidth = 0.8;

    for (int row = -1; row <= rows; row++) {
      for (int col = -1; col <= cols; col++) {
        // Pointy-top hex centres: odd cols offset vertically
        final double cx = col * colW + (row.isOdd ? colW / 2 : 0.0);
        final double cy = row * rowH;

        // Depth: 0 = centre, 1 = corner
        final double dist = math.sqrt(
          math.pow(cx - cx0, 2) + math.pow(cy - cy0, 2),
        );
        final double depth = (dist / maxDist).clamp(0.0, 1.0);
        // Invert so centre = 1 (bright), edge = 0 (dark)
        final double brightness = 1.0 - depth;

        // Fill: barely-there deep navy that lightens towards centre
        //   deep edge ~ 0x050C14, mild centre ~ 0x0C1E2E
        final int rVal = (5  + (brightness * 7).round());
        final int gVal = (12 + (brightness * 18).round());
        final int bVal = (20 + (brightness * 26).round());
        fillPaint.color = Color.fromARGB(255, rVal, gVal, bVal);
        canvas.drawPath(_hexPath(cx, cy, innerR), fillPaint);

        // Stroke: dark steel-teal, brighter near centre
        //   edges: barely visible 0x0A1E2A @ 60% opacity
        //   centre: 0x1E4A5C @ 80% opacity with a hint of cyan
        final double strokeAlpha = 0.45 + brightness * 0.35;
        final int sr = (10  + (brightness * 20).round());
        final int sg = (30  + (brightness * 44).round());
        final int sb = (42  + (brightness * 48).round());
        strokePaint.color = Color.fromARGB(
          (strokeAlpha * 255).round(), sr, sg, sb);
        canvas.drawPath(_hexPath(cx, cy, innerR), strokePaint);
      }
    }
  }

  // Completely static — never repaint
  @override
  bool shouldRepaint(_StaticHexPainter old) => false;
}

// ══════════════════════════════════════════════════════════════════════
// Section Header Widget
// ══════════════════════════════════════════════════════════════════════

class SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  const SectionHeader({super.key, required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        gradient: ZapGradients.sectionHeaderGradient,
        border: Border(
          bottom: BorderSide(color: ZapColors.dividerColor, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: ZapColors.neonCyan, size: 16),
          const SizedBox(width: 8),
          Text(
            title,
            style: ZapTextStyles.sectionLabel,
          ),
        ],
      ),
    );
  }
}
