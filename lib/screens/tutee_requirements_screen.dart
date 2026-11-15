import 'package:flutter/material.dart';

import 'tutee_dashboard.dart';

class TuteeRequirementsScreen extends StatefulWidget {
  final String userName;

  const TuteeRequirementsScreen({super.key, required this.userName});

  @override
  State<TuteeRequirementsScreen> createState() =>
      _TuteeRequirementsScreenState();
}

class _TuteeRequirementsScreenState extends State<TuteeRequirementsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _goalsController = TextEditingController();
  final _targetSubjectsController = TextEditingController();
  String _selectedLevel = 'High School';
  bool _isLoading = false;

  final List<String> _academicLevels = [
    'Elementary',
    'High School',
    'College / University',
    'Lifelong Learner',
  ];

  @override
  void dispose() {
    _goalsController.dispose();
    _targetSubjectsController.dispose();
    super.dispose();
  }

  void _submitTuteeRequirements() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // Simulate network submission upload
      Future.delayed(const Duration(seconds: 2), () {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
        });

        // Redirect to Tutee Dashboard
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => TuteeDashboard(userName: widget.userName),
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const accentColor = Colors.teal;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Tutee Profile Setup'),
        backgroundColor: accentColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 450),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Icon(
                      Icons.school_outlined,
                      size: 56,
                      color: accentColor,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Tell Us What You Want to Learn',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Help us match you with the ideal tutors based on your learning targets and academic background.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Academic Level Dropdown
                    DropdownButtonFormField<String>(
                      value: _selectedLevel,
                      decoration: InputDecoration(
                        labelText: 'Current Education / Skill Level',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      items: _academicLevels.map((level) {
                        return DropdownMenuItem(
                          value: level,
                          child: Text(level),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedLevel = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // Target Subjects
                    TextFormField(
                      controller: _targetSubjectsController,
                      decoration: InputDecoration(
                        labelText: 'Subjects You Want to Learn (e.g. Physics, Flutter)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter subjects you want to learn';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Learning Goals
                    TextFormField(
                      controller: _goalsController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText:
                            'Your Learning Goals / What you hope to achieve',
                        alignLabelWithHint: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please describe your goals';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),

                    // Submit Button
                    SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submitTuteeRequirements,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accentColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Save Profile & Continue',
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
      ),
    );
  }
}
