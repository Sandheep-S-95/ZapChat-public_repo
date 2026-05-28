import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'firebase_options.dart';
import 'utilities/neon_theme.dart';
import 'providers/auth_provider.dart';
import 'screens/welcome_screen.dart';
import 'screens/login_screen.dart';
import 'screens/registration_screen.dart';
import 'screens/profile_setup_screen.dart';
import 'screens/home_screen.dart';
import 'screens/create_group_screen.dart';
import 'screens/profile_edit_screen.dart';
import 'screens/blocked_users_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: ZapColors.deepPurple,
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  // ProviderScope is the root of the Riverpod dependency injection tree.
  runApp(const ProviderScope(child: FlashChat()));
}

class FlashChat extends StatelessWidget {
  const FlashChat({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ZapChat',
      builder: (context, child) {
        return ColoredBox(
          color: Colors.black,
          child: Center(
            child: ClipRect(
              child: SizedBox(width: 500, child: child),
            ),
          ),
        );
      },
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: ZapColors.deepPurple,
        primaryColor: ZapColors.neonCyan,
        colorScheme: const ColorScheme.dark(
          primary: ZapColors.neonCyan,
          secondary: ZapColors.neonCyanDim,
          surface: ZapColors.darkPurple,
          error: ZapColors.errorRed,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(color: ZapColors.neonCyan),
          titleTextStyle: TextStyle(
            color: ZapColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: ZapColors.textPrimary),
          bodyMedium: TextStyle(color: ZapColors.textSecondary),
          bodySmall: TextStyle(color: ZapColors.textMuted),
        ),
        iconTheme: const IconThemeData(color: ZapColors.neonCyan),
        dividerColor: ZapColors.dividerColor,
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: ZapColors.neonCyan,
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: ZapColors.cardDark,
          contentTextStyle: const TextStyle(color: ZapColors.textPrimary),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          behavior: SnackBarBehavior.floating,
        ),
        dialogTheme: DialogThemeData(
          backgroundColor: ZapColors.darkPurple,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          titleTextStyle: const TextStyle(
            color: ZapColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
          contentTextStyle: const TextStyle(
            color: ZapColors.textSecondary,
            fontSize: 15,
          ),
        ),
        bottomSheetTheme: const BottomSheetThemeData(
          backgroundColor: ZapColors.darkPurple,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const _AuthGate(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegistrationScreen(),
        '/profile_setup': (context) => ProfileSetupScreen(),
        '/home': (context) => _AuthGuard(child: HomeScreen()),
        '/create_group': (context) => _AuthGuard(child: CreateGroupScreen()),
        '/profile_edit': (context) => _AuthGuard(child: ProfileEditScreen()),
        '/blocked_users': (context) => const _AuthGuard(child: BlockedUsersScreen()),
      },
    );
  }
}

// ── Auth gate: watches authStateProvider from Riverpod.
// Riverpod caches the stream — no duplicate subscriptions across rebuilds.
class _AuthGate extends ConsumerWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator(color: ZapColors.neonCyan)),
      ),
      error: (_, __) => const WelcomeScreen(),
      data: (user) {
        if (user != null) return const _AuthGuard(child: HomeScreen());
        return const WelcomeScreen();
      },
    );
  }
}

// ── Auth guard: protects routes — kicks user to welcome on sign-out.
class _AuthGuard extends ConsumerWidget {
  final Widget child;
  const _AuthGuard({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator(color: ZapColors.neonCyan)),
      ),
      error: (_, __) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.of(context).pushNamedAndRemoveUntil('/', (_) => false);
        });
        return const Scaffold(
          body: Center(child: CircularProgressIndicator(color: ZapColors.neonCyan)),
        );
      },
      data: (user) {
        if (user == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushNamedAndRemoveUntil('/', (_) => false);
          });
          return const Scaffold(
            body: Center(child: CircularProgressIndicator(color: ZapColors.neonCyan)),
          );
        }
        return child;
      },
    );
  }
}
