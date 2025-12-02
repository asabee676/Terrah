import 'package:flutter/material.dart';

class Home extends StatelessWidget {
  final String userName;

  const Home({super.key, required this.userName});

  @override
  Widget build(BuildContext context) {
    // Theme colors
    const blue = Color(0xFF0066FF);
    const lightBlue = Color(0xFFE8F5F7);
    const green = Color(0xFF3CC173);
    const red = Color(0xFFFF4D4D);
    const orange = Color(0xFFFFA726);

    return Scaffold(
      backgroundColor: lightBlue,
      appBar: AppBar(
        backgroundColor: blue,
        elevation: 0,
        title: Text(
          'Hello, $userName!',
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Balance Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: blue,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Balance',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  SizedBox(height: 10),
                  Text(
                    '₵12,345.67',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  LinearProgressIndicator(
                    value: 0.7,
                    color: green,
                    backgroundColor: Colors.white24,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Quick Actions
            const Text(
              'Quick Actions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _quickAction(icon: Icons.send, label: 'Send', color: blue),
                _quickAction(
                  icon: Icons.request_page,
                  label: 'Request',
                  color: green,
                ),
                _quickAction(
                  icon: Icons.account_balance_wallet,
                  label: 'Wallet',
                  color: orange,
                ),
                _quickAction(icon: Icons.more_horiz, label: 'More', color: red),
              ],
            ),
            const SizedBox(height: 20),

            // Remittance Overview Table
            const Text(
              'Remittance Overview',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Table(
              border: TableBorder.all(color: Colors.grey.shade300),
              children: const [
                TableRow(
                  decoration: BoxDecoration(color: Colors.white),
                  children: [
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        'Date',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        'Amount',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        'Status',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                TableRow(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('30 Nov'),
                    ),
                    Padding(padding: EdgeInsets.all(8.0), child: Text('₵500')),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Completed', style: TextStyle(color: green)),
                    ),
                  ],
                ),
                TableRow(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('29 Nov'),
                    ),
                    Padding(padding: EdgeInsets.all(8.0), child: Text('₵200')),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Pending', style: TextStyle(color: orange)),
                    ),
                  ],
                ),
                TableRow(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('28 Nov'),
                    ),
                    Padding(padding: EdgeInsets.all(8.0), child: Text('₵100')),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Failed', style: TextStyle(color: red)),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Budget Overview
            const Text(
              'Budget Overview',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: const [
                  _budgetItem(title: 'Food', progress: 0.6, color: blue),
                  SizedBox(height: 10),
                  _budgetItem(title: 'Transport', progress: 0.4, color: green),
                  SizedBox(height: 10),
                  _budgetItem(title: 'Shopping', progress: 0.8, color: red),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Quick Action Widget
  Widget _quickAction({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        CircleAvatar(
          radius: 25,
          backgroundColor: color,
          child: Icon(icon, color: Colors.white),
        ),
        const SizedBox(height: 5),
        Text(label),
      ],
    );
  }
}

// Budget Item Widget
class _budgetItem extends StatelessWidget {
  final String title;
  final double progress;
  final Color color;

  const _budgetItem({
    required this.title,
    required this.progress,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 5),
        LinearProgressIndicator(
          value: progress,
          color: color,
          backgroundColor: Colors.grey.shade200,
        ),
      ],
    );
  }
}
