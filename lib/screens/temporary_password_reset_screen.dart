import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TemporaryPasswordResetScreen extends StatefulWidget {
  const TemporaryPasswordResetScreen({super.key});

  @override
  State<TemporaryPasswordResetScreen> createState() =>
      _TemporaryPasswordResetScreenState();
}

class _TemporaryPasswordResetScreenState
    extends State<TemporaryPasswordResetScreen> {
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _loading = false;
  bool _obscurePassword = true;
  String? _message;
  bool _success = false;

  Future<void> _updatePassword() async {
    final password = _passwordController.text;
    final confirm = _confirmController.text;

    if (password.length < 8) {
      setState(() => _message = 'Password must be at least 8 characters.');
      return;
    }

    if (password != confirm) {
      setState(() => _message = 'Passwords do not match.');
      return;
    }

    setState(() {
      _loading = true;
      _message = null;
    });

    try {
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(password: password),
      );

      if (!mounted) return;

      setState(() {
        _success = true;
        _message = 'Password updated successfully. You may now sign in.';
      });
    } on AuthException catch (error) {
      if (!mounted) return;
      setState(() => _message = error.message);
    } catch (error) {
      if (!mounted) return;
      setState(() => _message = 'Unable to update password. Please try again.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Icon(Icons.lock_reset, size: 48),
                    const SizedBox(height: 16),
                    const Text(
                      'Reset Admin Password',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),
                    if (!_success) ...[
                      TextField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: 'New password',
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _confirmController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Confirm new password',
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _loading ? null : _updatePassword,
                        child: Text(
                          _loading ? 'Updating...' : 'Update Password',
                        ),
                      ),
                    ],
                    if (_message != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        _message!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _success ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
