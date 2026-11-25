import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'tutor_requirements_screen.dart';

class RoleSelectionScreen extends StatefulWidget {
  final String userName;

  const RoleSelectionScreen({super.key, required this.userName});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  final _nameController = TextEditingController();

  String? _selectedRole;
  String? _selectedUserType;

  bool _isLoading = false;
  bool _profileCreated = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _confirmSelection() async {
    if (_isLoading || _profileCreated) return;

    if (_selectedRole == null) {
      _showMessage('Please select an account role.');
      return;
    }

    if (_selectedRole == 'tutee' && _selectedUserType == null) {
      _showMessage('Please select your Tutee classification.');
      return;
    }

    final fullName = widget.userName.trim().isNotEmpty
        ? widget.userName.trim()
        : _nameController.text.trim();

    if (fullName.isEmpty) {
      _showMessage('Please enter your full name.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final supabase = Supabase.instance.client;

      // Save the full name if the account has no name metadata.
      if (widget.userName.trim().isEmpty) {
        await supabase.auth.updateUser(
          UserAttributes(data: {'full_name': fullName}),
        );
      }

      // Create the user's profile through the secured database RPC.
      await supabase.rpc(
        'create_user_profile',
        params: {
          'p_role': _selectedRole,
          'p_user_type': _selectedRole == 'tutee' ? _selectedUserType : null,
        },
      );

      if (!mounted) return;

if (_selectedRole == 'tutor') {
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      builder: (context) => TutorRequirementsScreen(
        userName: fullName,
      ),
    ),
  );
  return;
}

setState(() {
  _profileCreated = true;
});

_showMessage('Your SkillBridge profile has been created successfully.');
    } on AuthException catch (error) {
      if (!mounted) return;
      _showMessage(error.message, isError: true);
    } catch (error) {
      if (!mounted) return;
      _showMessage('Unable to create your profile: $error', isError: true);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasName = widget.userName.trim().isNotEmpty;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(
                    Icons.auto_awesome_rounded,
                    size: 48,
                    color: Colors.indigo,
                  ),
                  const SizedBox(height: 16),

                  const Text(
                    'Welcome to SkillBridge!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Colors.indigo,
                    ),
                  ),
                  const SizedBox(height: 8),

                  Text(
                    'Hello ${hasName ? widget.userName : "there"}! '
                    'How do you plan to use SkillBridge today?',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 15, color: Colors.grey.shade700),
                  ),
                  const SizedBox(height: 28),

                  if (!hasName) ...[
                    TextField(
                      controller: _nameController,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        labelText: 'Full Name',
                        prefixIcon: Icon(Icons.person_outline),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  _buildRoleCard(
                    roleKey: 'tutor',
                    title: 'Become a Tutor',
                    description:
                        'Share your knowledge, mentor students, '
                        'and earn by teaching skills you love.',
                    icon: Icons.psychology_rounded,
                    accentColor: Colors.indigo,
                  ),

                  const SizedBox(height: 16),

                  _buildRoleCard(
                    roleKey: 'tutee',
                    title: 'Become a Tutee',
                    description:
                        'Learn new skills, connect with mentors, '
                        'and achieve your learning goals.',
                    icon: Icons.menu_book_rounded,
                    accentColor: Colors.teal,
                  ),

                  if (_selectedRole == 'tutee') ...[
                    const SizedBox(height: 24),

                    const Text(
                      'Tutee Classification',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),

                    Text(
                      'Select the classification that applies to you.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 12),

                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        ChoiceChip(
                          label: const Text('Student'),
                          selected: _selectedUserType == 'student',
                          onSelected: _isLoading
                              ? null
                              : (selected) {
                                  setState(() {
                                    _selectedUserType = selected
                                        ? 'student'
                                        : null;
                                  });
                                },
                        ),
                        ChoiceChip(
                          label: const Text('Non-student'),
                          selected: _selectedUserType == 'non_student',
                          onSelected: _isLoading
                              ? null
                              : (selected) {
                                  setState(() {
                                    _selectedUserType = selected
                                        ? 'non_student'
                                        : null;
                                  });
                                },
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 32),

                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed:
                          _selectedRole != null &&
                              !_isLoading &&
                              !_profileCreated
                          ? _confirmSelection
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.grey.shade300,
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
                          : Text(
                              _profileCreated ? 'Profile Created' : 'Continue',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard({
    required String roleKey,
    required String title,
    required String description,
    required IconData icon,
    required Color accentColor,
  }) {
    final isSelected = _selectedRole == roleKey;

    return InkWell(
      onTap: _isLoading || _profileCreated
          ? null
          : () {
              setState(() {
                _selectedRole = roleKey;

                if (roleKey == 'tutor') {
                  _selectedUserType = null;
                }
              });
            },
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected
              ? accentColor.withValues(alpha: 0.08)
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? accentColor : Colors.grey.shade300,
            width: isSelected ? 2.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected
                    ? accentColor
                    : accentColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 32,
                color: isSelected ? Colors.white : accentColor,
              ),
            ),
            const SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? accentColor : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            Icon(
              isSelected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: isSelected ? accentColor : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}
