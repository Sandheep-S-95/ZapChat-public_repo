import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utilities/neon_theme.dart';
import '../widgets/message_bubble.dart';
import '../providers/user_provider.dart';
import '../providers/auth_provider.dart';
import 'group_info_screen.dart';

class GroupChatScreen extends ConsumerStatefulWidget {
  final String groupId;
  final String groupName;

  const GroupChatScreen({super.key, required this.groupId, required this.groupName});

  @override
  ConsumerState<GroupChatScreen> createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends ConsumerState<GroupChatScreen> {
  final _firestore = FirebaseFirestore.instance;
  final messageTextController = TextEditingController();
  String? messageText;

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);
    final String myEmail = currentUser?.email ?? '';

    return Scaffold(
      appBar: zapAppBar(
        title: widget.groupName,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: ZapColors.neonCyan, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline_rounded, color: ZapColors.neonCyan),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(
                builder: (context) => GroupInfoScreen(groupId: widget.groupId, groupName: widget.groupName),
              ));
            },
          ),
        ],
      ),
      body: ChatBackground(
        child: Column(
          children: [
            Expanded(
              child: Consumer(builder: (context, ref, _) {
                final messagesAsync = ref.watch(groupMessagesProvider(widget.groupId));
                return messagesAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator(color: ZapColors.neonCyan)),
                  error: (_, __) => const SizedBox(),
                  data: (messages) => ListView.builder(
                    reverse: true,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final msg = messages[index];
                      final bool isMe = msg['sender'] == myEmail;
                      return MessageBubble(sender: msg['sender'], text: msg['text'], isMe: isMe);
                    },
                  ),
                );
              }),
            ),
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
                      child: const Icon(Icons.attach_file_rounded, color: ZapColors.textMuted, size: 20),
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
                                onChanged: (val) => messageText = val,
                                style: const TextStyle(color: ZapColors.textPrimary, fontSize: 14),
                                cursorColor: ZapColors.neonCyan,
                                decoration: const InputDecoration(
                                  hintText: 'Type your message here...',
                                  hintStyle: TextStyle(color: ZapColors.textMuted, fontSize: 13),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                ),
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.only(right: 10),
                              child: Icon(Icons.emoji_emotions_outlined, color: ZapColors.textMuted, size: 22),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Send button — glowing orb
                    GestureDetector(
                      onTap: () {
                        if (messageText != null && messageText!.trim().isNotEmpty) {
                          messageTextController.clear();
                          _firestore.collection('groups').doc(widget.groupId).collection('messages').add({
                            'text': messageText,
                            'sender': myEmail,
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
                        child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
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
}