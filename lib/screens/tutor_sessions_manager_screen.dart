import 'package:flutter/material.dart';

import 'tutor_start_session_screen.dart';

class TutorSessionsManagerScreen extends StatefulWidget {
  const TutorSessionsManagerScreen({super.key});

  @override
  State<TutorSessionsManagerScreen> createState() =>
      _TutorSessionsManagerScreenState();
}

class _TutorSessionsManagerScreenState
    extends State<TutorSessionsManagerScreen> {
  final List _sessions = [
    {
      'id': '1',
      'student': 'Alex Rivera',
      'subject': 'Flutter & Dart Mobile Development',
      'date': 'Nov 28, 2026',
      'time': '10:00 AM - 11:30 AM',
      'status': 'Upcoming',
    },
    {
      'id': '2',
      'student': 'Maria Santos',
      'subject': 'Calculus & Advanced Math',
      'date': 'Nov 30, 2026',
      'time': '2:00 PM - 3:00 PM',
      'status': 'Upcoming',
    },
    {
      'id': '3',
      'student': 'Clara Cruz',
      'subject': 'Flutter & Dart Mobile Development',
      'date': 'Nov 20, 2026',
      'time': '1:00 PM - 2:00 PM',
      'status': 'Completed',
    },
  ];

  void _editSession(Map<String, String> session) {
    final subjectController = TextEditingController(text: session['subject']);
    final dateController = TextEditingController(text: session['date']);
    final timeController = TextEditingController(text: session['time']);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Session Details'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: subjectController,
                decoration: const InputDecoration(
                  labelText: 'Subject / Topic',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: dateController,
                decoration: const InputDecoration(
                  labelText: 'Date',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: timeController,
                decoration: const InputDecoration(
                  labelText: 'Time Slot',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
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
              setState(() {
                session['subject'] = subjectController.text.trim().isEmpty
                    ? session['subject']!
                    : subjectController.text.trim();
                session['date'] = dateController.text.trim().isEmpty
                    ? session['date']!
                    : dateController.text.trim();
                session['time'] = timeController.text.trim().isEmpty
                    ? session['time']!
                    : timeController.text.trim();
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Session updated.')));
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _startSession(Map<String, String> session) async {
    final completed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => TutorStartSessionScreen(session: session),
      ),
    );

    if (completed == true && mounted) {
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Session marked as Completed.')),
      );
    } else if (mounted) {
      setState(() {});
    }
  }

  void _cancelAndProposeSchedule(Map<String, String> session) {
    final proposedDateController = TextEditingController();
    final proposedTimeController = TextEditingController();
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel & Propose New Schedule'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Cancelling session with ${session['student']}. Propose an alternative slot:',
                style: const TextStyle(fontSize: 13, color: Colors.black87),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: proposedDateController,
                decoration: const InputDecoration(
                  labelText: 'Proposed Date',
                  hintText: 'e.g., Dec 03, 2026',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: proposedTimeController,
                decoration: const InputDecoration(
                  labelText: 'Proposed Time',
                  hintText: 'e.g., 3:00 PM - 4:30 PM',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: reasonController,
                decoration: const InputDecoration(
                  labelText: 'Reason (Optional)',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Keep Session',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              final newDate = proposedDateController.text.trim();
              final newTime = proposedTimeController.text.trim();

              setState(() {
                if (newDate.isNotEmpty && newTime.isNotEmpty) {
                  session['date'] = newDate;
                  session['time'] = newTime;
                  session['status'] = 'Upcoming';
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Cancelled previous slot. Proposed $newDate ($newTime).',
                      ),
                    ),
                  );
                } else {
                  _sessions.remove(session);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Session cancelled.')),
                  );
                }
              });
              Navigator.pop(context);
            },
            child: const Text('Cancel & Propose'),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionTabList(String statusFilter) {
    final filtered = _sessions
        .where((s) => s['status'] == statusFilter)
        .toList();

    if (filtered.isEmpty) {
      return Center(
        child: Text(
          'No $statusFilter sessions.',
          style: TextStyle(color: Colors.grey.shade600, fontSize: 15),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final session = filtered[index];
        final isUpcoming = session['status'] == 'Upcoming';
        final badgeColor = isUpcoming ? Colors.indigo : Colors.teal;

        return Card(
          elevation: 1,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        session['subject']!,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: badgeColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        session['status']!,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: badgeColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(
                      Icons.person_outline,
                      size: 18,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 8),
                    Text('Tutee: ${session['student']}'),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_outlined,
                      size: 18,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 8),
                    Text('${session['date']}  •  ${session['time']}'),
                  ],
                ),
                const Divider(height: 22),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.end,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () => _editSession(session),
                      icon: const Icon(Icons.edit_outlined, size: 16),
                      label: const Text('Edit'),
                    ),
                    if (isUpcoming) ...[
                      OutlinedButton.icon(
                        onPressed: () => _cancelAndProposeSchedule(session),
                        icon: const Icon(Icons.event_repeat_outlined, size: 16),
                        label: const Text('Cancel / Propose'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.redAccent,
                          side: const BorderSide(color: Colors.redAccent),
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => _startSession(session),
                        icon: const Icon(Icons.play_arrow_rounded, size: 18),
                        label: const Text('Start Session'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: AppBar(
          title: const Text('Sessions'),
          backgroundColor: Colors.indigo,
          foregroundColor: Colors.white,
          bottom: const TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(text: 'Upcoming'),
              Tab(text: 'Completed'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildSessionTabList('Upcoming'),
            _buildSessionTabList('Completed'),
          ],
        ),
      ),
    );
  }
}