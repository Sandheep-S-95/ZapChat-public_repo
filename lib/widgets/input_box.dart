import 'package:flutter/material.dart';
import '../utilities/neon_theme.dart';

class InputBox extends StatefulWidget {
  const InputBox({super.key, required this.placeholderContent, required this.varStore});
  final String placeholderContent;
  final void Function(String) varStore;

  @override
  State<InputBox> createState() => _InputBoxState();
}

class _InputBoxState extends State<InputBox> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    final bool isPassword = widget.placeholderContent.toLowerCase().contains('password');
    final bool isEmail = widget.placeholderContent.toLowerCase().contains('email');

    IconData leadingIcon = Icons.person_outline;
    if (isEmail) leadingIcon = Icons.email_outlined;
    if (isPassword) leadingIcon = Icons.lock_outline;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.15),
          width: 1.2,
        ),
      ),
      child: TextField(
        obscureText: isPassword ? _obscure : false,
        keyboardType: isEmail ? TextInputType.emailAddress : TextInputType.text,
        onChanged: widget.varStore,
        style: const TextStyle(color: ZapColors.textPrimary, fontSize: 14),
        cursorColor: ZapColors.neonCyan,
        decoration: ZapDecorations.neonInputDecoration(
          hint: widget.placeholderContent,
          icon: leadingIcon,
          isPassword: isPassword,
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    _obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    color: ZapColors.textMuted,
                    size: 20,
                  ),
                  onPressed: () => setState(() => _obscure = !_obscure),
                )
              : null,
        ).copyWith(
          // Remove the internal background color and borders since the container handles it
          fillColor: Colors.transparent,
          filled: true,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: ZapColors.neonCyan, width: 1.5),
          ),
        ),
      ),
    );
  }
}
