import 'package:flutter/material.dart';

import 'tutor_dashboard.dart';

class TutorRequirementsScreen extends StatefulWidget {
  final String userName;

  const TutorRequirementsScreen({super.key, required this.userName});

  @override
  State<TutorRequirementsScreen> createState() =>
      _TutorRequirementsScreenState();
}

class _TutorRequirementsScreenState extends State<TutorRequirementsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _bioController = TextEditingController();
  final _subjectsController = TextEditingController();
  final _rateController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _bioController.dispose();
    _subjectsController.dispose();
    _rateController.dispose();
    super.dispose();
  }

  void _submitTutorRequirements() {
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

        // Redirect to Tutor Dashboard
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => TutorDashboard(userName: widget.userName),
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const accentColor = Colors.indigo;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Tutor Verification'),
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
                      Icons.verified_user_outlined,
                      size: 56,
                      color: accentColor,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Submit Tutor Credentials',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Please provide your teaching background, expertise, and certifications to start mentoring on SkillBridge.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Professional Bio
                    TextFormField(
                      controller: _bioController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: 'Professional Bio & Experience',
                        alignLabelWithHint: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your professional bio';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Subjects You Can Teach
                    TextFormField(
                      controller: _subjectsController,
                      decoration: InputDecoration(
                        labelText: 'Subjects / Skills to Teach (e.g. Calculus, Python)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter subjects you can teach';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Expected Hourly Rate
                    TextFormField(
                      controller: _rateController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Expected Hourly Rate (\$ / hr)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please specify your hourly rate';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Certificate Upload Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.upload_file_rounded,
                            color: accentColor,
                            size: 32,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Upload Diploma / Valid ID / Resume',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'PDF, JPG, or PNG (Max 5MB)',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Document uploaded successfully!',
                                  ),
                                ),
                              );
                            },
                            child: const Text(
                              'Browse',
                              style: TextStyle(color: accentColor),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Submit Button
                    SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submitTutorRequirements,
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
                                'Submit Credentials & Continue',
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
