import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utilities/neon_theme.dart';
import '../widgets/message_bubble.dart';
import '../providers/auth_provider.dart';
import '../providers/user_provider.dart';

final _firestore = FirebaseFirestore.instance;

class ChatScreen extends ConsumerStatefulWidget {
  final String chatId;
  final String chatTitle;
  final String? chatPic;

  const ChatScreen({super.key, required this.chatId, required this.chatTitle, this.chatPic});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final messageTextController = TextEditingController();
  String? messageText;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: zapAppBar(
        title: widget.chatTitle,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: ZapColors.neonCyan, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          GestureDetector(
            onTap: () {
              String myId = ref.read(currentUserIdProvider);
              String friendId = widget.chatId.split('_').firstWhere((id) => id != myId, orElse: () => '');
              if (friendId.isNotEmpty) {
                _showProfileOptions(context, friendId);
              }
            },
            child: Padding(
              padding: const EdgeInsets.only(right: 12),
              child: CircleAvatar(
                radius: 18,
                backgroundColor: ZapColors.accentPurple,
                backgroundImage: (widget.chatPic != null && widget.chatPic!.isNotEmpty)
                    ? NetworkImage(widget.chatPic!)
                    : null,
                child: (widget.chatPic == null || widget.chatPic!.isEmpty)
                    ? Text(
                        widget.chatTitle.isNotEmpty
                            ? widget.chatTitle[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                            color: ZapColors.neonCyan,
                            fontWeight: FontWeight.w700,
                            fontSize: 16),
                      )
                    : null,
              ),
            ),
          ),
        ],
      ),
      body: ChatBackground(
        child: Column(
          children: [
            MessageStream(chatId: widget.chatId, chatPic: widget.chatPic),
            // Input area — dark glassy bar matching the hex theme
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF060B14).withValues(alpha: 0.92),
                border: Border(
                  top: BorderSide(
                      color: ZapColors.neonCyan.withValues(alpha: 0.12),
                      width: 0.8),
                ),
              ),
              child: SafeArea(
                top: false,
                child: Row(
                  children: [
                    // Attach button
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: Colors.white.withValues(alpha: 0.10)),
                      ),
                      child: const Icon(Icons.attach_file_rounded,
                          color: ZapColors.textMuted, size: 20),
                    ),
                    const SizedBox(width: 10),
                    // Text input pill
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.07),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: ZapColors.neonCyan.withValues(alpha: 0.18),
                            width: 1.0,
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: messageTextController,
                                onChanged: (v) => messageText = v,
                                style: const TextStyle(
                                    color: ZapColors.textPrimary, fontSize: 14),
                                cursorColor: ZapColors.neonCyan,
                                decoration: const InputDecoration(
                                  hintText: 'Type your message here...',
                                  hintStyle: TextStyle(
                                      color: ZapColors.textMuted, fontSize: 13),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 10),
                                ),
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.only(right: 10),
                              child: Icon(Icons.emoji_emotions_outlined,
                                  color: ZapColors.textMuted, size: 22),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Send button — glowing orb
                    GestureDetector(
                      onTap: () {
                        if (messageText != null &&
                            messageText!.trim().isNotEmpty) {
                          messageTextController.clear();
                          _firestore
                              .collection('chats')
                              .doc(widget.chatId)
                              .collection('messages')
                              .add({
                            'text': messageText,
                            'sender': ref.read(currentUserProvider)?.email,
                            'timestamp': FieldValue.serverTimestamp(),
                          });
                          messageText = null;
                        }
                      },
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const RadialGradient(
                            colors: [Color(0xFF00E5FF), Color(0xFF0050B0)],
                            center: Alignment(-0.3, -0.3),
                            radius: 1.1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: ZapColors.neonCyan.withValues(alpha: 0.45),
                              blurRadius: 14,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: const Icon(Icons.send_rounded,
                            color: Colors.white, size: 20),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showProfileOptions(BuildContext context, String friendId) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: ZapColors.darkPurple,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(widget.chatTitle, style: const TextStyle(color: ZapColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.person_remove_rounded, color: ZapColors.warningOrange),
                title: const Text('Remove Friend', style: TextStyle(color: ZapColors.warningOrange)),
                onTap: () {
                  Navigator.pop(ctx);
                  _removeFriend(friendId);
                },
              ),
              ListTile(
                leading: const Icon(Icons.block_rounded, color: ZapColors.errorRed),
                title: const Text('Block User', style: TextStyle(color: ZapColors.errorRed)),
                onTap: () {
                  Navigator.pop(ctx);
                  _blockUser(friendId);
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      }
    );
  }

  void _removeFriend(String friendId) async {
    String myId = ref.read(currentUserIdProvider);
    await _firestore.collection('users').doc(myId).update({
      'friends': FieldValue.arrayRemove([friendId])
    });
    await _firestore.collection('users').doc(friendId).update({
      'friends': FieldValue.arrayRemove([myId])
    });
    var messages = await _firestore.collection('chats').doc(widget.chatId).collection('messages').get();
    for (var doc in messages.docs) {
      await doc.reference.delete();
    }
    await _firestore.collection('chats').doc(widget.chatId).delete();
    if (mounted) Navigator.pop(context);
  }

  void _blockUser(String friendId) async {
    _removeFriend(friendId);
    String myId = ref.read(currentUserIdProvider);
    await _firestore.collection('users').doc(myId).update({
      'blockedUsers': FieldValue.arrayUnion([friendId])
    });
  }
}

class MessageStream extends ConsumerWidget {
  final String chatId;
  final String? chatPic;
  const MessageStream({super.key, required this.chatId, this.chatPic});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    final messagesAsync = ref.watch(chatMessagesProvider(chatId));

    return messagesAsync.when(
      loading: () => const Expanded(
          child: Center(
              child: CircularProgressIndicator(color: ZapColors.neonCyan))),
      error: (_, __) => const Expanded(child: SizedBox()),
      data: (messages) {
        return Expanded(
          child: ListView.builder(
            reverse: true,
            padding: const EdgeInsets.symmetric(vertical: 12),
            itemCount: messages.length,
            itemBuilder: (context, index) {
              final msg = messages[index];
              final sender = msg['sender'];
              final isMe = currentUser?.email == sender;
              return MessageBubble(
                sender: sender,
                text: msg['text'],
                isMe: isMe,
                avatarUrl: isMe ? null : chatPic,
              );
            },
          ),
        );
      },
    );
  }
}
