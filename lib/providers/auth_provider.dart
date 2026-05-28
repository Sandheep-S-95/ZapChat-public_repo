import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Streams the Firebase auth state — null means signed out.
final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

/// The current user's UID. Throws if called when unauthenticated.
final currentUserIdProvider = Provider<String>((ref) {
  final user = ref.watch(authStateProvider).valueOrNull;
  if (user == null) throw StateError('No authenticated user');
  return user.uid;
});

/// The current Firebase User object (nullable — safe version).
final currentUserProvider = Provider<User?>((ref) {
  return FirebaseAuth.instance.currentUser;
});
