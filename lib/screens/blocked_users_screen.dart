import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utilities/neon_theme.dart';
import '../providers/user_provider.dart';

// ConsumerStatefulWidget so we can call ref.read() in unblock action.
class BlockedUsersScreen extends ConsumerWidget {
  const BlockedUsersScreen({super.key});

  Future<void> _unblockUser(String blockedUserId, WidgetRef ref) async {
    final myId = FirebaseAuth.instance.currentUser!.uid;
    await FirebaseFirestore.instance.collection('users').doc(myId).update({
      'blockedUsers': FieldValue.arrayRemove([blockedUserId])
    });
    // No setState needed — myBlockedUsersProvider will emit a new value
    // automatically because it derives from the live Firestore stream.
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Reuses the already-open Firestore stream from myUserDataProvider.
    // Zero extra Firestore connections compared to the old StreamBuilder approach.
    final blockedUsers = ref.watch(myBlockedUsersProvider);

    return Scaffold(
      backgroundColor: ZapColors.deepPurple,
      appBar: zapAppBar(title: 'Blocked Users', centerTitle: true),
      body: HomeBackground(
        child: blockedUsers.isEmpty
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.shield_rounded,
                        color: ZapColors.textMuted.withValues(alpha: 0.5),
                        size: 64),
                    const SizedBox(height: 16),
                    const Text('No blocked users',
                        style: TextStyle(color: ZapColors.textMuted, fontSize: 16)),
                  ],
                ),
              )
            : ListView.builder(
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
                itemCount: blockedUsers.length,
                itemBuilder: (context, index) {
                  final String blockedId = blockedUsers[index];
                  return FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance
                        .collection('users')
                        .doc(blockedId)
                        .get(),
                    builder: (context, userSnap) {
                      if (!userSnap.hasData) return const SizedBox();
                      final userData =
                          userSnap.data!.data() as Map<String, dynamic>?;
                      if (userData == null) return const SizedBox();

                      final String username =
                          userData['username'] ?? 'Unknown User';
                      final String pic = userData['profilePicUrl'] ?? '';

                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.04),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color: Colors.white.withValues(alpha: 0.08)),
                        ),
                        child: Row(
                          children: [
                            _avatarWidget(pic, username),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Text(
                                username,
                                style: const TextStyle(
                                  color: ZapColors.textPrimary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => _unblockUser(blockedId, ref),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color:
                                      ZapColors.neonCyan.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                      color: ZapColors.neonCyan
                                          .withValues(alpha: 0.3)),
                                ),
                                child: const Text(
                                  'Unblock',
                                  style: TextStyle(
                                    color: ZapColors.neonCyan,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
      ),
    );
  }

  Widget _avatarWidget(String pic, String name) {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: ZapColors.errorRed.withValues(alpha: 0.3), width: 1.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: pic.isNotEmpty
          ? Image.network(pic,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _fallbackAvatar(name))
          : _fallbackAvatar(name),
    );
  }

  Widget _fallbackAvatar(String name) {
    return Container(
      color: ZapColors.errorRed.withValues(alpha: 0.15),
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : '?',
          style: const TextStyle(
              color: ZapColors.errorRed,
              fontWeight: FontWeight.w800,
              fontSize: 18),
        ),
      ),
    );
  }
}
