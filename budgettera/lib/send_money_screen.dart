import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ============================================================
// DESIGN TOKENS
// ============================================================
const kDominant = Color(0xFF007AFF); // dominant blue
const kComplementary = Color(0xFF00238E); // dark navy
const kOffWhite = Color(0xFFE6F4F1); // off-white bg
const kBorder = Color(0xFFE8ECF4);
const kInputBg = Color(0xFFF7F8F9);
const kDark = Color(0xFF1E232C);
const kDarkGray = Color(0xFF6A707C);
const kGreen = Color(0xFF7ED321);
const kRed = Color(0xFFFF3B30);

class SendMoneyScreen extends StatefulWidget {
  const SendMoneyScreen({super.key});

  @override
  State<SendMoneyScreen> createState() => _SendMoneyScreenState();
}

class _SendMoneyScreenState extends State<SendMoneyScreen>
    with TickerProviderStateMixin {
  // ------------------------------------------------------------
  // State
  // ------------------------------------------------------------
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _recipientController = TextEditingController();

  String _selectedAccount = 'Mobile Money';
  int _selectedRecipientIndex = -1;
  bool _isLoading = false;

  late AnimationController _successAnimCtrl;
  late Animation<double> _successFade;
  late Animation<double> _successScale;

  // ------------------------------------------------------------
  // Mock data
  // ------------------------------------------------------------
  final List<Map<String, dynamic>> _recentRecipients = [
    {
      'name': 'Kofi Mensah',
      'number': '055 123 4567',
      'initials': 'KM',
      'color': Color(0xFF007AFF),
    },
    {
      'name': 'Ama Asante',
      'number': '024 987 6543',
      'initials': 'AA',
      'color': Color(0xFF7ED321),
    },
    {
      'name': 'John Smith',
      'number': '050 456 7890',
      'initials': 'JS',
      'color': Color(0xFFFF8400),
    },
    {
      'name': 'Nana Akua',
      'number': '027 321 6549',
      'initials': 'NA',
      'color': Color(0xFF00238E),
    },
  ];

  final List<String> _accounts = [
    'Mobile Money',
    'Main Bank',
    'Credit Card',
  ];

  final List<String> _quickAmounts = ['50', '100', '200', '500'];

  @override
  void initState() {
    super.initState();
    _successAnimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _successFade = CurvedAnimation(
      parent: _successAnimCtrl,
      curve: Curves.easeIn,
    );
    _successScale = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _successAnimCtrl, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    _recipientController.dispose();
    _successAnimCtrl.dispose();
    super.dispose();
  }

  // ------------------------------------------------------------
  // Actions
  // ------------------------------------------------------------
  Future<void> _onSend() async {
    // Validate
    if (_amountController.text.isEmpty) {
      _showSnack('Please enter an amount');
      return;
    }
    if (_recipientController.text.isEmpty && _selectedRecipientIndex == -1) {
      _showSnack('Please select or enter a recipient');
      return;
    }

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 2)); // mock network call
    setState(() => _isLoading = false);

    _showSuccessSheet();
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(fontFamily: 'Poppins')),
        backgroundColor: kComplementary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showSuccessSheet() {
    _successAnimCtrl.reset();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _SuccessSheet(
        amount: _amountController.text,
        recipient: _selectedRecipientIndex >= 0
            ? _recentRecipients[_selectedRecipientIndex]['name'] as String
            : _recipientController.text,
        account: _selectedAccount,
        onDone: () {
          Navigator.pop(context); // close sheet
          Navigator.pop(context); // go back to home
        },
        fadeAnim: _successFade,
        scaleAnim: _successScale,
        animCtrl: _successAnimCtrl,
      ),
    );
  }

  // ------------------------------------------------------------
  // Build
  // ------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kDominant,
      body: Column(
        children: [
          // ── Blue header ──────────────────────────────────────
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    'Send Money',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── White card panel ─────────────────────────────────
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Amount input ─────────────────────────
                    _sectionLabel('Amount'),
                    const SizedBox(height: 12),
                    _AmountInput(controller: _amountController),
                    const SizedBox(height: 12),

                    // ── Quick-amount chips ───────────────────
                    Row(
                      children: _quickAmounts
                          .map(
                            (a) => Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: _QuickAmountChip(
                                label: 'GHS $a',
                                onTap: () {
                                  setState(
                                      () => _amountController.text = a);
                                },
                              ),
                            ),
                          )
                          .toList(),
                    ),

                    const SizedBox(height: 28),

                    // ── From account ─────────────────────────
                    _sectionLabel('From Account'),
                    const SizedBox(height: 12),
                    _AccountDropdown(
                      selected: _selectedAccount,
                      accounts: _accounts,
                      onChanged: (v) => setState(() => _selectedAccount = v!),
                    ),

                    const SizedBox(height: 28),

                    // ── Recent recipients ────────────────────
                    _sectionLabel('Recent Recipients'),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 90,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _recentRecipients.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(width: 16),
                        itemBuilder: (_, i) {
                          final r = _recentRecipients[i];
                          final isSelected = _selectedRecipientIndex == i;
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedRecipientIndex = isSelected ? -1 : i;
                                if (!isSelected) {
                                  _recipientController.text =
                                      r['number'] as String;
                                }
                              });
                            },
                            child: _RecipientAvatar(
                              name: r['name'] as String,
                              initials: r['initials'] as String,
                              color: r['color'] as Color,
                              isSelected: isSelected,
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 28),

                    // ── Or new recipient ─────────────────────
                    Row(
                      children: [
                        Expanded(
                            child:
                                Divider(color: kBorder)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            'Or',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: kDarkGray,
                            ),
                          ),
                        ),
                        Expanded(child: Divider(color: kBorder)),
                      ],
                    ),

                    const SizedBox(height: 20),

                    _sectionLabel('Recipient Number / Account'),
                    const SizedBox(height: 12),
                    _PillInput(
                      controller: _recipientController,
                      hint: 'Enter mobile number or account',
                      keyboardType: TextInputType.phone,
                      prefixIcon: Icons.person_outline,
                    ),

                    const SizedBox(height: 20),

                    _sectionLabel('Note (optional)'),
                    const SizedBox(height: 12),
                    _PillInput(
                      controller: _noteController,
                      hint: "What's this for?",
                      prefixIcon: Icons.note_outlined,
                    ),

                    const SizedBox(height: 40),

                    // ── Send button ──────────────────────────
                    _SendButton(
                      isLoading: _isLoading,
                      onTap: _onSend,
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

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontFamily: 'Poppins',
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: kComplementary,
      ),
    );
  }
}

// ============================================================
// AMOUNT INPUT
// ============================================================
class _AmountInput extends StatelessWidget {
  final TextEditingController controller;
  const _AmountInput({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: kOffWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kBorder),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Row(
        children: [
          Text(
            'GHS',
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: kComplementary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))
              ],
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: kComplementary,
              ),
              decoration: const InputDecoration(
                hintText: '0.00',
                hintStyle: TextStyle(
                  color: Color(0xFFBBC5D8),
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                ),
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// QUICK AMOUNT CHIP
// ============================================================
class _QuickAmountChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _QuickAmountChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: kOffWhite,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: kBorder),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: kComplementary,
          ),
        ),
      ),
    );
  }
}

// ============================================================
// ACCOUNT DROPDOWN
// ============================================================
class _AccountDropdown extends StatelessWidget {
  final String selected;
  final List<String> accounts;
  final ValueChanged<String?> onChanged;
  const _AccountDropdown(
      {required this.selected,
      required this.accounts,
      required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      decoration: BoxDecoration(
        color: kInputBg,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: kBorder),
      ),
      child: DropdownButton<String>(
        value: selected,
        isExpanded: true,
        underline: const SizedBox(),
        icon: const Icon(Icons.keyboard_arrow_down, color: kComplementary),
        style: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 15,
          color: kComplementary,
          fontWeight: FontWeight.w400,
        ),
        items: accounts
            .map(
              (a) => DropdownMenuItem(
                value: a,
                child: Row(
                  children: [
                    const Icon(Icons.account_balance_wallet_outlined,
                        size: 18, color: kDominant),
                    const SizedBox(width: 10),
                    Text(a),
                  ],
                ),
              ),
            )
            .toList(),
        onChanged: onChanged,
      ),
    );
  }
}

// ============================================================
// RECIPIENT AVATAR
// ============================================================
class _RecipientAvatar extends StatelessWidget {
  final String name;
  final String initials;
  final Color color;
  final bool isSelected;
  const _RecipientAvatar({
    required this.name,
    required this.initials,
    required this.color,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isSelected ? color : color.withValues(alpha: 0.12),
            border: isSelected
                ? Border.all(color: color, width: 2.5)
                : Border.all(color: Colors.transparent),
            boxShadow: isSelected
                ? [BoxShadow(color: color.withValues(alpha: 0.35), blurRadius: 8)]
                : [],
          ),
          child: Center(
            child: Text(
              initials,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: isSelected ? Colors.white : color,
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        SizedBox(
          width: 60,
          child: Text(
            name.split(' ').first,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: isSelected ? kComplementary : kDarkGray,
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================
// PILL INPUT
// ============================================================
class _PillInput extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData prefixIcon;
  final TextInputType? keyboardType;
  const _PillInput({
    required this.controller,
    required this.hint,
    required this.prefixIcon,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: kInputBg,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: kBorder),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Row(
        children: [
          Icon(prefixIcon, color: kComplementary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 15,
                color: kDark,
              ),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 15,
                  color: Color(0xFFBBC5D8),
                ),
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// SEND BUTTON
// ============================================================
class _SendButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onTap;
  const _SendButton({required this.isLoading, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 56,
        width: double.infinity,
        decoration: BoxDecoration(
          color: isLoading ? kComplementary.withValues(alpha: 0.6) : kComplementary,
          borderRadius: BorderRadius.circular(100),
          boxShadow: [
            BoxShadow(
              color: kComplementary.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.send_rounded, color: Colors.white, size: 20),
                    SizedBox(width: 10),
                    Text(
                      'Send Money',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

// ============================================================
// SUCCESS BOTTOM SHEET
// ============================================================
class _SuccessSheet extends StatefulWidget {
  final String amount;
  final String recipient;
  final String account;
  final VoidCallback onDone;
  final Animation<double> fadeAnim;
  final Animation<double> scaleAnim;
  final AnimationController animCtrl;

  const _SuccessSheet({
    required this.amount,
    required this.recipient,
    required this.account,
    required this.onDone,
    required this.fadeAnim,
    required this.scaleAnim,
    required this.animCtrl,
  });

  @override
  State<_SuccessSheet> createState() => _SuccessSheetState();
}

class _SuccessSheetState extends State<_SuccessSheet> {
  @override
  void initState() {
    super.initState();
    widget.animCtrl.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(40),
          topRight: Radius.circular(40),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(28, 20, 28, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // drag handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: kBorder,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 32),

          // ── Animated checkmark ──────────────────────────
          ScaleTransition(
            scale: widget.scaleAnim,
            child: FadeTransition(
              opacity: widget.fadeAnim,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: kGreen.withValues(alpha: 0.12),
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: kGreen,
                  size: 64,
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          const Text(
            'Payment Successful!',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: kDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your transfer has been sent.',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              color: kDarkGray,
            ),
          ),

          const SizedBox(height: 32),

          // ── Transfer details card ────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: kOffWhite,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                _receiptRow('Amount', 'GHS ${widget.amount}',
                    valueColor: kComplementary, valueBold: true),
                const SizedBox(height: 12),
                _receiptRow('To', widget.recipient),
                const SizedBox(height: 12),
                _receiptRow('From', widget.account),
                const SizedBox(height: 12),
                _receiptRow(
                  'Reference',
                  'TXN${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
                ),
                const SizedBox(height: 12),
                _receiptRow('Status', 'Successful',
                    valueColor: kGreen, valueBold: true),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // ── Done button ──────────────────────────────────
          GestureDetector(
            onTap: widget.onDone,
            child: Container(
              height: 56,
              width: double.infinity,
              decoration: BoxDecoration(
                color: kComplementary,
                borderRadius: BorderRadius.circular(100),
                boxShadow: [
                  BoxShadow(
                    color: kComplementary.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Center(
                child: Text(
                  'Done',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _receiptRow(String label, String value,
      {Color? valueColor, bool valueBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            color: kDarkGray,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            fontWeight: valueBold ? FontWeight.w700 : FontWeight.w500,
            color: valueColor ?? kDark,
          ),
        ),
      ],
    );
  }
}
