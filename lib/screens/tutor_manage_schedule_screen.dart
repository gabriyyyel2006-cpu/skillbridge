import 'package:flutter/material.dart';

class TutorManageScheduleScreen extends StatefulWidget {
  const TutorManageScheduleScreen({super.key});

  @override
  State<TutorManageScheduleScreen> createState() => _TutorManageScheduleScreenState();
}

class _TutorManageScheduleScreenState extends State<TutorManageScheduleScreen> {
  // Initial list of schedule availability slots
  final List<Map<String, String>> _schedules = [
    {'day': 'Monday', 'time': '9:00 AM - 11:00 AM'},
    {'day': 'Wednesday', 'time': '2:00 PM - 5:00 PM'},
    {'day': 'Friday', 'time': '10:00 AM - 12:00 PM'},
  ];

  String _selectedDay = 'Monday';
  final List<String> _daysOfWeek = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
  
  final TextEditingController _timeController = TextEditingController();

  @override
  void dispose() {
    _timeController.dispose();
    super.dispose();
  }

  // Dialog to Add or Edit a Schedule Slot
  void _showScheduleDialog({Map<String, String>? existingSlot, int? index}) {
    if (existingSlot != null) {
      _selectedDay = existingSlot['day']!;
      _timeController.text = existingSlot['time']!;
    } else {
      _selectedDay = 'Monday';
      _timeController.clear();
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Text(existingSlot == null ? 'Add Availability Slot' : 'Edit Availability Slot'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DropdownButtonFormField<String>(
                  value: _selectedDay,
                  decoration: const InputDecoration(
                    labelText: 'Day of the Week',
                    border: OutlineInputBorder(),
                  ),
                  items: _daysOfWeek.map((day) {
                    return DropdownMenuItem(value: day, child: Text(day));
                  }).toList(),
                  onChanged: (value) {
                    setDialogState(() {
                      _selectedDay = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _timeController,
                  decoration: const InputDecoration(
                    labelText: 'Time Range',
                    hintText: 'e.g., 1:00 PM - 4:00 PM',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
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
                  final timeText = _timeController.text.trim();
                  if (timeText.isNotEmpty) {
                    setState(() {
                      if (existingSlot == null) {
                        _schedules.add({'day': _selectedDay, 'time': timeText});
                      } else {
                        _schedules[index!] = {'day': _selectedDay, 'time': timeText};
                      }
                    });
                    Navigator.pop(context);
                  }
                },
                child: Text(existingSlot == null ? 'Add' : 'Save'),
              ),
            ],
          );
        },
      ),
    );
  }

  // Remove Schedule Slot
  void _removeSchedule(int index) {
    setState(() {
      _schedules.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Availability slot removed')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Manage Schedule & Availability'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: _schedules.isEmpty
          ? const Center(
              child: Text(
                'No availability slots set. Click "+" below to add one.',
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: _schedules.length,
              itemBuilder: (context, index) {
                final slot = _schedules[index];
                return Card(
                  elevation: 1,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.indigo.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.schedule, color: Colors.indigo),
                    ),
                    title: Text(
                      slot['day']!,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    subtitle: Text(
                      slot['time']!,
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Edit Button
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, color: Colors.blueGrey),
                          onPressed: () => _showScheduleDialog(
                            existingSlot: slot,
                            index: index,
                          ),
                        ),
                        // Remove Button
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                          onPressed: () => _removeSchedule(index),
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
        onPressed: () => _showScheduleDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Add Slot'),
      ),
    );
  }
}