import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utilities/neon_theme.dart';
import '../widgets/drawer_widgets.dart';
import '../providers/user_provider.dart';
import '../providers/auth_provider.dart';
import 'chat_screen.dart';
import 'group_chat_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});
  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

// ConsumerState gives us access to `ref` for reading Riverpod providers.
class _HomeScreenState extends ConsumerState<HomeScreen> with TickerProviderStateMixin {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  String searchText = '';
  bool isSearching = false;
  late AnimationController _fabPulse;
  late Stream<DocumentSnapshot> _userStream;
  late Stream<QuerySnapshot> _friendRequestsStream;
  late Stream<QuerySnapshot> _groupRequestsStream;

  @override
  void initState() {
    super.initState();
    _fabPulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    final myId = _auth.currentUser!.uid;
    _userStream = _firestore.collection('users').doc(myId).snapshots();
    _friendRequestsStream = _firestore
        .collection('friend_requests')
        .where('receiverId', isEqualTo: myId)
        .snapshots();
    _groupRequestsStream = _firestore
        .collection('group_requests')
        .where('receiverId', isEqualTo: myId)
        .snapshots();
  }

  @override
  void dispose() {
    _fabPulse.dispose();
    super.dispose();
  }

  // ─── Firebase helpers ───────────────────────────────────────────────

  void revokeRequest(String requestId) async =>
      await _firestore.collection('friend_requests').doc(requestId).delete();

  void rejectRequest(String requestId) async =>
      await _firestore.collection('friend_requests').doc(requestId).delete();

  void sendFriendRequest(String receiverId, String receiverName) async {
    final senderId = _auth.currentUser!.uid;
    var existing = await _firestore
        .collection('friend_requests')
        .where('senderId', isEqualTo: senderId)
        .where('receiverId', isEqualTo: receiverId)
        .get();
    if (existing.docs.isEmpty) {
      var senderDoc = await _firestore.collection('users').doc(senderId).get();
      String senderUsername = senderDoc.data()?['username'] ?? _auth.currentUser!.email;
      String senderPic = senderDoc.data()?['profilePicUrl'] ?? '';

      await _firestore.collection('friend_requests').add({
        'senderId': senderId,
        'senderName': senderUsername,
        'senderProfilePic': senderPic,
        'receiverId': receiverId,
        'status': 'pending',
        'timestamp': FieldValue.serverTimestamp(),
      });
    }
  }

  void acceptRequest(String requestId, String senderId) async {
    String myId = _auth.currentUser!.uid;
    await _firestore.collection('users').doc(myId).update({
      'friends': FieldValue.arrayUnion([senderId])
    });
    await _firestore.collection('users').doc(senderId).update({
      'friends': FieldValue.arrayUnion([myId])
    });
    await _firestore.collection('friend_requests').doc(requestId).delete();
  }

  void removeFriend(String friendId, String chatId) async {
    String myId = _auth.currentUser!.uid;
    await _firestore.collection('users').doc(myId).update({
      'friends': FieldValue.arrayRemove([friendId])
    });
    await _firestore.collection('users').doc(friendId).update({
      'friends': FieldValue.arrayRemove([myId])
    });
    var messages = await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .get();
    for (var doc in messages.docs) {
      await doc.reference.delete();
    }
    await _firestore.collection('chats').doc(chatId).delete();
  }

  void blockUser(String friendId, String chatId) async {
    removeFriend(friendId, chatId);
    String myId = _auth.currentUser!.uid;
    await _firestore.collection('users').doc(myId).update({
      'blockedUsers': FieldValue.arrayUnion([friendId])
    });
  }

  void markChatAsRead(String chatId) {
    String myId = _auth.currentUser!.uid;
    _firestore.collection('chats').doc(chatId).set(
        {'lastRead_$myId': FieldValue.serverTimestamp()},
        SetOptions(merge: true));
  }

  void acceptGroupRequest(String requestId, String groupId) async {
    String myId = _auth.currentUser!.uid;
    await _firestore.collection('groups').doc(groupId).update({
      'members': FieldValue.arrayUnion([myId])
    });
    await _firestore.collection('users').doc(myId).update({
      'groups': FieldValue.arrayUnion([groupId])
    });
    await _firestore.collection('group_requests').doc(requestId).delete();
  }

  void rejectGroupRequest(String requestId) async =>
      await _firestore.collection('group_requests').doc(requestId).delete();

  void markGroupAsRead(String groupId) {
    String myId = _auth.currentUser!.uid;
    _firestore.collection('groups').doc(groupId).set(
        {'lastRead_$myId': FieldValue.serverTimestamp()},
        SetOptions(merge: true));
  }

  // ─── Build ──────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final String myId = _auth.currentUser!.uid;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: _buildAppBar(),
      drawer: _buildDrawer(context),
      floatingActionButton: _buildFAB(context),
      body: HomeBackground(
        child: SafeArea(
          child: StreamBuilder<DocumentSnapshot>(
            stream: _userStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: ZapColors.neonCyan),
                );
              }
              if (snapshot.hasError) {
                return Center(
                  child: Text('Error: ${snapshot.error}', style: const TextStyle(color: ZapColors.errorRed)),
                );
              }
              if (!snapshot.hasData || !snapshot.data!.exists) {
                return const Center(
                  child: Text('User data not found.', style: TextStyle(color: ZapColors.neonCyan)),
                );
              }

              var userData = snapshot.data!.data() as Map<String, dynamic>? ?? {};
              List<String> myFriends = List<String>.from(userData['friends'] ?? []);
              List<String> myGroups = List<String>.from(userData['groups'] ?? []);
              List<String> myBlockedUsers = List<String>.from(userData['blockedUsers'] ?? []);

              return Column(
                children: [
                  _buildSearchBar(),
                  if (isSearching && searchText.isNotEmpty)
                    _buildSearchResults(myId, myFriends, myBlockedUsers)
                  else
                    Expanded(
                      child: CustomScrollView(
                        physics: const BouncingScrollPhysics(),
                        slivers: [
                          SliverToBoxAdapter(child: _buildFriendRequests(myId)),
                          SliverToBoxAdapter(child: _buildGroupInvites(myId)),
                          if (myGroups.isNotEmpty) ...[
                            SliverToBoxAdapter(
                              child: _buildSectionHeader(
                                Icons.group_rounded,
                                'MY GROUPS',
                              ),
                            ),
                            SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (ctx, i) => _buildGroupTile(myGroups[i], myId),
                                childCount: myGroups.length,
                              ),
                            ),
                          ],
                          SliverToBoxAdapter(
                            child: _buildSectionHeader(
                              Icons.person_rounded,
                              'MY FRIENDS',
                            ),
                          ),
                          if (myFriends.isEmpty)
                            SliverToBoxAdapter(
                              child: _buildEmptyState(),
                            )
                          else
                            SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (ctx, i) => _buildFriendTile(myFriends[i], myId),
                                childCount: myFriends.length,
                              ),
                            ),
                          const SliverToBoxAdapter(child: SizedBox(height: 100)),
                        ],
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  // ─── App Bar ────────────────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(62),
      child: ClipRect(
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF0D1530), Color(0xFF080F22)],
            ),
            border: Border(
              bottom: BorderSide(
                  color: ZapColors.neonCyan.withValues(alpha: 0.15), width: 1),
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                children: [
                  // Menu
                  Builder(
                    builder: (ctx) => _appBarIconBtn(
                      Icons.menu_rounded,
                      () => Scaffold.of(ctx).openDrawer(),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Logo + Title
                  const AnimatedLogoSmall(size: 26),
                  const SizedBox(width: 8),
                  ShaderMask(
                    shaderCallback: (b) => const LinearGradient(
                      colors: [Colors.white, Color(0xFF80DEEA)],
                    ).createShader(b),
                    child: const Text(
                      'ZapChat',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.4,
                      ),
                    ),
                  ),
                  const Spacer(),
                  // Search toggle
                  _appBarIconBtn(
                    isSearching ? Icons.close_rounded : Icons.search_rounded,
                    () => setState(() {
                      isSearching = !isSearching;
                      if (!isSearching) searchText = '';
                    }),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _appBarIconBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(12),
          border:
              Border.all(color: Colors.white.withValues(alpha: 0.10), width: 1),
        ),
        child: Icon(icon, color: ZapColors.neonCyan, size: 20),
      ),
    );
  }

  // ─── Search bar ─────────────────────────────────────────────────────

  Widget _buildSearchBar() {
    if (!isSearching) return const SizedBox();
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: ZapColors.neonCyan.withValues(alpha: 0.30), width: 1.2),
      ),
      child: TextField(
        autofocus: true,
        onChanged: (v) => setState(() => searchText = v),
        style: const TextStyle(color: ZapColors.textPrimary, fontSize: 14),
        cursorColor: ZapColors.neonCyan,
        decoration: const InputDecoration(
          hintText: 'Search users...',
          hintStyle: TextStyle(color: ZapColors.textMuted),
          prefixIcon:
              Icon(Icons.search_rounded, color: ZapColors.neonCyan, size: 20),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        ),
      ),
    );
  }

  // ─── Section header ─────────────────────────────────────────────────

  Widget _buildSectionHeader(IconData icon, String label) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF00E5FF), Color(0xFF0097A7)],
              ),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                    color: ZapColors.neonCyan.withValues(alpha: 0.35),
                    blurRadius: 8,
                    spreadRadius: 0),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 14),
          ),
          const SizedBox(width: 10),
          Text(
            label,
            style: const TextStyle(
              color: ZapColors.neonCyan,
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 2.0,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    ZapColors.neonCyan.withValues(alpha: 0.40),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Empty state ─────────────────────────────────────────────────────

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 32),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: ZapColors.neonCyan.withValues(alpha: 0.08),
              shape: BoxShape.circle,
              border:
                  Border.all(color: ZapColors.neonCyan.withValues(alpha: 0.20)),
            ),
            child: const Icon(Icons.person_search_rounded,
                color: ZapColors.neonCyan, size: 36),
          ),
          const SizedBox(height: 16),
          const Text(
            'No friends yet',
            style: TextStyle(
                color: ZapColors.textSecondary,
                fontSize: 16,
                fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          const Text(
            'Tap the search icon to find users',
            style: TextStyle(color: ZapColors.textMuted, fontSize: 13),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ─── Friend Requests ─────────────────────────────────────────────────

  Widget _buildFriendRequests(String myId) {
    return StreamBuilder<QuerySnapshot>(
      stream: _friendRequestsStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const SizedBox();
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(Icons.person_add_rounded, 'FRIEND REQUESTS'),
            ...snapshot.data!.docs.map((doc) {
              var data = doc.data() as Map<String, dynamic>;
              return _requestTile(
                icon: Icons.person_add_rounded,
                iconColor: ZapColors.warningOrange,
                title: '${data['senderName'] ?? 'Someone'}',
                subtitle: 'Wants to connect with you',
                profilePic: data.containsKey('senderProfilePic') ? data['senderProfilePic'] : null,
                onAccept: () => acceptRequest(doc.id, data['senderId']),
                onReject: () => rejectRequest(doc.id),
              );
            }),
          ],
        );
      },
    );
  }

  // ─── Group invites ────────────────────────────────────────────────────

  Widget _buildGroupInvites(String myId) {
    return StreamBuilder<QuerySnapshot>(
      stream: _groupRequestsStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const SizedBox();
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(Icons.group_add_rounded, 'GROUP INVITES'),
            ...snapshot.data!.docs.map((doc) => _requestTile(
                  icon: Icons.group_add_rounded,
                  iconColor: ZapColors.neonCyanSoft,
                  title: '${doc['groupName']}',
                  subtitle: 'From ${doc['senderName']}',
                  onAccept: () => acceptGroupRequest(doc.id, doc['groupId']),
                  onReject: () => rejectGroupRequest(doc.id),
                )),
          ],
        );
      },
    );
  }

  Widget _requestTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onAccept,
    required VoidCallback onReject,
    String? profilePic,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: iconColor.withValues(alpha: 0.20), width: 1),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: iconColor.withValues(alpha: 0.25), width: 1),
          ),
          clipBehavior: Clip.antiAlias,
          child: (profilePic != null && profilePic.isNotEmpty)
              ? Image.network(profilePic, fit: BoxFit.cover)
              : Icon(icon, color: iconColor, size: 20),
        ),
        title: Text(title,
            style: const TextStyle(
                color: ZapColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle,
            style: const TextStyle(color: ZapColors.textMuted, fontSize: 12)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _iconActionBtn(
                Icons.check_rounded, ZapColors.onlineGreen, onAccept),
            const SizedBox(width: 8),
            _iconActionBtn(Icons.close_rounded, ZapColors.errorRed, onReject),
          ],
        ),
      ),
    );
  }

  Widget _iconActionBtn(IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.25), width: 1),
        ),
        child: Icon(icon, color: color, size: 18),
      ),
    );
  }

  // ─── Search Results ────────────────────────────────────────────────────

  Widget _buildSearchResults(String myId, List myFriends, List myBlockedUsers) {
    return Expanded(
      child: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('users')
            .where('username', isGreaterThanOrEqualTo: searchText)
            .where('username', isLessThan: searchText + 'z')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const SizedBox();
          var results = snapshot.data!.docs.where((d) => d.id != myId && !myBlockedUsers.contains(d.id)).toList();
          if (results.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.search_off_rounded,
                      color: ZapColors.textMuted, size: 40),
                  const SizedBox(height: 12),
                  Text('No users found for "$searchText"',
                      style: const TextStyle(
                          color: ZapColors.textMuted, fontSize: 13)),
                ],
              ),
            );
          }
          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            children: results.map((userDoc) {
              var d = userDoc.data() as Map<String, dynamic>?;
              String pic = d?['profilePicUrl'] ?? '';
              bool isFriend = myFriends.contains(userDoc.id);
              List theirBlockedUsers = d?['blockedUsers'] ?? [];
              bool theyBlockedMe = theirBlockedUsers.contains(myId);
              return _chatCard(
                avatar: _avatarWidget(pic, userDoc['username']),
                title: userDoc['username'],
                subtitle: theyBlockedMe ? '' : (isFriend ? 'Already friends' : 'Tap to add friend'),
                hasNew: false,
                onTap: () {},
                trailing: isFriend
                    ? const Icon(Icons.how_to_reg_rounded,
                        color: ZapColors.onlineGreen, size: 20)
                    : StreamBuilder<QuerySnapshot>(
                        stream: _firestore
                            .collection('friend_requests')
                            .where('senderId', isEqualTo: myId)
                            .where('receiverId', isEqualTo: userDoc.id)
                            .snapshots(),
                        builder: (context, reqSnap) {
                          bool sent =
                              reqSnap.hasData && reqSnap.data!.docs.isNotEmpty;
                          return GestureDetector(
                            onTap: theyBlockedMe ? null : () => sent
                                ? revokeRequest(reqSnap.data!.docs.first.id)
                                : sendFriendRequest(
                                    userDoc.id, userDoc['username']),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                gradient: theyBlockedMe
                                    ? null
                                    : (sent ? null : ZapGradients.buttonGradient),
                                color: theyBlockedMe
                                    ? ZapColors.textMuted.withValues(alpha: 0.15)
                                    : (sent
                                        ? ZapColors.errorRed.withValues(alpha: 0.15)
                                        : null),
                                borderRadius: BorderRadius.circular(10),
                                border: theyBlockedMe
                                    ? Border.all(
                                        color: ZapColors.textMuted
                                            .withValues(alpha: 0.4))
                                    : (sent
                                        ? Border.all(
                                            color: ZapColors.errorRed
                                                .withValues(alpha: 0.4))
                                        : null),
                                boxShadow: theyBlockedMe || sent
                                    ? null
                                    : [
                                        BoxShadow(
                                            color: ZapColors.neonCyan
                                                .withValues(alpha: 0.25),
                                            blurRadius: 8)
                                      ],
                              ),
                              child: Text(
                                theyBlockedMe
                                    ? 'Blocked you'
                                    : (sent ? 'Undo' : 'Add'),
                                style: TextStyle(
                                  color: theyBlockedMe
                                      ? ZapColors.textMuted
                                      : (sent ? ZapColors.errorRed : Colors.white),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              );
            }).toList(),
          );
        },
      ),
    );
  }

  // ─── Group tile ─────────────────────────────────────────────────────────

  Widget _buildGroupTile(String groupId, String myId) {
    return StreamBuilder<DocumentSnapshot>(
      stream: _firestore.collection('groups').doc(groupId).snapshots(),
      builder: (context, groupSnap) {
        if (!groupSnap.hasData || !groupSnap.data!.exists)
          return const SizedBox();
        var gData = groupSnap.data!.data() as Map<String, dynamic>;
        Timestamp? myLastRead = gData['lastRead_$myId'];
        return StreamBuilder<QuerySnapshot>(
          stream: _firestore
              .collection('groups')
              .doc(groupId)
              .collection('messages')
              .orderBy('timestamp', descending: true)
              .limit(1)
              .snapshots(),
          builder: (context, msgSnap) {
            bool hasNew = false;
            String lastMsg = 'Group Chat';
            if (msgSnap.hasData && msgSnap.data!.docs.isNotEmpty) {
              var last = msgSnap.data!.docs.first;
              bool isFromMe = last['sender'] == _auth.currentUser!.email;
              Timestamp? msgTime = last['timestamp'];
              lastMsg = last['text'] ?? '';
              if (!isFromMe &&
                  msgTime != null &&
                  (myLastRead == null || msgTime.compareTo(myLastRead) > 0))
                hasNew = true;
            }
            return _chatCard(
              avatar: _groupAvatar(),
              title: gData['groupName'],
              subtitle: lastMsg,
              hasNew: hasNew,
              onTap: () {
                markGroupAsRead(groupId);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => GroupChatScreen(
                            groupId: groupId, groupName: gData['groupName'])));
              },
            );
          },
        );
      },
    );
  }

  // ─── Friend tile ────────────────────────────────────────────────────────

  Widget _buildFriendTile(String friendId, String myId) {
    return FutureBuilder<DocumentSnapshot>(
      future: _firestore.collection('users').doc(friendId).get(),
      builder: (context, fSnap) {
        if (!fSnap.hasData) return const SizedBox();
        var fData = fSnap.data!.data() as Map<String, dynamic>;
        List<String> ids = [myId, friendId];
        ids.sort();
        String chatId = ids.join('_');
        return StreamBuilder<DocumentSnapshot>(
          stream: _firestore.collection('chats').doc(chatId).snapshots(),
          builder: (context, chatSnap) {
            Map<String, dynamic>? chatData =
                chatSnap.data?.data() as Map<String, dynamic>?;
            Timestamp? myLastRead = chatData?['lastRead_$myId'];
            return StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('chats')
                  .doc(chatId)
                  .collection('messages')
                  .orderBy('timestamp', descending: true)
                  .limit(1)
                  .snapshots(),
              builder: (context, msgSnap) {
                bool hasNew = false;
                String lastMsg = '';
                if (msgSnap.hasData && msgSnap.data!.docs.isNotEmpty) {
                  var last = msgSnap.data!.docs.first;
                  bool isFromMe = last['sender'] == _auth.currentUser!.email;
                  Timestamp? msgTime = last['timestamp'];
                  lastMsg = last['text'] ?? '';
                  if (!isFromMe &&
                      msgTime != null &&
                      (myLastRead == null ||
                          msgTime.compareTo(myLastRead) > 0)) {
                    hasNew = true;
                  }
                }
                String pic = (fData.containsKey('profilePicUrl') &&
                        fData['profilePicUrl'] != null &&
                        fData['profilePicUrl'].toString().isNotEmpty)
                    ? fData['profilePicUrl']
                    : '';
                return Dismissible(
                  key: Key(friendId),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 24),
                    margin:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                    decoration: BoxDecoration(
                      color: ZapColors.errorRed.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: ZapColors.errorRed.withValues(alpha: 0.35)),
                    ),
                    child: const Icon(Icons.delete_rounded,
                        color: ZapColors.errorRed),
                  ),
                  confirmDismiss: (_) async {
                    String? action = await showDialog<String>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        backgroundColor: const Color(0xFF0D102A),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        title: const Text('Remove or Block?', style: TextStyle(color: ZapColors.textPrimary)),
                        content: Text("Remove ${fData['username']}? You can also block them to prevent future contact.", style: const TextStyle(color: ZapColors.textMuted)),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, 'cancel'),
                            child: const Text('Cancel', style: TextStyle(color: ZapColors.textMuted)),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, 'remove'),
                            child: const Text('Remove', style: TextStyle(color: ZapColors.warningOrange)),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, 'block'),
                            child: const Text('Block', style: TextStyle(color: ZapColors.errorRed)),
                          ),
                        ],
                      ),
                    );
                    if (action == 'block') {
                      blockUser(friendId, chatId);
                      return true;
                    } else if (action == 'remove') {
                      removeFriend(friendId, chatId);
                      return true;
                    }
                    return false;
                  },
                  onDismissed: (_) {},
                  child: _chatCard(
                    avatar: _avatarWidget(pic, fData['username']),
                    title: fData['username'],
                    subtitle: lastMsg,
                    hasNew: hasNew,
                    onTap: () {
                      markChatAsRead(chatId);
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => ChatScreen(
                                  chatId: chatId,
                                  chatTitle: fData['username'],
                                  chatPic: pic,
                              )));
                    },
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  // ─── Chat card (premium glassmorphic tile) ────────────────────────────

  Widget _chatCard({
    required Widget avatar,
    required String title,
    required String subtitle,
    required bool hasNew,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: hasNew ? 0.07 : 0.04),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: hasNew
                ? ZapColors.neonCyan.withValues(alpha: 0.30)
                : Colors.white.withValues(alpha: 0.08),
            width: hasNew ? 1.2 : 1.0,
          ),
          boxShadow: hasNew
              ? [
                  BoxShadow(
                    color: ZapColors.neonCyan.withValues(alpha: 0.08),
                    blurRadius: 12,
                    spreadRadius: 0,
                  )
                ]
              : null,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              avatar,
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: ZapColors.textPrimary,
                        fontSize: 15,
                        fontWeight: hasNew ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                    if (subtitle.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: hasNew
                              ? ZapColors.textSecondary
                              : ZapColors.textMuted,
                          fontSize: 12.5,
                        ),
                      ),
                    ]
                  ],
                ),
              ),
              const SizedBox(width: 8),
              trailing ??
                  (hasNew
                      ? Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: ZapColors.onlineGreen,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: ZapColors.onlineGreen
                                    .withValues(alpha: 0.55),
                                blurRadius: 8,
                              )
                            ],
                          ),
                        )
                      : Icon(Icons.chevron_right_rounded,
                          color: Colors.white.withValues(alpha: 0.25),
                          size: 20)),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Avatars ────────────────────────────────────────────────────────────

  Widget _groupAvatar() {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        gradient: ZapGradients.buttonGradient,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: ZapColors.neonCyan.withValues(alpha: 0.30), blurRadius: 8)
        ],
      ),
      child: const Icon(Icons.group_rounded, color: Colors.white, size: 22),
    );
  }

  Widget _avatarWidget(String pic, String name) {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: ZapColors.neonCyan.withValues(alpha: 0.25), width: 1.5),
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
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            ZapColors.accentPurple,
            ZapColors.neonCyan.withValues(alpha: 0.6),
          ],
        ),
      ),
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : '?',
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18),
        ),
      ),
    );
  }

  // ─── FAB (glowing orb) ────────────────────────────────────────────────────

  Widget _buildFAB(BuildContext context) {
    return AnimatedBuilder(
      animation: _fabPulse,
      builder: (context, child) {
        final pulse = _fabPulse.value;
        return GestureDetector(
          onTap: () => Navigator.pushNamed(context, '/create_group'),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Outer glow ring
              Container(
                width: 72 + pulse * 6,
                height: 72 + pulse * 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: ZapColors.neonCyan
                          .withValues(alpha: 0.20 + pulse * 0.15),
                      blurRadius: 24 + pulse * 12,
                      spreadRadius: 2 + pulse * 4,
                    ),
                  ],
                ),
              ),
              // Button
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF00E5FF).withValues(alpha: 0.9),
                      const Color(0xFF0050B0),
                    ],
                    center: Alignment(-0.3, -0.3),
                    radius: 1.1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: ZapColors.neonCyan.withValues(alpha: 0.45),
                      blurRadius: 16,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: const Icon(Icons.group_add_rounded,
                    color: Colors.white, size: 26),
              ),
            ],
          ),
        );
      },
    );
  }

  // ─── Drawer ────────────────────────────────────────────────────────────────

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0D102A), Color(0xFF060818)],
          ),
          border: Border(
            right: BorderSide(color: Color(0xFF1A2050), width: 1),
          ),
        ),
        child: Column(
          children: [
            // First part: Header with pastel sea watery background
            DrawerHeaderBackground(
              child: SafeArea(
                bottom: false,
                child: StreamBuilder<DocumentSnapshot>(
                  stream: _firestore
                      .collection('users')
                      .doc(_auth.currentUser!.uid)
                      .snapshots(),
                  builder: (context, snapshot) {
                    String username = '...';
                    String pic = '';
                    if (snapshot.hasData && snapshot.data!.exists) {
                      final data =
                          snapshot.data!.data() as Map<String, dynamic>;
                      username = data['username'] ?? 'User';
                      pic = data['profilePicUrl'] ?? '';
                    }
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.only(top: 32, bottom: 24),
                      child: Column(
                        children: [
                          RevolvingAvatar(
                            imageUrl: pic,
                            initial: username.isNotEmpty
                                ? username[0].toUpperCase()
                                : '?',
                            size: 70,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            username,
                            style: const TextStyle(
                              color: Color(0xFF062030), // Dark navy for contrast
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _auth.currentUser?.email ?? '',
                            style: const TextStyle(
                              color: Color(0xFF164A5B),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
            // Thin divider separating header from actions
            Container(height: 1, color: const Color(0xFF1A2050)),
            const SizedBox(height: 8),
            // Second part: Actions (Profile, Create Group)
            Expanded(
              child: SafeArea(
                top: false,
                child: Column(
                  children: [
                    _drawerTile(Icons.person_rounded, 'Profile', () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/profile_edit');
                    }),
                    _drawerTile(Icons.group_add_rounded, 'Create Group', () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/create_group');
                    }),
                    _drawerTile(Icons.shield_rounded, 'Blocked Users', () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/blocked_users');
                    }),
                    const Spacer(),
                    // Third part: Log Out
                    Container(
                        height: 1,
                        color: Colors.white.withValues(alpha: 0.07)),
                    _drawerTile(Icons.logout_rounded, 'Log Out', () async {
                      Navigator.pop(context); // close drawer
                      await _auth.signOut();
                      if (mounted) {
                        Navigator.of(context).pushNamedAndRemoveUntil(
                          '/',
                          (_) => false,
                        );
                      }
                    }, color: ZapColors.errorRed),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _drawerTile(IconData icon, String title, VoidCallback onTap,
      {Color? color}) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: (color ?? ZapColors.neonCyan).withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color ?? ZapColors.neonCyan, size: 18),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: color ?? ZapColors.textPrimary,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
    );
  }

  // ─── Alert dialog ──────────────────────────────────────────────────────────

  Widget _confirmDialog(BuildContext ctx, String title, String content) {
    return AlertDialog(
      backgroundColor: const Color(0xFF0D102A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(title, style: const TextStyle(color: ZapColors.textPrimary)),
      content:
          Text(content, style: const TextStyle(color: ZapColors.textMuted)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Cancel',
              style: TextStyle(color: ZapColors.textMuted)),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx, true),
          child:
              const Text('Remove', style: TextStyle(color: ZapColors.errorRed)),
        ),
      ],
    );
  }
}
