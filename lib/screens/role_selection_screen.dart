import 'package:flutter/material.dart';

import 'tutor_requirements_screen.dart'; // Import tutor requirements
import 'tutee_requirements_screen.dart'; // Import tutee requirements

class RoleSelectionScreen extends StatefulWidget {
  final String userName;

  const RoleSelectionScreen({super.key, required this.userName});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  String? _selectedRole; // 'tutor' or 'tutee'

  void _confirmSelection() {
    if (_selectedRole == null) return;

    // Navigate to the correct separate requirement screen
    if (_selectedRole == 'tutor') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              TutorRequirementsScreen(userName: widget.userName),
        ),
      );
    } else if (_selectedRole == 'tutee') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              TuteeRequirementsScreen(userName: widget.userName),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 24.0,
            ),
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
                    'Hello ${widget.userName.isNotEmpty ? widget.userName : "there"}! How do you plan to use SkillBridge today?',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 15, color: Colors.grey.shade700),
                  ),
                  const SizedBox(height: 32),

                  // Option 1: Tutor Card
                  _buildRoleCard(
                    roleKey: 'tutor',
                    title: 'Become a Tutor',
                    description: 'Share your knowledge, mentor students, and earn by teaching skills you love.',
                    icon: Icons.psychology_rounded,
                    accentColor: Colors.indigo,
                  ),
                  const SizedBox(height: 16),

                  // Option 2: Tutee Card
                  _buildRoleCard(
                    roleKey: 'tutee',
                    title: 'Become a Tutee',
                    description: 'Learn new skills, connect with expert mentors, and achieve your learning goals.',
                    icon: Icons.menu_book_rounded,
                    accentColor: Colors.teal,
                  ),
                  const SizedBox(height: 32),

                  // Continue Button
                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _selectedRole != null
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
                      child: const Text(
                        'Continue',
                        style: TextStyle(
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
      onTap: () {
        setState(() {
          _selectedRole = roleKey;
        });
      },
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? accentColor.withOpacity(0.08) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? accentColor : Colors.grey.shade300,
            width: isSelected ? 2.5 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
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
                color: isSelected ? accentColor : accentColor.withOpacity(0.1),
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
            Radio<String>(
              value: roleKey,
              groupValue: _selectedRole,
              activeColor: accentColor,
              onChanged: (value) {
                setState(() {
                  _selectedRole = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
