import 'package:flutter/material.dart';

class Home extends StatelessWidget {
  final String userName;

  const Home({super.key, required this.userName});

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF0A6CFF);
    const cardBlue = Color(0xFFEAF1FF);
    const successGreen = Color(0xFF3CC173);
    const failRed = Color(0xFFFF4D4D);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FF),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              //----------------------------------------------------------------
              //  🔵 BLUE TOP SECTION (NO CURVED BOTTOM)
              //----------------------------------------------------------------
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 18,
                ),
                color: primaryBlue,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //--------------------------------------------------------------
                    // GREETING + NOTIFICATION
                    //--------------------------------------------------------------
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Hi, Welcome Back",
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "Good morning",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.white,
                          child: Icon(Icons.notifications, color: primaryBlue),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    //--------------------------------------------------------------
                    // MAIN CARD — Stays FULLY inside Blue background
                    //--------------------------------------------------------------
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color: cardBlue,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            // ignore: deprecated_member_use
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          //----------------------------------------------------------
                          // NAME + ARROW
                          //----------------------------------------------------------
                          Row(
                            children: [
                              Text(
                                userName,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(width: 5),
                              const Icon(Icons.keyboard_arrow_down),
                            ],
                          ),

                          const SizedBox(height: 10),

                          //----------------------------------------------------------
                          // TAGS
                          //----------------------------------------------------------
                          Row(
                            children: [
                              _tag("budget"),
                              const SizedBox(width: 6),
                              _tag("remittance"),
                              const SizedBox(width: 6),
                              _tag("#37473958"),
                            ],
                          ),

                          const SizedBox(height: 20),

                          //----------------------------------------------------------
                          // BALANCE + EXPENSE
                          //----------------------------------------------------------
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.savings,
                                        color: successGreen,
                                        size: 16,
                                      ),
                                      SizedBox(width: 4),
                                      Text("Total Balance"),
                                    ],
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    "GHS 2000.00",
                                    style: TextStyle(
                                      color: primaryBlue,
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.money_off,
                                        color: failRed,
                                        size: 16,
                                      ),
                                      SizedBox(width: 4),
                                      Text("Total Expense"),
                                    ],
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    "GHS 1,187.40",
                                    style: TextStyle(
                                      color: failRed,
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          //----------------------------------------------------------
                          // PROGRESS BAR
                          //----------------------------------------------------------
                          const Text(
                            "Budget Spent : 30%",
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 6),

                          ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: const LinearProgressIndicator(
                              value: 0.30,
                              minHeight: 10,
                              color: successGreen,
                              backgroundColor: Colors.white,
                            ),
                          ),

                          const SizedBox(height: 6),

                          const Text(
                            "30% Of Your Expenses—Looks Great!",
                            style: TextStyle(
                              color: successGreen,
                              fontWeight: FontWeight.w600,
                            ),
                          ),

                          const SizedBox(height: 25),

                          //----------------------------------------------------------
                          // Action Buttons
                          //----------------------------------------------------------
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: const [
                              _actionButton(
                                icon: Icons.account_balance_wallet,
                                text: "Deposit",
                              ),
                              _actionButton(
                                icon: Icons.outbond,
                                text: "Withdraw",
                              ),
                              _actionButton(
                                icon: Icons.send,
                                text: "Send Money",
                              ),
                              _actionButton(
                                icon: Icons.receipt,
                                text: "Pay Bills",
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),

              //----------------------------------------------------------------
              //  ⚪ WHITE SECTION WITH CURVED TOP
              //----------------------------------------------------------------
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //--------------------------------------------------------------
                    // ROW: Remittance Text + Show All
                    //--------------------------------------------------------------
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text(
                          "Remittance Overview",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text("Show all", style: TextStyle(color: primaryBlue)),
                      ],
                    ),

                    const SizedBox(height: 10),
                    _remittanceTable(),
                  ],
                ),
              ),
            ],
          ),
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
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: Colors.grey.shade300),
    ),
    child: Text(
      text,
      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
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
          radius: 28,
          backgroundColor: const Color(0xFFDDE9FF),
          child: Icon(icon, color: Color(0xFF0A6CFF), size: 28),
        ),
        const SizedBox(height: 5),
        SizedBox(
          width: 70,
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11),
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// REMITTANCE TABLE
// ============================================================================
Widget _remittanceTable() {
  return Column(
    children: [
      Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF0A6CFF),
          borderRadius: BorderRadius.circular(15),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text("Date", style: TextStyle(color: Colors.white)),
            Text("Amount", style: TextStyle(color: Colors.white)),
            Text("Recipient", style: TextStyle(color: Colors.white)),
            Text("Status", style: TextStyle(color: Colors.white)),
          ],
        ),
      ),

      const SizedBox(height: 8),

      _row(
        "25/11/2024",
        "GHS 500.00",
        "John smith",
        "successful",
        Colors.green,
      ),
      _row("26/11/2024", "GHS 100.02", "Nana Kofi", "failed", Colors.red),
      _row("27/11/2024", "GHS 300.57", "Mike Adams", "pending", Colors.orange),
    ],
  );
}

Widget _row(String date, String amount, String rec, String status, Color col) {
  return Container(
    padding: const EdgeInsets.symmetric(vertical: 12),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Text(date),
        Text(amount),
        Text(rec),
        Text(
          status,
          style: TextStyle(color: col, fontWeight: FontWeight.w600),
        ),
      ],
    ),
  );
}
