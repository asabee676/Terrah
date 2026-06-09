import 'package:flutter/material.dart';

class Home extends StatelessWidget {
  final String userName;

  const Home({super.key, required this.userName});

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF0A6CFF);
    const cardBg = Color(0xFFEEF5F1); // Light greenish-grey
    const successGreen = Color(0xFF3CC173);
    const failRed = Color(0xFFFF4D4D);
    const textBlue = Color(0xFF0A6CFF);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            //----------------------------------------------------------------
            //  BLUE TOP SECTION
            //----------------------------------------------------------------
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 60, 20, 40),
              color: primaryBlue,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            "Hi,Welcome Back",
                            style: TextStyle(
                              fontSize: 22,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "Good morning",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const CircleAvatar(
                        radius: 22,
                        backgroundColor: Colors.white,
                        child: Icon(Icons.notifications, color: primaryBlue),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            //----------------------------------------------------------------
            //  MAIN CARD (Overlapping)
            //----------------------------------------------------------------
            Transform.translate(
              offset: const Offset(0, -20),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // NAME + ARROW
                    Row(
                      children: [
                        Text(
                          userName == 'Abel' ? 'Kofi' : userName, // Default to Kofi based on UI
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(width: 5),
                        const Icon(Icons.keyboard_arrow_down, color: primaryBlue, size: 28),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // TAGS
                    Row(
                      children: [
                        _tag("budget"),
                        const SizedBox(width: 8),
                        _tag("remittance"),
                        const SizedBox(width: 8),
                        _tag("#37473958"),
                      ],
                    ),

                    const SizedBox(height: 25),

                    // BALANCE + EXPENSE
                    Row(
                      children: [
                        // Left: Balance
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: BoxDecoration(
                                      color: successGreen.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Icon(Icons.arrow_upward, color: successGreen, size: 12),
                                  ),
                                  const SizedBox(width: 6),
                                  const Text("Total Balance", style: TextStyle(color: textBlue, fontSize: 13, fontWeight: FontWeight.w500)),
                                ],
                              ),
                              const SizedBox(height: 5),
                              const Text(
                                "GHS 2000.00",
                                style: TextStyle(color: textBlue, fontSize: 24, fontWeight: FontWeight.w900),
                              ),
                            ],
                          ),
                        ),
                        // Divider
                        Container(
                          height: 40,
                          width: 1,
                          color: Colors.green.withOpacity(0.2),
                        ),
                        const SizedBox(width: 15),
                        // Right: Expense
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: BoxDecoration(
                                      color: failRed.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Icon(Icons.arrow_downward, color: failRed, size: 12),
                                  ),
                                  const SizedBox(width: 6),
                                  const Text("Total Expense", style: TextStyle(color: textBlue, fontSize: 13, fontWeight: FontWeight.w500)),
                                ],
                              ),
                              const SizedBox(height: 5),
                              const Text(
                                "GHS 1,187.40",
                                style: TextStyle(color: failRed, fontSize: 24, fontWeight: FontWeight.w900),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 25),

                    // PROGRESS BAR
                    const Text(
                      "Budget Spent : 30%",
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),

                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: const LinearProgressIndicator(
                        value: 0.30,
                        minHeight: 14,
                        color: successGreen,
                        backgroundColor: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Row(
                      children: const [
                        Icon(Icons.check_box_outlined, size: 18, color: Colors.black87),
                        SizedBox(width: 6),
                        Text(
                          "30% Of Your Expenses—Looks Great!",
                          style: TextStyle(color: successGreen, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),

                    const SizedBox(height: 25),

                    // PAY AND RECEIVE
                    const Text(
                      "Pay  and Recieve",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.black),
                    ),
                    const SizedBox(height: 15),

                    // ACTION BUTTONS
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        _actionButton(
                          icon: Icons.account_balance_wallet_outlined,
                          text: "Desposit",
                        ),
                        _actionButton(
                          icon: Icons.local_atm_outlined,
                          text: "withdraw\nmoney",
                        ),
                        _actionButton(
                          icon: Icons.send_outlined,
                          text: "Send\nMoney",
                        ),
                        _actionButton(
                          icon: Icons.request_quote_outlined,
                          text: "Pay Bills",
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            //----------------------------------------------------------------
            //  REMITTANCE OVERVIEW
            //----------------------------------------------------------------
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Remmitance Overview",
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        "Show all",
                        style: TextStyle(
                          color: primaryBlue,
                          decoration: TextDecoration.underline,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  _remittanceTable(),
                  const SizedBox(height: 20),
                  // Pagination Dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        width: 25,
                        height: 8,
                        decoration: BoxDecoration(
                          color: primaryBlue,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: primaryBlue,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: primaryBlue,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// TAG CHIP
// ============================================================================
Widget _tag(String text) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text(
      text,
      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w400, color: Colors.black87),
    ),
  );
}

// ============================================================================
// ACTION BUTTON
// ============================================================================
class _actionButton extends StatelessWidget {
  final IconData icon;
  final String text;

  const _actionButton({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 25,
          backgroundColor: const Color(0xFF0A6CFF),
          child: Icon(icon, color: Colors.white, size: 26),
        ),
        const SizedBox(height: 8),
        Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.black),
        ),
      ],
    );
  }
}

// ============================================================================
// REMITTANCE TABLE
// ============================================================================
Widget _remittanceTable() {
  const primaryBlue = Color(0xFF0A6CFF);
  
  return Table(
    columnWidths: const {
      0: FlexColumnWidth(1.2),
      1: FlexColumnWidth(1.4),
      2: FlexColumnWidth(1.4),
      3: FlexColumnWidth(1),
    },
    children: [
      // HEADER
      TableRow(
        children: [
          _headerCell("Date"),
          _headerCell("Amount"),
          _headerCell("Recipeint"),
          _headerCell("Status"),
        ],
      ),
      // GAP ROW
      TableRow(
        children: [
          const SizedBox(height: 4),
          const SizedBox(height: 4),
          const SizedBox(height: 4),
          const SizedBox(height: 4),
        ],
      ),
      // DATA ROWS
      _dataRow("25/11/2024", "GHS 500.00", "John smith", "successful", const Color(0xFF3CC173), const Color(0xFFE8F8F0)),
      _spacerRow(),
      _dataRow("26/11/2024", "GHS 100.02", "Nana Kofi", "failed", const Color(0xFFFF4D4D), Colors.white),
      _spacerRow(),
      _dataRow("27/11/2024", "GHS 300.57", "Mike Adams", "pending", Colors.orange, const Color(0xFFFFF3E0)),
    ],
  );
}

Widget _headerCell(String text) {
  return Container(
    padding: const EdgeInsets.symmetric(vertical: 12),
    margin: const EdgeInsets.only(right: 2), // small white gap
    color: const Color(0xFF0A6CFF),
    alignment: Alignment.center,
    child: Text(
      text,
      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 13),
    ),
  );
}

TableRow _dataRow(String date, String amount, String rec, String status, Color statusColor, Color statusBg) {
  const rowBg = Color(0xFFF5F5F5); // light grey for first 3 cols
  return TableRow(
    children: [
      Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        margin: const EdgeInsets.only(right: 2),
        color: rowBg,
        alignment: Alignment.center,
        child: Text(date, style: const TextStyle(fontSize: 12)),
      ),
      Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        margin: const EdgeInsets.only(right: 2),
        color: rowBg,
        alignment: Alignment.center,
        child: Text(amount, style: const TextStyle(fontSize: 12)),
      ),
      Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        margin: const EdgeInsets.only(right: 2),
        color: rowBg,
        alignment: Alignment.center,
        child: Text(rec, style: const TextStyle(fontSize: 12)),
      ),
      Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        color: statusBg,
        alignment: Alignment.center,
        child: Text(status, style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.w500)),
      ),
    ],
  );
}

TableRow _spacerRow() {
  return const TableRow(
    children: [
      SizedBox(height: 4),
      SizedBox(height: 4),
      SizedBox(height: 4),
      SizedBox(height: 4),
    ],
  );
}
