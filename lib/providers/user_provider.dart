import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_provider.dart';

final _firestore = FirebaseFirestore.instance;

// ─── Current user's Firestore document ──────────────────────────────────────

/// Streams the logged-in user's Firestore document as a safe Map.
/// Falls back to {} if the document is missing fields (legacy user support).
final myUserDataProvider = StreamProvider<Map<String, dynamic>>((ref) {
  final uid = ref.watch(currentUserIdProvider);
  return _firestore.collection('users').doc(uid).snapshots().map(
    (snap) => snap.data() ?? {},
  );
});

// ─── Derived convenience providers ──────────────────────────────────────────

/// List of friend UIDs from the current user's document.
final myFriendsProvider = Provider<List<String>>((ref) {
  final data = ref.watch(myUserDataProvider).valueOrNull ?? {};
  return List<String>.from(data['friends'] ?? []);
});

/// List of group IDs the current user belongs to.
final myGroupsProvider = Provider<List<String>>((ref) {
  final data = ref.watch(myUserDataProvider).valueOrNull ?? {};
  return List<String>.from(data['groups'] ?? []);
});

/// List of blocked user UIDs.
final myBlockedUsersProvider = Provider<List<String>>((ref) {
  final data = ref.watch(myUserDataProvider).valueOrNull ?? {};
  return List<String>.from(data['blockedUsers'] ?? []);
});

// ─── Friend Requests ─────────────────────────────────────────────────────────

/// Incoming friend requests for the current user.
final friendRequestsProvider = StreamProvider<List<QueryDocumentSnapshot>>((ref) {
  final uid = ref.watch(currentUserIdProvider);
  return _firestore
      .collection('friend_requests')
      .where('receiverId', isEqualTo: uid)
      .snapshots()
      .map((snap) => snap.docs);
});

// ─── Group Requests ──────────────────────────────────────────────────────────

/// Incoming group invites for the current user.
final groupRequestsProvider = StreamProvider<List<QueryDocumentSnapshot>>((ref) {
  final uid = ref.watch(currentUserIdProvider);
  return _firestore
      .collection('group_requests')
      .where('receiverId', isEqualTo: uid)
      .snapshots()
      .map((snap) => snap.docs);
});

// ─── Chat message streams ────────────────────────────────────────────────────

/// Messages for a specific 1-on-1 chat.
final chatMessagesProvider = StreamProvider.family<List<QueryDocumentSnapshot>, String>((ref, chatId) {
  return _firestore
      .collection('chats')
      .doc(chatId)
      .collection('messages')
      .orderBy('timestamp', descending: true)
      .snapshots()
      .map((snap) => snap.docs);
});

/// Messages for a specific group chat.
final groupMessagesProvider = StreamProvider.family<List<QueryDocumentSnapshot>, String>((ref, groupId) {
  return _firestore
      .collection('groups')
      .doc(groupId)
      .collection('messages')
      .orderBy('timestamp', descending: true)
      .snapshots()
      .map((snap) => snap.docs);
});
