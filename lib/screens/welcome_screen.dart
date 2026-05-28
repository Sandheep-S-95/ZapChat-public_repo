import 'package:flutter/material.dart';
import 'package:flash_chat/utilities/neon_theme.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  AnimationController? controller;
  Animation? animation;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    animation = CurvedAnimation(
      parent: controller!,
      curve: Curves.easeOutCubic,
    );

    controller!.forward();

    controller!.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WelcomeBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              children: [
                const Spacer(flex: 2),
                // Animated Lightning Logo
                Opacity(
                  opacity: animation!.value.clamp(0.0, 1.0),
                  child: Transform.scale(
                    scale: (0.6 + animation!.value * 0.4).clamp(0.0, 1.0),
                    child: const AnimatedLightningLogo(size: 140),
                  ),
                ),
                const SizedBox(height: 32),

                // Hero gradient title
                const HeroGradientText(
                  text: 'ZapChat',
                  animate: true,
                ),

                const SizedBox(height: 10),

                // Subtitle with glow + divider line
                AnimatedOpacity(
                  opacity: (animation!.value * 2).clamp(0.0, 1.0),
                  duration: const Duration(milliseconds: 600),
                  child: Column(
                    children: [
                      const Text(
                        'Connect Instantly',
                        style: TextStyle(
                          color: Color(0xFF80DEEA),
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 3.5,
                          shadows: [
                            Shadow(
                              color: Color(0x8800E5FF),
                              blurRadius: 12,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: 60,
                        height: 1.5,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Colors.transparent,
                              Color(0xFF00E5FF),
                              Colors.transparent,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(2),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF00E5FF).withValues(alpha: 0.5),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(flex: 3),

                // Buttons
                NeonButton(
                  text: 'Log In',
                  onPressed: () => Navigator.pushNamed(context, '/login'),
                ),
                const SizedBox(height: 14),
                NeonButton(
                  text: 'Register',
                  isGlassmorphic: true,
                  isOutline: true,
                  onPressed: () => Navigator.pushNamed(context, '/register'),
                ),
                const SizedBox(height: 48),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
