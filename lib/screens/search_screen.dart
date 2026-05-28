import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utilities/neon_theme.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  String searchText = "";

  void sendFriendRequest(String receiverId, String receiverName) async {
    final senderId = _auth.currentUser!.uid;

    var senderDoc = await _firestore.collection('users').doc(senderId).get();
    String senderUsername = senderDoc.data()?['username'] ?? _auth.currentUser!.email;
    String senderProfilePic = senderDoc.data()?['profilePicUrl'] ?? '';

    // Create a request document
    await _firestore.collection('friend_requests').add({
      'senderId': senderId,
      'senderName': senderUsername,
      'senderProfilePic': senderProfilePic,
      'receiverId': receiverId,
      'status': 'pending',
      'timestamp': FieldValue.serverTimestamp(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Request sent to $receiverName')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: zapAppBar(
        title: '',
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: ZapColors.neonCyan, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: false,
      ),
      body: NeonBackground(
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.all(16),
              decoration: ZapDecorations.inputDecoration,
              child: TextField(
                autofocus: true,
                style: const TextStyle(color: ZapColors.textPrimary, fontSize: 14),
                cursorColor: ZapColors.neonCyan,
                decoration: const InputDecoration(
                  hintText: 'Search username...',
                  hintStyle: TextStyle(color: ZapColors.textMuted),
                  prefixIcon: Icon(Icons.search, color: ZapColors.neonCyan, size: 20),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                ),
                onChanged: (value) => setState(() => searchText = value),
              ),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore.collection('users')
                    .where('username', isGreaterThanOrEqualTo: searchText)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: ZapColors.neonCyan));
                  var docs = snapshot.data!.docs.where((doc) => doc.id != _auth.currentUser!.uid).toList();
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      var data = docs[index].data() as Map<String, dynamic>;
                      String username = data['username'] ?? 'User';
                      String profilePic = data['profilePicUrl'] ?? '';
                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 3),
                        decoration: BoxDecoration(
                          color: ZapColors.cardDark,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: ZapColors.dividerColor, width: 0.5),
                        ),
                        child: ListTile(
                          leading: Container(
                            width: 40, height: 40,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: ZapColors.neonCyan.withOpacity(0.3)),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: profilePic.isNotEmpty
                                ? Image.network(profilePic, fit: BoxFit.cover)
                                : Container(
                                    color: ZapColors.accentPurple,
                                    child: Center(child: Text(username[0].toUpperCase(), style: const TextStyle(color: ZapColors.neonCyan, fontWeight: FontWeight.w700))),
                                  ),
                          ),
                          title: Text(username, style: const TextStyle(color: ZapColors.textPrimary, fontSize: 14)),
                          trailing: IconButton(
                            icon: const Icon(Icons.person_add_rounded, color: ZapColors.neonCyan, size: 22),
                            onPressed: () => sendFriendRequest(docs[index].id, username),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}