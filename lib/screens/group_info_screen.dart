import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utilities/neon_theme.dart';

class GroupInfoScreen extends StatefulWidget {
  final String groupId;
  final String groupName;

  const GroupInfoScreen({super.key, required this.groupId, required this.groupName});

  @override
  _GroupInfoScreenState createState() => _GroupInfoScreenState();
}

class _GroupInfoScreenState extends State<GroupInfoScreen> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  void leaveGroup() async {
    String myId = _auth.currentUser!.uid;
    await _firestore.collection('groups').doc(widget.groupId).update({
      'members': FieldValue.arrayRemove([myId]),
      'admins': FieldValue.arrayRemove([myId])
    });
    await _firestore.collection('users').doc(myId).update({
      'groups': FieldValue.arrayRemove([widget.groupId])
    });
    Navigator.pop(context);
    Navigator.pop(context);
  }

  void manageUserOptions(BuildContext context, String memberId, String memberName, bool isAdmin, bool isTargetAlreadyAdmin) {
    if (!isAdmin) return;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: ZapColors.darkPurple,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text("Manage $memberName", style: const TextStyle(color: ZapColors.textPrimary)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(isTargetAlreadyAdmin ? Icons.remove_moderator : Icons.add_moderator, color: ZapColors.neonCyan),
                title: Text(isTargetAlreadyAdmin ? "Revoke Admin" : "Make Admin", style: const TextStyle(color: ZapColors.textPrimary)),
                onTap: () {
                  _firestore.collection('groups').doc(widget.groupId).update({
                    'admins': isTargetAlreadyAdmin ? FieldValue.arrayRemove([memberId]) : FieldValue.arrayUnion([memberId])
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.person_remove, color: ZapColors.errorRed),
                title: const Text("Remove from Group", style: TextStyle(color: ZapColors.errorRed)),
                onTap: () {
                  _firestore.collection('groups').doc(widget.groupId).update({
                    'members': FieldValue.arrayRemove([memberId]),
                    'admins': FieldValue.arrayRemove([memberId])
                  });
                  _firestore.collection('users').doc(memberId).update({
                    'groups': FieldValue.arrayRemove([widget.groupId])
                  });
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void showAddMembersDialog(List currentMembers) async {
    String myId = _auth.currentUser!.uid;
    var myDoc = await _firestore.collection('users').doc(myId).get();
    List myFriends = myDoc.data()?['friends'] ?? [];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: ZapColors.darkPurple,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text("Invite Friends", style: TextStyle(color: ZapColors.textPrimary)),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: myFriends.length,
              itemBuilder: (context, index) {
                String friendId = myFriends[index];
                if (currentMembers.contains(friendId)) return const SizedBox();
                return FutureBuilder<DocumentSnapshot>(
                  future: _firestore.collection('users').doc(friendId).get(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const SizedBox();
                    String friendName = snapshot.data!['username'];
                    return ListTile(
                      title: Text(friendName, style: const TextStyle(color: ZapColors.textPrimary)),
                      trailing: IconButton(
                        icon: const Icon(Icons.send_rounded, color: ZapColors.neonCyan),
                        onPressed: () async {
                          await _firestore.collection('group_requests').add({
                            'groupId': widget.groupId,
                            'groupName': widget.groupName,
                            'senderName': _auth.currentUser!.email,
                            'receiverId': friendId,
                            'status': 'pending',
                            'timestamp': FieldValue.serverTimestamp(),
                          });
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Invite sent to $friendName")));
                          Navigator.pop(context);
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    String myId = _auth.currentUser!.uid;

    return Scaffold(
      appBar: zapAppBar(title: 'Group Info'),
      body: NeonBackground(
        child: StreamBuilder<DocumentSnapshot>(
          stream: _firestore.collection('groups').doc(widget.groupId).snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: ZapColors.neonCyan));
            var groupData = snapshot.data!.data() as Map<String, dynamic>?;
            if (groupData == null) return const Center(child: Text("Group doesn't exist", style: TextStyle(color: ZapColors.textMuted)));

            List members = groupData['members'] ?? [];
            List admins = groupData['admins'] ?? [];
            bool iAmAdmin = admins.contains(myId);

            return Column(
              children: [
                const SizedBox(height: 28),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    gradient: ZapGradients.buttonGradient,
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: ZapColors.neonCyanGlow, blurRadius: 20)],
                  ),
                  child: const Icon(Icons.group_rounded, size: 36, color: Colors.white),
                ),
                const SizedBox(height: 14),
                Text(widget.groupName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: ZapColors.textPrimary)),
                const SizedBox(height: 6),
                Text("${members.length} Members", style: const TextStyle(color: ZapColors.textMuted, fontSize: 13)),
                
                if (iAmAdmin) 
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: GestureDetector(
                      onTap: () => showAddMembersDialog(members),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          border: Border.all(color: ZapColors.neonCyan, width: 1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.person_add_rounded, color: ZapColors.neonCyan, size: 16),
                            SizedBox(width: 6),
                            Text("Invite Members", style: TextStyle(color: ZapColors.neonCyan, fontSize: 13, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ),
                  ),

                const SizedBox(height: 16),
                const Divider(color: ZapColors.dividerColor, height: 1),
                
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: members.length,
                    itemBuilder: (context, index) {
                      String memberId = members[index];
                      bool isThisMemberAdmin = admins.contains(memberId);

                      return FutureBuilder<DocumentSnapshot>(
                        future: _firestore.collection('users').doc(memberId).get(),
                        builder: (context, userSnap) {
                          if (!userSnap.hasData) return const SizedBox();
                          String username = userSnap.data!['username'];

                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 3),
                            decoration: BoxDecoration(
                              color: ZapColors.cardDark,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: ZapColors.dividerColor, width: 0.5),
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: ZapColors.accentPurple,
                                child: Text(username[0].toUpperCase(), style: const TextStyle(color: ZapColors.neonCyan, fontWeight: FontWeight.w700)),
                              ),
                              title: Text(
                                username + (memberId == myId ? " (You)" : ""),
                                style: const TextStyle(color: ZapColors.textPrimary, fontSize: 14),
                              ),
                              trailing: isThisMemberAdmin
                                  ? Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: ZapColors.onlineGreen.withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Text("Admin", style: TextStyle(color: ZapColors.onlineGreen, fontWeight: FontWeight.w700, fontSize: 11)),
                                    )
                                  : null,
                              onTap: () {
                                if (memberId != myId) {
                                  manageUserOptions(context, memberId, username, iAmAdmin, isThisMemberAdmin);
                                }
                              },
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: GestureDetector(
                    onTap: leaveGroup,
                    child: Container(
                      width: double.infinity,
                      height: 48,
                      decoration: BoxDecoration(
                        color: ZapColors.errorRed.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: ZapColors.errorRed.withOpacity(0.5)),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.exit_to_app_rounded, color: ZapColors.errorRed, size: 20),
                          SizedBox(width: 8),
                          Text("Leave Group", style: TextStyle(color: ZapColors.errorRed, fontWeight: FontWeight.w700, fontSize: 15)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}