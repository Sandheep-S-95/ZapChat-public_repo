import 'package:flutter/material.dart';
import '../utilities/neon_theme.dart';

class TextBox extends StatelessWidget {
  const TextBox({super.key, required this.boxColor, required this.content, required this.func});
  final Color boxColor;
  final String content;
  final VoidCallback func;

  @override
  Widget build(BuildContext context) {
    final bool isPrimary = boxColor == ZapColors.neonCyan || 
                           boxColor == Colors.lightBlueAccent;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: GestureDetector(
        onTap: func,
        child: Container(
          width: double.infinity,
          height: 52,
          decoration: isPrimary
              ? ZapDecorations.glowButton
              : ZapDecorations.outlineButton,
          child: Center(
            child: Text(
              content,
              style: TextStyle(
                color: isPrimary ? Colors.white : ZapColors.neonCyan,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.0,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
