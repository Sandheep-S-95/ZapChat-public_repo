import 'package:flutter/material.dart';
import 'dart:ui' as ui;

class MessageBubble extends StatelessWidget {
  const MessageBubble({
    super.key,
    required this.sender,
    required this.text,
    required this.isMe,
    this.avatarUrl,
  });

  final String sender;
  final String text;
  final bool isMe;
  final String? avatarUrl;

  // Derives a short display name or first letter for the avatar
  String get _displayName {
    final parts = sender.split('@');
    return parts.isNotEmpty ? parts[0] : sender;
  }

  String get _initial => _displayName.isNotEmpty
      ? _displayName[0].toUpperCase()
      : '?';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: isMe ? 60 : 12,
        right: isMe ? 12 : 60,
        top: 3,
        bottom: 3,
      ),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          // Sender label
          Padding(
            padding: EdgeInsets.only(
              bottom: 4,
              left: isMe ? 0 : 44,
              right: isMe ? 4 : 0,
            ),
            child: Text(
              _displayName,
              style: const TextStyle(
                color: Color(0xFF5E8099),
                fontSize: 11,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.3,
              ),
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment:
                isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              // Avatar (only for other user)
              if (!isMe) ...[
                _Avatar(initial: _initial, avatarUrl: avatarUrl),
                const SizedBox(width: 8),
              ],
              // Bubble
              Flexible(
                child: isMe ? _MeBubble(text: text) : _OtherBubble(text: text),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Avatar for received messages ─────────────────────────────────────
class _Avatar extends StatelessWidget {
  final String initial;
  final String? avatarUrl;
  const _Avatar({required this.initial, this.avatarUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [Color(0xFF1E3A4A), Color(0xFF0E1E2A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        image: (avatarUrl != null && avatarUrl!.isNotEmpty)
            ? DecorationImage(
                image: NetworkImage(avatarUrl!),
                fit: BoxFit.cover,
              )
            : null,
        border: Border.all(
          color: const Color(0xFF1E4055).withValues(alpha: 0.9),
          width: 1.2,
        ),
      ),
      child: (avatarUrl == null || avatarUrl!.isEmpty)
          ? Center(
              child: Text(
                initial,
                style: const TextStyle(
                  color: Color(0xFF80C8E0),
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            )
          : null,
    );
  }
}

// ── "Their" bubble — glassy frosted dark ──────────────────────────────
class _OtherBubble extends StatelessWidget {
  final String text;
  const _OtherBubble({required this.text});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(4),
        topRight: Radius.circular(20),
        bottomLeft: Radius.circular(20),
        bottomRight: Radius.circular(20),
      ),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          decoration: BoxDecoration(
            // Very dark glassy teal-navy
            color: const Color(0xFF0C1B26).withValues(alpha: 0.82),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(20),
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
            border: Border.all(
              color: const Color(0xFF1A3D52).withValues(alpha: 0.75),
              width: 1.0,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x28000000),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Text(
            text,
            style: const TextStyle(
              color: Color(0xFFDDEEF5),
              fontSize: 14.5,
              height: 1.35,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}

// ── "My" bubble — vivid gradient with glow ────────────────────────────
class _MeBubble extends StatelessWidget {
  final String text;
  const _MeBubble({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      decoration: BoxDecoration(
        // Cyan → electric-blue gradient (matches image)
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF00C8E0),
            Color(0xFF007FCC),
          ],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(4),
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        boxShadow: [
          // Cyan glow under the bubble
          BoxShadow(
            color: const Color(0xFF00C8E0).withValues(alpha: 0.28),
            blurRadius: 16,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
          const BoxShadow(
            color: Color(0x40000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14.5,
          height: 1.35,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
