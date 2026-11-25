
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'screens/login_screen.dart';
import 'screens/role_selection_screen.dart';
import 'screens/temporary_password_reset_screen.dart';
import 'screens/tutee_dashboard.dart';
import 'screens/tutor_dashboard.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://sbfrxuyoexbcidkutzpv.supabase.co',
    publishableKey: 'sb_publishable_mlpX2Fa54NarPBAMg5u-1w_rTqtlOey',
  );

  runApp(const SkillBridgeApp());
}

class SkillBridgeApp extends StatelessWidget {
  const SkillBridgeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SkillBridge',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        useMaterial3: true,
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
        ),
      ),
      home: const TemporaryAuthGate(),
    );
  }
}

class TemporaryAuthGate extends StatefulWidget {
  const TemporaryAuthGate({super.key});

  @override
  State<TemporaryAuthGate> createState() => _TemporaryAuthGateState();
}

class _TemporaryAuthGateState extends State<TemporaryAuthGate> {
  late Future<Widget> _initialScreen;

  bool _showResetScreen = false;
  StreamSubscription<AuthState>? _authSubscription;

  final supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();

    _initialScreen = _resolveInitialScreen();

    _authSubscription =
        supabase.auth.onAuthStateChange.listen((data) {
      if (!mounted) return;

      if (data.event == AuthChangeEvent.passwordRecovery) {
        setState(() {
          _showResetScreen = true;
        });
      }

      if (data.event == AuthChangeEvent.signedOut) {
        setState(() {
          _showResetScreen = false;
          _initialScreen = Future.value(const LoginScreen());
        });
      }
    });
  }

  Future<Widget> _resolveInitialScreen() async {
    final user = supabase.auth.currentUser;

    if (user == null) {
      return const LoginScreen();
    }

    try {
      // Check Admin membership first.
      final adminRecord = await supabase
          .from('admin_users')
          .select('id')
          .eq('id', user.id)
          .maybeSingle();

      if (adminRecord != null) {
        return const AdminAccessPendingScreen();
      }

      // Retrieve the user's application profile.
      final profile = await supabase
          .from('profiles')
          .select('id, role, full_name')
          .eq('id', user.id)
          .maybeSingle();

      final userName =
          (profile?['full_name'] ??
                  user.userMetadata?['full_name'] ??
                  'User')
              .toString();

      if (profile == null) {
        return RoleSelectionScreen(userName: userName);
      }

      final role = profile['role']?.toString().toLowerCase();

      if (role == 'tutee') {
        return TuteeDashboard(userName: userName);
      }

      if (role == 'tutor') {
        return TutorDashboard(userName: userName);
      }

      return const AuthenticationErrorScreen(
        message: 'Your account has an invalid role. Please contact support.',
      );
    } catch (error) {
      return AuthenticationErrorScreen(
        message: 'Unable to load your account. Please try again.\n$error',
      );
    }
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_showResetScreen) {
      return const TemporaryPasswordResetScreen();
    }

    return FutureBuilder<Widget>(
      future: _initialScreen,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return const AuthenticationErrorScreen(
            message: 'Something went wrong while opening SkillBridge.',
          );
        }

        return snapshot.data!;
      },
    );
  }
}

// Temporary screen until the actual Admin Dashboard is implemented.
class AdminAccessPendingScreen extends StatelessWidget {
  const AdminAccessPendingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SkillBridge Admin'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () async {
              await Supabase.instance.client.auth.signOut();
            },
            icon: const Icon(Icons.logout),
            tooltip: 'Sign out',
          ),
        ],
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.admin_panel_settings,
                size: 64,
                color: Colors.indigo,
              ),
              SizedBox(height: 16),
              Text(
                'Admin access verified',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'The Admin Dashboard has not been connected yet.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AuthenticationErrorScreen extends StatelessWidget {
  final String message;

  const AuthenticationErrorScreen({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                size: 55,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                message,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  await Supabase.instance.client.auth.signOut();
                },
                child: const Text('Sign out'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
