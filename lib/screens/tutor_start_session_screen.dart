import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TutorStartSessionScreen extends StatefulWidget {
  final Map<String, String> session;

  const TutorStartSessionScreen({super.key, required this.session});

  @override
  State<TutorStartSessionScreen> createState() =>
      _TutorStartSessionScreenState();
}

class _TutorStartSessionScreenState extends State<TutorStartSessionScreen> {
  final List<String> _platforms = ['Google Meet', 'Zoom', 'Messenger', 'Webex'];

  late String _selectedPlatform;
  late TextEditingController _linkController;
  bool _isSessionLive = true;

  @override
  void initState() {
    super.initState();
    _selectedPlatform = _platforms.contains(widget.session['platform'])
        ? widget.session['platform']!
        : 'Google Meet';
    _linkController = TextEditingController(
      text: widget.session['meetingLink'] ?? '',
    );
  }

  @override
  void dispose() {
    _linkController.dispose();
    super.dispose();
  }

  IconData _getPlatformIcon(String platform) {
    switch (platform) {
      case 'Google Meet':
        return Icons.video_call_rounded;
      case 'Zoom':
        return Icons.videocam_rounded;
      case 'Messenger':
        return Icons.chat_bubble_rounded;
      case 'Webex':
        return Icons.groups_rounded;
      default:
        return Icons.link_rounded;
    }
  }

  String _getPlaceholderHint(String platform) {
    switch (platform) {
      case 'Google Meet':
        return 'https://meet.google.com/xxx-xxxx-xxx';
      case 'Zoom':
        return 'https://zoom.us/j/1234567890';
      case 'Messenger':
        return 'https://m.me/your-room-or-chat-link';
      case 'Webex':
        return 'https://company.webex.com/meet/username';
      default:
        return 'https://...';
    }
  }

  void _shareOrCopyLink() {
    final link = _linkController.text.trim();
    if (link.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a meeting link first.')),
      );
      return;
    }

    setState(() {
      widget.session['platform'] = _selectedPlatform;
      widget.session['meetingLink'] = link;
    });

    Clipboard.setData(ClipboardData(text: link));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '$_selectedPlatform link saved and copied for ${widget.session['student']}.',
        ),
      ),
    );
  }

  void _completeSession() {
    final link = _linkController.text.trim();
    setState(() {
      if (link.isNotEmpty) {
        widget.session['platform'] = _selectedPlatform;
        widget.session['meetingLink'] = link;
      }
      widget.session['status'] = 'Completed';
      _isSessionLive = false;
    });

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final student = widget.session['student'] ?? 'Tutee';
    final subject = widget.session['subject'] ?? 'Session';
    final date = widget.session['date'] ?? '';
    final time = widget.session['time'] ?? '';

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Start Session & Share Link'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Live Status Banner
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _isSessionLive
                    ? Colors.teal.shade50
                    : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _isSessionLive
                      ? Colors.teal.shade200
                      : Colors.grey.shade300,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _isSessionLive
                        ? Icons.sensors_rounded
                        : Icons.check_circle_rounded,
                    color: _isSessionLive
                        ? Colors.teal.shade700
                        : Colors.grey.shade700,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _isSessionLive
                          ? 'Session is live — share your meeting link with $student.'
                          : 'Session marked as completed.',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: _isSessionLive
                            ? Colors.teal.shade900
                            : Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Session Summary Card
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subject,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tutee: $student',
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$date  •  $time',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Platform Selection
            const Text(
              'Select Meeting Platform',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _platforms.map((platform) {
                final isSelected = _selectedPlatform == platform;
                return ChoiceChip(
                  avatar: Icon(
                    _getPlatformIcon(platform),
                    size: 18,
                    color: isSelected ? Colors.white : Colors.indigo,
                  ),
                  label: Text(platform),
                  selected: isSelected,
                  selectedColor: Colors.indigo,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                  onSelected: (_) {
                    setState(() {
                      _selectedPlatform = platform;
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Meeting Link Input
            Text(
              '$_selectedPlatform Meeting Link',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _linkController,
              keyboardType: TextInputType.url,
              decoration: InputDecoration(
                hintText: _getPlaceholderHint(_selectedPlatform),
                prefixIcon: Icon(
                  _getPlatformIcon(_selectedPlatform),
                  color: Colors.indigo,
                ),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Save & Copy Link Button
            SizedBox(
              height: 48,
              child: OutlinedButton.icon(
                onPressed: _shareOrCopyLink,
                icon: const Icon(Icons.share_rounded),
                label: const Text('Save & Copy Link to Share'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.indigo,
                  side: const BorderSide(color: Colors.indigo),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Complete Session Button
            SizedBox(
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _completeSession,
                icon: const Icon(Icons.check_circle_outline),
                label: const Text(
                  'Finish & Mark Session Completed',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}