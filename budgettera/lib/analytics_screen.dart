import 'dart:math' as math;
import 'package:flutter/material.dart';

// ── Design tokens ───────────────────────────────────────────────
const _kDominant = Color(0xFF007AFF);
const _kComplementary = Color(0xFF00238E);
const _kOffWhite = Color(0xFFE6F4F1);
const _kLightGreen = Color(0xFFDFF7E2);
const _kGreen = Color(0xFF7ED321);
const _kRed = Color(0xFFED251A);

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  // 0 = Daily, 1 = Weekly, 2 = Monthly
  int _selectedTab = 0;

  // Paired [income, expense] per bar (in thousands)
  static const List<List<double>> _dailyData = [
    [47, 17], // Mon
    [90, 56], // Tue
    [50, 83], // Wed
    [73, 32], // Thu
    [65, 10], // Fri
    [10, 30], // Sat
    [30, 50], // Sun  — matches Figma heights roughly
  ];
  static const List<String> _dailyLabels = [
    'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'
  ];

  static const List<List<double>> _weeklyData = [
    [80, 40], [60, 70], [90, 30], [50, 60],
  ];
  static const List<String> _weeklyLabels = [
    'Wk 1', 'Wk 2', 'Wk 3', 'Wk 4'
  ];

  static const List<List<double>> _monthlyData = [
    [70, 50], [85, 60], [60, 40], [90, 70],
    [75, 55], [80, 65], [65, 45], [70, 80],
    [88, 52], [60, 30], [78, 68], [90, 40],
  ];
  static const List<String> _monthlyLabels = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  List<List<double>> get _chartData =>
      [_dailyData, _weeklyData, _monthlyData][_selectedTab];
  List<String> get _chartLabels =>
      [_dailyLabels, _weeklyLabels, _monthlyLabels][_selectedTab];

  final List<String> _tabs = ['Daily', 'Weekly', 'Monthly'];

  // Summary figures
  static const String _totalBalance = 'GHS 2,884.00';
  static const String _totalExpense = 'GHS 1,187.40';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kDominant,
      body: Column(
        children: [
          // ── Blue top section ──────────────────────────────────
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Analytics',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                        Icons.calendar_today_outlined,
                        color: Colors.white,
                        size: 18),
                  ),
                ],
              ),
            ),
          ),

          // ── White card panel ──────────────────────────────────
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(50),
                  topRight: Radius.circular(50),
                ),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Period switcher ─────────────────────────
                    _PeriodSwitcher(
                      tabs: _tabs,
                      selected: _selectedTab,
                      onChanged: (i) => setState(() => _selectedTab = i),
                    ),

                    const SizedBox(height: 30),

                    // ── Income & Expenses bar chart ─────────────
                    _ChartCard(
                      data: _chartData,
                      labels: _chartLabels,
                    ),

                    const SizedBox(height: 24),

                    // ── Balance / Expense summary ───────────────
                    _SummaryRow(
                      balance: _totalBalance,
                      expense: _totalExpense,
                    ),

                    const SizedBox(height: 24),

                    // ── Date range label ────────────────────────
                    const Center(
                      child: Text(
                        'Mon Nov 1, 2024 – Sun Nov 7, 2024',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 15,
                          color: _kComplementary,
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ── Income & Expense donut cards ────────────
                    Row(
                      children: [
                        Expanded(
                          child: _DonutCard(
                            label: 'Income',
                            percent: 50,
                            color: _kDominant,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: _DonutCard(
                            label: 'Expenses',
                            percent: 50,
                            color: _kDominant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ================================================================
// PERIOD SWITCHER  (#DFF7E2 bg, active = #007AFF)
// ================================================================
class _PeriodSwitcher extends StatelessWidget {
  final List<String> tabs;
  final int selected;
  final ValueChanged<int> onChanged;

  const _PeriodSwitcher({
    required this.tabs,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: _kLightGreen,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: List.generate(tabs.length, (i) {
          final isActive = i == selected;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: isActive ? _kDominant : Colors.transparent,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Center(
                  child: Text(
                    tabs[i],
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isActive ? Colors.white : _kComplementary,
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ================================================================
// INCOME & EXPENSES BAR CHART CARD
// ================================================================
class _ChartCard extends StatelessWidget {
  final List<List<double>> data; // [[income, expense], ...]
  final List<String> labels;

  const _ChartCard({required this.data, required this.labels});

  @override
  Widget build(BuildContext context) {
    const maxH = 101.0; // max bar height in logical pixels

    // y-axis ticks
    const yTicks = ['15k', '10k', '5k', '1k'];
    const yValues = [15000.0, 10000.0, 5000.0, 1000.0];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _kOffWhite,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // title
          const Text(
            'Income & Expenses',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: _kComplementary,
            ),
          ),
          const SizedBox(height: 6),

          // legend
          Row(
            children: [
              _legendDot(_kGreen),
              const SizedBox(width: 4),
              const Text('Income',
                  style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      color: _kComplementary)),
              const SizedBox(width: 10),
              _legendDot(_kRed),
              const SizedBox(width: 4),
              const Text('Expenses',
                  style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      color: _kComplementary)),
            ],
          ),

          const SizedBox(height: 14),

          // Chart area: y-axis + bars
          SizedBox(
            height: maxH + 30, // bars + x labels
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Y-axis labels
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: yTicks
                      .map((t) => Text(
                            t,
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 11,
                              color: _kDominant,
                            ),
                          ))
                      .toList(),
                ),
                const SizedBox(width: 8),

                // Bars area
                Expanded(
                  child: Column(
                    children: [
                      // dashed grid lines + bars stacked
                      Expanded(
                        child: Stack(
                          children: [
                            // dashed horizontal lines at each y tick
                            ...List.generate(yValues.length, (i) {
                              final frac =
                                  1.0 - (yValues[i] / yValues.first);
                              return Positioned(
                                top: frac * maxH,
                                left: 0,
                                right: 0,
                                child: CustomPaint(
                                  painter: _DashedLinePainter(),
                                  child: const SizedBox(height: 1),
                                ),
                              );
                            }),

                            // Bar groups
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceEvenly,
                              children: List.generate(data.length, (i) {
                                final income = data[i][0];
                                final expense = data[i][1];
                                final maxVal = 101.0;
                                final incH = (income / maxVal) * maxH;
                                final expH = (expense / maxVal) * maxH;
                                return Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        // expense bar (red, left)
                                        Container(
                                          width: 5,
                                          height: expH.clamp(4.0, maxH),
                                          decoration: BoxDecoration(
                                            color: _kRed,
                                            borderRadius:
                                                BorderRadius.circular(4),
                                          ),
                                        ),
                                        const SizedBox(width: 3),
                                        // income bar (green, right)
                                        Container(
                                          width: 5,
                                          height: incH.clamp(4.0, maxH),
                                          decoration: BoxDecoration(
                                            color: _kGreen,
                                            borderRadius:
                                                BorderRadius.circular(4),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                );
                              }),
                            ),
                          ],
                        ),
                      ),

                      // X-axis baseline
                      Container(
                        height: 1,
                        color: _kComplementary,
                      ),

                      // X-axis labels
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: labels
                            .map((l) => Text(
                                  l,
                                  style: const TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 11,
                                    color: _kComplementary,
                                  ),
                                ))
                            .toList(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _legendDot(Color color) => Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
      );
}

// dashed line painter
class _DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = _kDominant.withValues(alpha: 0.4)
      ..strokeWidth = 0.6
      ..style = PaintingStyle.stroke;

    const dashW = 6.0;
    const gapW = 4.0;
    double x = 0;
    while (x < size.width) {
      canvas.drawLine(Offset(x, 0), Offset(x + dashW, 0), paint);
      x += dashW + gapW;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ================================================================
// SUMMARY ROW (Total Balance | Total Expense)
// ================================================================
class _SummaryRow extends StatelessWidget {
  final String balance;
  final String expense;
  const _SummaryRow({required this.balance, required this.expense});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: _kOffWhite,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          // Balance
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 15,
                      height: 17,
                      decoration: BoxDecoration(
                        color: _kDominant,
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: const Icon(Icons.arrow_upward,
                          size: 11, color: Colors.white),
                    ),
                    const SizedBox(width: 6),
                    const Text('Total Balance',
                        style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 13,
                            color: Colors.black87)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  balance,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: _kDominant,
                  ),
                ),
              ],
            ),
          ),

          // Divider
          Container(
            height: 40,
            width: 1,
            color: const Color(0xFF8E8E93).withValues(alpha: 0.4),
          ),
          const SizedBox(width: 16),

          // Expense
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 15,
                      height: 17,
                      decoration: BoxDecoration(
                        color: _kRed,
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: const Icon(Icons.arrow_downward,
                          size: 11, color: Colors.white),
                    ),
                    const SizedBox(width: 6),
                    const Text('Total Expense',
                        style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 13,
                            color: Colors.black87)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  expense,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: _kRed,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ================================================================
// DONUT CARD  (blue square with circular arc)
// ================================================================
class _DonutCard extends StatelessWidget {
  final String label;
  final double percent; // 0–100
  final Color color;

  const _DonutCard({
    required this.label,
    required this.percent,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 167,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer white ring (background)
          CustomPaint(
            painter: _ArcPainter(
              fraction: 1.0,
              color: Colors.white.withValues(alpha: 0.3),
              strokeWidth: 10,
            ),
            child: const SizedBox(width: 100, height: 100),
          ),
          // Inner navy arc (progress)
          CustomPaint(
            painter: _ArcPainter(
              fraction: percent / 100,
              color: _kComplementary,
              strokeWidth: 10,
            ),
            child: const SizedBox(width: 100, height: 100),
          ),
          // Percentage text
          Text(
            '${percent.toInt()}%',
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),

          // Label at the bottom
          Positioned(
            bottom: 18,
            child: Text(
              label,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: _kOffWhite,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ArcPainter extends CustomPainter {
  final double fraction;
  final Color color;
  final double strokeWidth;

  const _ArcPainter({
    required this.fraction,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final rect = Rect.fromLTWH(
        strokeWidth / 2,
        strokeWidth / 2,
        size.width - strokeWidth,
        size.height - strokeWidth);

    canvas.drawArc(
      rect,
      -math.pi / 2, // start from top
      fraction * 2 * math.pi,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _ArcPainter old) =>
      old.fraction != fraction || old.color != color;
}
