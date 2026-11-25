import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

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

  PlatformFile? _selectedFile;
  bool _isLoading = false;

  @override
  void dispose() {
    _bioController.dispose();
    _subjectsController.dispose();
    _rateController.dispose();
    super.dispose();
  }

  Future<void> _pickDocument() async {
  try {
    final file = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );

    if (file == null) return;

    final fileSize = file.lengthSync() ?? await file.length();

    if (fileSize == null) {
      throw Exception('Unable to determine file size.');
    }

    if (fileSize > 10 * 1024 * 1024) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('File must not exceed 10 MB.'),
        ),
      );
      return;
    }

    // Check that the selected file can be read.
    await file.readAsBytes();

    if (!mounted) return;

    setState(() {
      _selectedFile = file;
    });
  } catch (e) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('File selection failed: $e'),
      ),
    );
  }
}

  void _submitTutorRequirements() {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select your verification document.'),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'File selection is working. Database submission is the next step.',
        ),
      ),
    );
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
            padding: const EdgeInsets.all(24),
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
                      'Provide your teaching background and supporting documents for verification.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 32),

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

                    TextFormField(
                      controller: _subjectsController,
                      decoration: InputDecoration(
                        labelText: 'Subjects / Skills to Teach',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your subjects or skills';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _rateController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Expected Hourly Rate (₱ / hour)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      validator: (value) {
                        final rate = double.tryParse(value?.trim() ?? '');

                        if (rate == null || rate < 0) {
                          return 'Enter a valid hourly rate';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Verification Document',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Select a valid ID or supporting document. PDF, JPG, or PNG. Maximum 10 MB.',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Icon(
                                Icons.upload_file_rounded,
                                color: accentColor,
                                size: 30,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _selectedFile?.name ??
                                      'No file selected',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 13),
                                ),
                              ),
                              TextButton(
                                onPressed: _pickDocument,
                                child: const Text(
                                  'Browse',
                                  style: TextStyle(color: accentColor),
                                ),
                              ),
                            ],
                          ),
                          if (_selectedFile != null)
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton.icon(
                                onPressed: () {
                                  setState(() {
                                    _selectedFile = null;
                                  });
                                },
                                icon: const Icon(Icons.delete_outline),
                                label: const Text('Remove file'),
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.red,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        onPressed:
                            _isLoading ? null : _submitTutorRequirements,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accentColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
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
      ),
    );
  }
}
