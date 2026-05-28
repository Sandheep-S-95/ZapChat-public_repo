import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utilities/neon_theme.dart';

class ProfileEditScreen extends StatefulWidget {
  @override
  _ProfileEditScreenState createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  
  String currentUsername = "";
  String currentPicUrl = "";
  String newUsername = "";
  bool isLoading = true;
  bool isSaving = false;
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

  @override
  void initState() {
    super.initState();
    loadCurrentProfile();
  }

  void loadCurrentProfile() async {
    try {
      User? currentUser = _auth.currentUser;
      if (currentUser != null) {
        var doc = await _firestore.collection('users').doc(currentUser.uid).get();
        if (doc.exists) {
          setState(() {
            var data = doc.data();
            currentUsername = data?['username'] ?? '';
            newUsername = currentUsername;
            currentPicUrl = data?['profilePicUrl'] ?? '';
            selectedAvatarIndex = avatarPool.indexOf(currentPicUrl);
            if (selectedAvatarIndex == -1) selectedAvatarIndex = 0;
            isLoading = false;
          });
          return;
        }
      }
      setState(() { isLoading = false; });
    } catch (e) {
      print("Error loading profile: $e");
      setState(() { isLoading = false; errorMessage = "Failed to load profile."; });
    }
  }

  void saveChanges() async {
    if (newUsername.trim().isEmpty) {
      setState(() => errorMessage = "Username cannot be empty");
      return;
    }
    setState(() { isSaving = true; errorMessage = ""; });
    try {
      User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        setState(() { isSaving = false; errorMessage = "No authenticated user."; });
        return;
      }
      if (newUsername.trim() != currentUsername) {
        var existing = await _firestore.collection('users').where('username', isEqualTo: newUsername.trim()).get();
        if (existing.docs.isNotEmpty) {
          setState(() { isSaving = false; errorMessage = "Username is already taken."; });
          return;
        }
      }
      String chosenAvatarUrl = avatarPool[selectedAvatarIndex];
      await _firestore.collection('users').doc(currentUser.uid).update({
        'username': newUsername.trim(),
        'profilePicUrl': chosenAvatarUrl,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Profile Updated!")));
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() { isSaving = false; errorMessage = "An error occurred."; });
    }
  }

  void _showInfoSheet(BuildContext context, String title, IconData icon, String content, Color iconColor) {
    showModalBottomSheet(
      context: context,
      backgroundColor: ZapColors.darkPurple,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(28.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 4, decoration: BoxDecoration(color: ZapColors.dividerColor, borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: iconColor.withOpacity(0.15), shape: BoxShape.circle),
                child: Icon(icon, size: 36, color: iconColor),
              ),
              const SizedBox(height: 18),
              Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: ZapColors.textPrimary)),
              const SizedBox(height: 14),
              Text(content, textAlign: TextAlign.center, style: const TextStyle(fontSize: 14, color: ZapColors.textSecondary, height: 1.6)),
              const SizedBox(height: 28),
              NeonButton(text: 'Close', onPressed: () => Navigator.pop(context)),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: zapAppBar(title: 'Edit Profile'),
      body: NeonBackground(
        child: isLoading
          ? const Center(child: CircularProgressIndicator(color: ZapColors.neonCyan))
          : SingleChildScrollView(
              child: Column(
                children: [
                  // Section 1: Profile Edit
                  Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(20),
                    decoration: ZapDecorations.cardDecoration,
                    child: Column(
                      children: [
                        const Text("Choose Avatar", style: TextStyle(fontWeight: FontWeight.w700, color: ZapColors.neonCyan, fontSize: 14, letterSpacing: 1)),
                        const SizedBox(height: 16),
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
                        const SizedBox(height: 24),
                        TextFormField(
                          initialValue: currentUsername,
                          textAlign: TextAlign.center,
                          onChanged: (v) => newUsername = v,
                          style: const TextStyle(color: ZapColors.textPrimary, fontSize: 16),
                          cursorColor: ZapColors.neonCyan,
                          decoration: ZapDecorations.neonInputDecoration(hint: 'Change username', icon: Icons.person_outline),
                        ),
                        if (errorMessage.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Text(errorMessage, style: const TextStyle(color: ZapColors.errorRed, fontWeight: FontWeight.w600, fontSize: 13)),
                          ),
                        const SizedBox(height: 20),
                        isSaving
                          ? const CircularProgressIndicator(color: ZapColors.neonCyan)
                          : NeonButton(text: 'Save Changes', onPressed: saveChanges, icon: Icons.save_rounded),
                      ],
                    ),
                  ),
                  // Section 2: Security & Info
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: ZapDecorations.cardDecoration,
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.fromLTRB(20, 18, 20, 10),
                          child: Text("SECURITY & INFO", style: TextStyle(fontWeight: FontWeight.w700, color: ZapColors.neonCyan, fontSize: 12, letterSpacing: 1.2)),
                        ),
                        _settingsTile(Icons.lock_rounded, Colors.green, "Encryption & Privacy", "How your data is secured", () {
                          _showInfoSheet(context, "End-to-End Security", Icons.lock_outline, "Your messages and data are securely handled by Google's Firebase infrastructure. We use industry-standard encryption in transit and at rest to ensure your conversations remain private.", Colors.green);
                        }),
                        Divider(height: 1, color: ZapColors.dividerColor),
                        _settingsTile(Icons.privacy_tip_rounded, Colors.blue, "Data Protection", "Our data protection policy", () {
                          _showInfoSheet(context, "Data Protection", Icons.privacy_tip_outlined, "We strictly adhere to data protection guidelines. We do not sell your personal information or chat metadata to third parties. Your generated avatars are completely anonymous.", Colors.blue);
                        }),
                        Divider(height: 1, color: ZapColors.dividerColor),
                        _settingsTile(Icons.info_rounded, Colors.orange, "App Info", "ZapChat v1.0", () {
                          _showInfoSheet(context, "ZapChat v1.0", Icons.info_outline, "Developed proudly using Flutter and Firebase.\n\nFeaturing real-time messaging, group chats, zero-cost avatar generation, and secure cloud syncing.", Colors.orange);
                        }),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
      ),
    );
  }

  Widget _settingsTile(IconData icon, Color color, String title, String subtitle, VoidCallback onTap) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(title, style: const TextStyle(color: ZapColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle, style: const TextStyle(color: ZapColors.textMuted, fontSize: 12)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: ZapColors.textMuted),
      onTap: onTap,
    );
  }
}