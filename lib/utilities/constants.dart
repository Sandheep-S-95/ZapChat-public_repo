import 'package:flutter/material.dart';
import 'neon_theme.dart';

const kSendButtonTextStyle = TextStyle(
  color: ZapColors.neonCyan,
  fontWeight: FontWeight.bold,
  fontSize: 18.0,
);

const kMessageTextFieldDecoration = InputDecoration(
  contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
  hintText: 'Type your message here...',
  hintStyle: TextStyle(color: ZapColors.textMuted, fontSize: 14),
  border: InputBorder.none,
);

const kMessageContainerDecoration = BoxDecoration(
  border: Border(
    top: BorderSide(color: ZapColors.dividerColor, width: 1.0),
  ),
);

const kTextFieldDecoration = InputDecoration(
  hintText: 'Enter a value',
  hintStyle: TextStyle(color: ZapColors.textMuted),
  contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(14.0)),
  ),
  enabledBorder: OutlineInputBorder(
    borderSide: BorderSide(color: ZapColors.neonCyan, width: 1.0),
    borderRadius: BorderRadius.all(Radius.circular(14.0)),
  ),
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(color: ZapColors.neonCyan, width: 2.0),
    borderRadius: BorderRadius.all(Radius.circular(14.0)),
  ),
);