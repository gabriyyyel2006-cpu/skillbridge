
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'registration_screen.dart';
import 'role_selection_screen.dart';
import 'tutee_dashboard.dart';
import 'tutor_dashboard.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // LOGIN FUNCTION
  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your email and password.'),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final supabase = Supabase.instance.client;

      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final user = response.user;

      if (user == null) {
        throw Exception('Login failed. Please try again.');
      }

      // CHECK EMAIL VERIFICATION BEFORE DASHBOARD ACCESS
      if (user.emailConfirmedAt == null) {
        await supabase.auth.signOut();

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Your email address is not verified. Please check your inbox and verify your email before logging in.',
            ),
            duration: Duration(seconds: 5),
          ),
        );

        return;
      }

      // CHECK ADMIN MEMBERSHIP FIRST
      final adminRecord = await supabase
          .from('admin_users')
          .select('id')
          .eq('id', user.id)
          .maybeSingle();

      if (adminRecord != null) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Admin access verified. Admin Dashboard integration is pending.',
            ),
          ),
        );

        await supabase.auth.signOut();
        return;
      }

      // FETCH REGULAR USER PROFILE
      final profile = await supabase
          .from('profiles')
          .select('id, role, full_name')
          .eq('id', user.id)
          .maybeSingle();

      if (!mounted) return;

      // HANDLE USERS WITHOUT PROFILES
      if (profile == null) {
        final fullName =
            user.userMetadata?['full_name']?.toString() ?? '';

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => RoleSelectionScreen(
              userName: fullName,
            ),
          ),
        );
        return;
      }

      final role = profile['role']?.toString().toLowerCase();
      final userName = profile['full_name']?.toString() ?? '';

      // ROUTE TO TUTEE DASHBOARD
      if (role == 'tutee') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => TuteeDashboard(
              userName: userName,
            ),
          ),
        );
      }
      // ROUTE TO TUTOR DASHBOARD
      else if (role == 'tutor') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => TutorDashboard(
              userName: userName,
            ),
          ),
        );
      } else {
        throw Exception('Invalid account role.');
      }
    } on AuthException catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Something went wrong: $error'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // FORGOT PASSWORD FUNCTION
  Future<void> _handleForgotPassword() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your email address first.'),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await Supabase.instance.client.auth.resetPasswordForEmail(
        email,
        redirectTo: 'http://localhost:8080',
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Password reset instructions have been sent to your email.',
          ),
        ),
      );
    } on AuthException catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Something went wrong: $error'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // OPEN REGISTRATION SCREEN
  void _openRegistration() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const RegistrationScreen(),
      ),
    );
  }

  // LOGIN UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(
          color: Colors.indigo,
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 16.0,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 450,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(
                    Icons.school_rounded,
                    size: 64,
                    color: Colors.indigo,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Welcome Back!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: Colors.indigo,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Log in to continue your SkillBridge journey',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // EMAIL ADDRESS
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Email Address',
                      prefixIcon: const Icon(
                        Icons.email_outlined,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // PASSWORD
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(
                        Icons.lock_outline,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                    ),
                  ),

                  // FORGOT PASSWORD BUTTON
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _isLoading
                          ? null
                          : _handleForgotPassword,
                      child: const Text('Forgot Password?'),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // LOGIN BUTTON
                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading
                          ? null
                          : _handleLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Log In',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // SIGN UP LINK
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account?",
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 14,
                        ),
                      ),
                      TextButton(
                        onPressed: _isLoading
                            ? null
                            : _openRegistration,
                        child: const Text(
                          'Sign Up',
                          style: TextStyle(
                            color: Colors.indigo,
                            fontWeight: FontWeight.bold,
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
