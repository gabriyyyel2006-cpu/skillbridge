import 'package:flutter/material.dart';

class TuteeDashboard extends StatefulWidget {
  final String userName;

  const TuteeDashboard({super.key, required this.userName});

  @override
  State<TuteeDashboard> createState() => _TuteeDashboardState();
}

class _TuteeDashboardState extends State<TuteeDashboard> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    // List of tab views for the Tutee
    final List<Widget> _pages = [
      _TuteeHomeTab(userName: widget.userName),
      const _TuteeMyClassesTab(),
      const _TuteeProfileTab(),
    ];

    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.explore_rounded),
            label: 'Explore',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book_rounded),
            label: 'My Classes',
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
// TUTEE HOME / EXPLORE TAB
// -----------------------------------------
class _TuteeHomeTab extends StatelessWidget {
  final String userName;

  const _TuteeHomeTab({required this.userName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('SkillBridge - Learner Hub'),
        backgroundColor: Colors.teal,
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
              'Hello, ${userName.isNotEmpty ? userName : "Learner"}! 📚',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'What new skill or subject would you like to master today?',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),

            // Search Bar Widget
            TextField(
              decoration: InputDecoration(
                hintText: 'Search for expert tutors or subjects...',
                prefixIcon: const Icon(Icons.search, color: Colors.teal),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 32),

            const Text(
              'Featured Options',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildActionTile(
              icon: Icons.supervisor_account_outlined,
              title: 'Browse Expert Tutors',
              subtitle:
                  'Find and connect with verified mentors ready to guide you',
              onTap: () {},
            ),
            const SizedBox(height: 12),
            _buildActionTile(
              icon: Icons.bookmark_added_outlined,
              title: 'My Learning Progress',
              subtitle: 'Check your enrolled modules, hours, and milestones',
              onTap: () {},
            ),
          ],
        ),
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
            Icon(icon, color: Colors.teal, size: 28),
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
// TUTEE CLASSES & PROFILE TABS (Placeholders)
// -----------------------------------------
class _TuteeMyClassesTab extends StatelessWidget {
  const _TuteeMyClassesTab();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Enrolled Classes'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text(
          'You are not enrolled in any classes yet.',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      ),
    );
  }
}

class _TuteeProfileTab extends StatelessWidget {
  const _TuteeProfileTab();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Learner Profile'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text(
          'Manage your learning goals and profile settings here.',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      ),
    );
  }
}
