import 'package:flutter/material.dart';

import 'tutor_manage_subjects_screen.dart';
import 'tutor_edit_profile_screen.dart';
import 'tutor_manage_schedule_screen.dart';

class TutorDashboard extends StatefulWidget {
  final String userName;

  const TutorDashboard({super.key, required this.userName});

  @override
  State<TutorDashboard> createState() => _TutorDashboardState();
}

class _TutorDashboardState extends State<TutorDashboard> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    // List of tab views for the Tutor
    final List<Widget> _pages = [
      _TutorHomeTab(userName: widget.userName),
      const _TutorSessionsTab(),
      _TutorProfileTab(userName: widget.userName),
    ];

    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.indigo,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month_rounded),
            label: 'Sessions',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------
// TUTOR HOME TAB
// -----------------------------------------
class _TutorHomeTab extends StatelessWidget {
  final String userName;

  const _TutorHomeTab({required this.userName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('SkillBridge - Tutor Portal'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome back, ${userName.isNotEmpty ? userName : "Tutor"}! 👨‍🏫',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Here is an overview of your tutoring activity.',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),

            // Metrics / Stats Row
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    title: 'Active Students',
                    value: '0',
                    icon: Icons.people_alt_outlined,
                    color: Colors.indigo,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildMetricCard(
                    title: 'Total Earnings',
                    value: '\$0.00',
                    icon: Icons.payments_outlined,
                    color: Colors.teal,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            const Text(
              'Quick Actions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildActionTile(
              icon: Icons.add_circle_outline,
              title: 'Create New Subject',
              subtitle: 'Publish a new subject or skill you want to teach',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TutorManageSubjectsScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            _buildActionTile(
              icon: Icons.access_time_rounded,
              title: 'Update Schedule & Availability',
              subtitle: 'Set open slots for upcoming mentorship sessions',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TutorManageScheduleScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 16),
          Text(
            value,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.indigo, size: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------
// TUTOR SESSIONS & PROFILE TABS (Placeholders)
// -----------------------------------------
class _TutorSessionsTab extends StatelessWidget {
  const _TutorSessionsTab();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Sessions'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text(
          'No upcoming sessions scheduled yet.',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      ),
    );
  }
}

class _TutorProfileTab extends StatefulWidget {
  final String userName;

  const _TutorProfileTab({required this.userName});

  @override
  State<_TutorProfileTab> createState() => _TutorProfileTabState();
}

class _TutorProfileTabState extends State<_TutorProfileTab> {
  late String _currentName;

  @override
  void initState() {
    super.initState();
    _currentName = widget.userName;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Tutor Profile'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Center(
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.indigo,
                child: Icon(Icons.person, size: 50, color: Colors.white),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _currentName.isNotEmpty ? _currentName : 'Tutor User',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'tutor@skillbridge.com',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 32),

            // Edit Profile Option Tile
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: const Icon(Icons.edit_outlined, color: Colors.indigo),
                title: const Text(
                  'Edit Profile Information',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: const Text('Update your name, bio, and hourly rate'),
                trailing: const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey,
                ),
                onTap: () async {
                  final updatedName = await Navigator.push<String>(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          TutorEditProfileScreen(currentName: _currentName),
                    ),
                  );

                  if (updatedName != null) {
                    setState(() {
                      _currentName = updatedName;
                    });
                  }
                },
              ),
            ),
            const SizedBox(height: 12),
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: const Icon(Icons.logout, color: Colors.redAccent),
                title: const Text(
                  'Log Out',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.redAccent,
                  ),
                ),
                onTap: () {
                  // Handle logout navigation
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
