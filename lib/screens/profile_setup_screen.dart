import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utilities/neon_theme.dart';

class ProfileSetupScreen extends StatefulWidget {
  @override
  _ProfileSetupScreenState createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  
  String username = "";
  bool isLoading = false;
  String errorMessage = "";
  int selectedAvatarIndex = 0;

  final List<String> avatarPool = [
    // Old avatars
    "https://api.dicebear.com/9.x/adventurer/png?seed=Felix",
    "https://api.dicebear.com/9.x/bottts/png?seed=Mimi",
    "https://api.dicebear.com/9.x/avataaars/png?seed=Jack",
    "https://api.dicebear.com/9.x/fun-emoji/png?seed=Luna",
    "https://api.dicebear.com/9.x/micah/png?seed=Oliver",
    "https://api.dicebear.com/9.x/pixel-art/png?seed=Sam",
    // New happy avatars
    "https://api.dicebear.com/9.x/fun-emoji/png?seed=Joy",
    "https://api.dicebear.com/9.x/fun-emoji/png?seed=Happy",
    "https://api.dicebear.com/9.x/fun-emoji/png?seed=Lily",
    "https://api.dicebear.com/9.x/fun-emoji/png?seed=Wink",
    "https://api.dicebear.com/9.x/avataaars/png?seed=Leo&mouth=smile",
    "https://api.dicebear.com/9.x/micah/png?seed=Oliver&mouth=smile",
    "https://api.dicebear.com/9.x/adventurer/png?seed=Destiny",
    "https://api.dicebear.com/9.x/bottts/png?seed=Tinker",
    // Extras to round out to 16 for the 4-column grid
    "https://api.dicebear.com/9.x/pixel-art/png?seed=Bob",
    "https://api.dicebear.com/9.x/avataaars/png?seed=Mia",
  ];

  void saveProfile() async {
    if (username.trim().isEmpty) {
      setState(() => errorMessage = "Username cannot be empty");
      return;
    }
    setState(() { isLoading = true; errorMessage = ""; });
    try {
      User? currentUser = _auth.currentUser;
      if (currentUser == null) return;
      var existingUser = await _firestore.collection('users').where('username', isEqualTo: username.trim()).get();
      if (existingUser.docs.isNotEmpty) {
        setState(() { isLoading = false; errorMessage = "Username is taken. Please choose another."; });
        return;
      }
      String chosenAvatarUrl = avatarPool[selectedAvatarIndex];
      await _firestore.collection('users').doc(currentUser.uid).set({
        'email': currentUser.email,
        'username': username.trim(),
        'profilePicUrl': chosenAvatarUrl,
        'friends': [],
        'groups': [],
      });
      if (mounted) { Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false); }
    } catch (e) {
      setState(() { isLoading = false; errorMessage = "An error occurred. Please try again."; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: zapAppBar(title: 'Setup Profile'),
      body: NeonBackground(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: ZapDecorations.cardDecoration,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("Choose your Avatar", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: ZapColors.neonCyan, letterSpacing: 1)),
                  const SizedBox(height: 20),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: avatarPool.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, crossAxisSpacing: 16, mainAxisSpacing: 16),
                    itemBuilder: (context, index) {
                      bool isSelected = selectedAvatarIndex == index;
                      return GestureDetector(
                        onTap: () => setState(() => selectedAvatarIndex = index),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: isSelected ? ZapColors.neonCyan : Colors.transparent, width: 3),
                            boxShadow: isSelected ? [BoxShadow(color: ZapColors.neonCyanGlow, blurRadius: 12)] : [],
                          ),
                          child: CircleAvatar(
                            backgroundColor: ZapColors.cardDark,
                            backgroundImage: NetworkImage(avatarPool[index]),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 28),
                  TextField(
                    textAlign: TextAlign.center,
                    onChanged: (value) => setState(() => username = value),
                    style: const TextStyle(color: ZapColors.textPrimary, fontSize: 15),
                    cursorColor: ZapColors.neonCyan,
                    decoration: ZapDecorations.neonInputDecoration(hint: 'Choose a unique username', icon: Icons.person_outline),
                  ),
                  if (errorMessage.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text(errorMessage, style: const TextStyle(color: ZapColors.errorRed, fontWeight: FontWeight.w600, fontSize: 13)),
                    ),
                  const SizedBox(height: 24),
                  isLoading
                    ? const CircularProgressIndicator(color: ZapColors.neonCyan)
                    : NeonButton(text: 'Save & Continue', onPressed: saveProfile, icon: Icons.arrow_forward_rounded),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}