import 'package:flutter/material.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  String _selectedPeriod = "Week"; // "Week", "Month", "Year"

  // Weekly data
  final List<double> _weeklyExpenses = [240, 150, 480, 90, 310, 600, 180];
  final List<String> _weeklyDays = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];

  // Monthly data
  final List<double> _monthlyExpenses = [1200, 1800, 950, 2200];
  final List<String> _monthlyWeeks = ["Week 1", "Week 2", "Week 3", "Week 4"];

  // Category breakdown data
  final List<Map<String, dynamic>> _categories = [
    {
      "name": "Food & Dining",
      "percent": 35,
      "amount": "GHS 480.00",
      "icon": Icons.fastfood,
      "color": const Color(0xFFFF8008),
    },
    {
      "name": "Shopping",
      "percent": 25,
      "amount": "GHS 342.90",
      "icon": Icons.shopping_bag,
      "color": const Color(0xFF00C9FF),
    },
    {
      "name": "Entertainment",
      "percent": 22,
      "amount": "GHS 300.00",
      "icon": Icons.movie,
      "color": const Color(0xFFFF416C),
    },
    {
      "name": "Transport",
      "percent": 18,
      "amount": "GHS 246.80",
      "icon": Icons.directions_car,
      "color": const Color(0xFF11998E),
    },
  ];

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF0A6CFF);
    const successGreen = Color(0xFF3CC173);
    const failRed = Color(0xFFFF4D4D);

    // Determine current chart data
    final chartValues = _selectedPeriod == "Week" ? _weeklyExpenses : _monthlyExpenses;
    final chartLabels = _selectedPeriod == "Week" ? _weeklyDays : _monthlyWeeks;
    final double maxVal = chartValues.fold(1.0, (prev, element) => element > prev ? element : prev);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FF),
      appBar: AppBar(
        title: const Text(
          "Analytics",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: primaryBlue,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Period Selector Toggle
            Center(
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _periodButton("Week"),
                    _periodButton("Month"),
                    _periodButton("Year"),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 25),

            // Chart Card Container
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Total Spending",
                            style: TextStyle(color: Colors.grey, fontSize: 14),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _selectedPeriod == "Week" ? "GHS 2,050.00" : "GHS 6,150.00",
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF1E2843),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: successGreen.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.arrow_downward, size: 14, color: successGreen),
                            SizedBox(width: 4),
                            Text(
                              "12.4%",
                              style: TextStyle(
                                color: successGreen,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),

                  // The Interactive Bar Chart
                  SizedBox(
                    height: 180,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: List.generate(chartValues.length, (idx) {
                        double normalizedHeight = (chartValues[idx] / maxVal) * 140;
                        if (normalizedHeight < 15) normalizedHeight = 15;

                        return Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              "GHS ${chartValues[idx].toInt()}",
                              style: TextStyle(
                                fontSize: 9,
                                color: Colors.grey.shade500,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              width: _selectedPeriod == "Week" ? 22 : 40,
                              height: normalizedHeight,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF00C6FF), primaryBlue],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              chartLabels[idx],
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E2843),
                              ),
                            ),
                          ],
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // Income / Expense summary Row
            Row(
              children: [
                Expanded(
                  child: _statSummaryCard(
                    title: "Income",
                    amount: "GHS 7,500.00",
                    color: successGreen,
                    icon: Icons.arrow_upward,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: _statSummaryCard(
                    title: "Expenses",
                    amount: "GHS 2,050.00",
                    color: failRed,
                    icon: Icons.arrow_downward,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            const Text(
              "Expense Breakdown",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E2843),
              ),
            ),
            const SizedBox(height: 15),

            // Categories list
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final cat = _categories[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: cat["color"].withOpacity(0.12),
                        child: Icon(cat["icon"], color: cat["color"]),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  cat["name"],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: Color(0xFF1E2843),
                                  ),
                                ),
                                Text(
                                  cat["amount"],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 15,
                                    color: Color(0xFF1E2843),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Stack(
                              children: [
                                Container(
                                  height: 6,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                FractionallySizedBox(
                                  widthFactor: cat["percent"] / 100,
                                  child: Container(
                                    height: 6,
                                    decoration: BoxDecoration(
                                      color: cat["color"],
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 15),
                      Text(
                        "${cat["percent"]}%",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade700,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _periodButton(String period) {
    final bool isSelected = _selectedPeriod == period;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPeriod = period;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          period,
          style: TextStyle(
            color: isSelected ? const Color(0xFF0A6CFF) : Colors.grey.shade600,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _statSummaryCard({
    required String title,
    required String amount,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(0.12),
            radius: 20,
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(height: 4),
              Text(
                amount,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E2843),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
