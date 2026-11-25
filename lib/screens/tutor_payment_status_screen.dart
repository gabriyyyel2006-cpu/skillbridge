import 'package:flutter/material.dart';

class TutorPaymentStatusScreen extends StatefulWidget {
  final List sessions;
  final void Function(Map<String, String> session, String newStatus)?
  onStatusChanged;

  const TutorPaymentStatusScreen({
    super.key,
    required this.sessions,
    this.onStatusChanged,
  });

  @override
  State<TutorPaymentStatusScreen> createState() =>
      _TutorPaymentStatusScreenState();
}

class _TutorPaymentStatusScreenState extends State<TutorPaymentStatusScreen> {
  Color _getPaymentColor(String status) {
    switch (status) {
      case 'Paid':
        return Colors.green.shade700;
      case 'Pending':
        return Colors.orange.shade800;
      case 'Refunded':
        return Colors.redAccent;
      default:
        return Colors.grey;
    }
  }

  void _changePaymentStatus(Map<String, String> session) {
    String selectedStatus = session['paymentStatus'] ?? 'Pending';
    final List<String> statuses = ['Pending', 'Paid', 'Refunded'];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Update Payment Status'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session['subject'] ?? 'Session',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text('Tutee: ${session['student'] ?? 'Unknown'}'),
                Text('Amount: ${session['amount'] ?? '\$0.00'}'),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedStatus,
                  decoration: const InputDecoration(
                    labelText: 'Payment Status',
                    border: OutlineInputBorder(),
                  ),
                  items: statuses.map((status) {
                    return DropdownMenuItem(value: status, child: Text(status));
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setDialogState(() {
                        selectedStatus = value;
                      });
                    }
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  setState(() {
                    session['paymentStatus'] = selectedStatus;
                  });
                  widget.onStatusChanged?.call(session, selectedStatus);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Payment status updated to $selectedStatus.',
                      ),
                    ),
                  );
                },
                child: const Text('Save'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final paidCount = widget.sessions
        .where((s) => s['paymentStatus'] == 'Paid')
        .length;
    final pendingCount = widget.sessions
        .where((s) => s['paymentStatus'] == 'Pending')
        .length;
    final refundedCount = widget.sessions
        .where((s) => s['paymentStatus'] == 'Refunded')
        .length;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Payment Status'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Expanded(
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Paid',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$paidCount',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Pending',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$pendingCount',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange.shade800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Refunded',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$refundedCount',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.redAccent,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...widget.sessions.map((session) {
            final status = session['paymentStatus'] ?? 'Pending';
            final color = _getPaymentColor(status);

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
                title: Text(
                  session['subject'] ?? 'Session',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  'Tutee: ${session['student'] ?? ''} • ${session['date'] ?? ''}\nAmount: ${session['amount'] ?? '\$0.00'}',
                ),
                isThreeLine: true,
                trailing: InkWell(
                  onTap: () => _changePaymentStatus(session),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}