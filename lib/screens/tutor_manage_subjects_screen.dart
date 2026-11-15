import 'package:flutter/material.dart';

class TutorManageSubjectsScreen extends StatefulWidget {
  const TutorManageSubjectsScreen({super.key});

  @override
  State<TutorManageSubjectsScreen> createState() =>
      _TutorManageSubjectsScreenState();
}

class _TutorManageSubjectsScreenState extends State<TutorManageSubjectsScreen> {
  // Initial list of subjects/skills
  final List<String> _subjects = [
    'Calculus & Advanced Math',
    'Introduction to Python',
    'Flutter & Dart Mobile Development',
  ];

  final TextEditingController _subjectController = TextEditingController();

  @override
  void dispose() {
    _subjectController.dispose();
    super.dispose();
  }

  // Dialog to Add or Edit a Subject
  void _showSubjectDialog({String? existingSubject, int? index}) {
    if (existingSubject != null) {
      _subjectController.text = existingSubject;
    } else {
      _subjectController.clear();
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          existingSubject == null ? 'Add New Subject' : 'Edit Subject',
        ),
        content: TextField(
          controller: _subjectController,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Subject / Skill Name',
            hintText: 'e.g., Organic Chemistry',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              final text = _subjectController.text.trim();
              if (text.isNotEmpty) {
                setState(() {
                  if (existingSubject == null) {
                    _subjects.add(text); // Add
                  } else {
                    _subjects[index!] = text; // Edit
                  }
                });
                Navigator.pop(context);
              }
            },
            child: Text(existingSubject == null ? 'Add' : 'Save'),
          ),
        ],
      ),
    );
  }

  // Remove Subject
  void _removeSubject(int index) {
    setState(() {
      _subjects.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Subject removed successfully')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Manage Subjects & Skills'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: _subjects.isEmpty
          ? const Center(
              child: Text(
                'No subjects added yet. Click "+" below to add one.',
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: _subjects.length,
              itemBuilder: (context, index) {
                return Card(
                  elevation: 1,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.indigo.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.book_outlined,
                        color: Colors.indigo,
                      ),
                    ),
                    title: Text(
                      _subjects[index],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Edit Button
                        IconButton(
                          icon: const Icon(
                            Icons.edit_outlined,
                            color: Colors.blueGrey,
                          ),
                          onPressed: () => _showSubjectDialog(
                            existingSubject: _subjects[index],
                            index: index,
                          ),
                        ),
                        // Remove Button
                        IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.redAccent,
                          ),
                          onPressed: () => _removeSubject(index),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        onPressed: () => _showSubjectDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Add Subject'),
      ),
    );
  }
}
