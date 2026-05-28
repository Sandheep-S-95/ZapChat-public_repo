import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utilities/neon_theme.dart';

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  _CreateGroupScreenState createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  String groupName = "";
  bool isLoading = false;

  void createGroup() async {
    if (groupName.trim().isEmpty) return;
    setState(() => isLoading = true);

    String myId = _auth.currentUser!.uid;

    // 1. Create the Group Document
    DocumentReference groupRef = await _firestore.collection('groups').add({
      'groupName': groupName,
      'members': [myId],
      'admins': [myId], // Creator is automatically an admin
      'createdAt': FieldValue.serverTimestamp(),
    });

    // 2. Add Group ID to the User's document
    await _firestore.collection('users').doc(myId).update({
      'groups': FieldValue.arrayUnion([groupRef.id])
    });

    Navigator.pop(context); // Go back to home
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: zapAppBar(title: 'Create Group'),
      body: NeonBackground(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: ZapDecorations.cardDecoration,
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: ZapColors.neonCyan.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.group_add_rounded, color: ZapColors.neonCyan, size: 36),
                    ),
                    const SizedBox(height: 20),
                    const Text('New Group', style: TextStyle(color: ZapColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    const Text('Create a group and invite your friends', style: TextStyle(color: ZapColors.textMuted, fontSize: 13)),
                    const SizedBox(height: 24),
                    TextField(
                      autofocus: true,
                      onChanged: (val) => groupName = val,
                      style: const TextStyle(color: ZapColors.textPrimary, fontSize: 15),
                      cursorColor: ZapColors.neonCyan,
                      decoration: ZapDecorations.neonInputDecoration(
                        hint: 'Enter Group Name',
                        icon: Icons.group_rounded,
                      ),
                    ),
                    const SizedBox(height: 24),
                    isLoading
                      ? const CircularProgressIndicator(color: ZapColors.neonCyan)
                      : NeonButton(text: 'Create Group', onPressed: createGroup, icon: Icons.add_rounded),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}