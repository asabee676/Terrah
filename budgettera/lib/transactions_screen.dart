import 'package:flutter/material.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  String _searchQuery = "";
  String _selectedTab = "All"; // "All", "Income", "Expenses"

  final List<Map<String, dynamic>> _allTransactions = [
    {
      "id": "TXN100239",
      "title": "Salary Deposit",
      "subtitle": "Monthly Salary payout",
      "amount": 5500.00,
      "isIncome": true,
      "date": "Today, 10:30 AM",
      "category": "Salary",
      "icon": Icons.wallet_membership,
      "color": Colors.green,
      "status": "Successful",
      "account": "Main Bank"
    },
    {
      "id": "TXN100240",
      "title": "KFC Fast Food",
      "subtitle": "Lunch meal with team",
      "amount": 120.50,
      "isIncome": false,
      "date": "Today, 01:15 PM",
      "category": "Food & Dining",
      "icon": Icons.fastfood,
      "color": Colors.orange,
      "status": "Successful",
      "account": "Mobile Money"
    },
    {
      "id": "TXN100241",
      "title": "Shell Fuel Station",
      "subtitle": "Car refuel",
      "amount": 250.00,
      "isIncome": false,
      "date": "Yesterday, 06:45 PM",
      "category": "Transport",
      "icon": Icons.directions_car,
      "color": Colors.blue,
      "status": "Successful",
      "account": "Main Bank"
    },
    {
      "id": "TXN100242",
      "title": "Netflix Subscription",
      "subtitle": "Premium Ultra HD Plan",
      "amount": 85.00,
      "isIncome": false,
      "date": "04 June 2026",
      "category": "Entertainment",
      "icon": Icons.movie,
      "color": Colors.red,
      "status": "Successful",
      "account": "Credit Card"
    },
    {
      "id": "TXN100243",
      "title": "Freelance Design",
      "subtitle": "Budgetterra Landing Page UI",
      "amount": 1200.00,
      "isIncome": true,
      "date": "02 June 2026",
      "category": "Freelance",
      "icon": Icons.work,
      "color": Colors.purple,
      "status": "Successful",
      "account": "Mobile Money"
    },
    {
      "id": "TXN100244",
      "title": "Amazon Online Shop",
      "subtitle": "Hardcover notebook & pen",
      "amount": 45.20,
      "isIncome": false,
      "date": "30 May 2026",
      "category": "Shopping",
      "icon": Icons.shopping_bag,
      "color": Colors.amber,
      "status": "Pending",
      "account": "Credit Card"
    },
    {
      "id": "TXN100245",
      "title": "Electricity Bill Payment",
      "subtitle": "Home utilities ECG GHS",
      "amount": 350.00,
      "isIncome": false,
      "date": "28 May 2026",
      "category": "Utilities",
      "icon": Icons.bolt,
      "color": Colors.cyan,
      "status": "Failed",
      "account": "Mobile Money"
    }
  ];

  void _showTransactionDetails(Map<String, dynamic> txn) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      builder: (context) {
        final isIncome = txn["isIncome"] as bool;
        final Color statusColor = txn["status"] == "Successful"
            ? Colors.green
            : txn["status"] == "Pending"
                ? Colors.orange
                : Colors.red;

        return Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 50,
                  height: 5,
                  decoration: const BoxDecoration(
                    color: Colors.black12,
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(height: 25),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        txn["title"],
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E2843),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        txn["subtitle"],
                        style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                  CircleAvatar(
                    backgroundColor: txn["color"].withOpacity(0.15),
                    radius: 25,
                    child: Icon(txn["icon"], color: txn["color"], size: 28),
                  ),
                ],
              ),
              const Divider(height: 35),
              _detailRow("Transaction ID", txn["id"]),
              _detailRow("Date & Time", txn["date"]),
              _detailRow("Category", txn["category"]),
              _detailRow("Payment Method", txn["account"]),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Status",
                    style: TextStyle(fontSize: 15, color: Colors.grey, fontWeight: FontWeight.w500),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      txn["status"],
                      style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                ],
              ),
              const Divider(height: 35),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Total Amount",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E2843)),
                  ),
                  Text(
                    "${isIncome ? '+' : '-'} GHS ${txn['amount'].toStringAsFixed(2)}",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: isIncome ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
            ],
          ),
        );
      },
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 15, color: Colors.grey, fontWeight: FontWeight.w500),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1E2843)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Filter logic
    final filtered = _allTransactions.where((txn) {
      final matchesSearch = txn["title"].toLowerCase().contains(_searchQuery.toLowerCase()) ||
          txn["subtitle"].toLowerCase().contains(_searchQuery.toLowerCase()) ||
          txn["category"].toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesTab = _selectedTab == "All" ||
          (_selectedTab == "Income" && txn["isIncome"] == true) ||
          (_selectedTab == "Expenses" && txn["isIncome"] == false);

      return matchesSearch && matchesTab;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FF),
      appBar: AppBar(
        title: const Text(
          "Transactions",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF0A6CFF),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search & Filter Header Container
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFF0A6CFF),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 25),
            child: Column(
              children: [
                // Search Input Field
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: TextField(
                    onChanged: (val) {
                      setState(() {
                        _searchQuery = val;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: "Search transactions...",
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 15),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, color: Colors.grey),
                              onPressed: () {
                                setState(() {
                                  _searchQuery = "";
                                });
                              },
                            )
                          : null,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Filter Custom Tabs
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _tabButton("All"),
                    _tabButton("Income"),
                    _tabButton("Expenses"),
                  ],
                ),
              ],
            ),
          ),

          // Transactions List
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.receipt_long, size: 80, color: Colors.grey.shade400),
                        const SizedBox(height: 15),
                        Text(
                          "No transactions found",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final txn = filtered[index];
                      final isIncome = txn["isIncome"] as bool;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
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
                        child: ListTile(
                          onTap: () => _showTransactionDetails(txn),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          leading: CircleAvatar(
                            backgroundColor: txn["color"].withOpacity(0.12),
                            child: Icon(txn["icon"], color: txn["color"]),
                          ),
                          title: Text(
                            txn["title"],
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E2843)),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text(
                              txn["date"],
                              style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                            ),
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                "${isIncome ? '+' : '-'} GHS ${txn['amount'].toStringAsFixed(2)}",
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 15,
                                  color: isIncome ? Colors.green : Colors.red,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                txn["category"],
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _tabButton(String tabTitle) {
    final bool isSelected = _selectedTab == tabTitle;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTab = tabTitle;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.white24,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Text(
          tabTitle,
          style: TextStyle(
            color: isSelected ? const Color(0xFF0A6CFF) : Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
