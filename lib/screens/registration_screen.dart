import 'package:flutter/material.dart';
import 'package:flash_chat/utilities/neon_theme.dart';
import 'package:flash_chat/widgets/input_box.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'dart:ui' as ui;

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _auth = FirebaseAuth.instance;
  String email = "";
  String password = "";
  bool showSpinner = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NeonBackground(
        child: ModalProgressHUD(
          inAsyncCall: showSpinner,
          progressIndicator: const CircularProgressIndicator(
            color: ZapColors.neonCyan,
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 40),
                  // Back button
                  Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: ZapColors.cardDark,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: ZapColors.dividerColor),
                        ),
                        child: const Icon(Icons.arrow_back_ios_new, color: ZapColors.neonCyan, size: 18),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  // Logo with blurred lock behind
                  Center(
                    child: SizedBox(
                      width: 200,
                      height: 200,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Blurred Aqua Lock
                          Icon(
                            Icons.lock,
                            size: 180,
                            color: ZapColors.neonCyan.withValues(alpha: 0.25),
                          ),
                          Positioned.fill(
                            child: BackdropFilter(
                              filter: ui.ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                              child: Container(color: Colors.transparent),
                            ),
                          ),
                          // Lightning Logo
                          const AnimatedLightningLogo(size: 100),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Center(
                    child: HeroGradientText(
                      text: 'Create Account',
                      fontSize: 32,
                      animate: false,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Center(
                    child: Text(
                      'Create your account',
                      style: TextStyle(color: ZapColors.textMuted, fontSize: 14),
                    ),
                  ),
                  const SizedBox(height: 44),
                  // Input fields
                  InputBox(
                    placeholderContent: "Enter your Email",
                    varStore: (value) {
                      email = value;
                    },
                  ),
                  const SizedBox(height: 16.0),
                  InputBox(
                    placeholderContent: "Enter your password",
                    varStore: (value) {
                      password = value;
                    },
                  ),
                  const SizedBox(height: 32.0),
                  NeonButton(
                    text: 'Register',
                    isLoading: showSpinner,
                    onPressed: () async {
                      setState(() {
                        showSpinner = true;
                      });
                      try {
                        await _auth.createUserWithEmailAndPassword(
                            email: email, password: password);
                            
                        // Redirect to profile setup instead of chat
                        if (context.mounted) {
                          Navigator.pushNamed(context, '/profile_setup');
                        }

                        setState(() {
                          showSpinner = false;
                        });
                      } catch (e) {
                        print(e);
                        // Stop the spinner if there is an error
                        setState(() {
                          showSpinner = false;
                        });
                        
                        // Optional: Show error to user via SnackBar
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(e.toString()),
                              backgroundColor: ZapColors.errorRed.withOpacity(0.9),
                            ),
                          );
                        }
                      }
                    },
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Already have an account? ",
                        style: TextStyle(color: ZapColors.textMuted, fontSize: 13),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.pushNamed(context, '/login');
                        },
                        child: const Text(
                          'Log In',
                          style: TextStyle(
                            color: ZapColors.neonCyan,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}