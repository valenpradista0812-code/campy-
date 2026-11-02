import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class PaymentMethodsPage extends StatelessWidget {
  const PaymentMethodsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Payment Methods',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, size: 22),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Saved Methods ─────────────────────────────────────────────────
          const Text('Saved Methods',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.muted)),
          const SizedBox(height: 10),
          _SavedMethodTile(
              label: 'BCA',
              subtitle: '•••• •••• 1234',
              color: const Color(0xFF003087)),
          _SavedMethodTile(
              label: 'DANA',
              subtitle: '+62 812-3456-7890',
              color: const Color(0xFF108EE9)),
          TextButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.add, size: 16, color: AppColors.primary),
            label: const Text('Add New Payment Method',
                style: TextStyle(fontSize: 12, color: AppColors.primary)),
          ),
          const Divider(height: 28),

          // ── Bank Transfer ─────────────────────────────────────────────────
          const Text('Bank Transfer',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.muted)),
          const SizedBox(height: 8),
          _OptionTile(
            icon: Icons.account_balance_outlined,
            label: 'Bank Transfer',
            onTap: () {},
          ),
          const SizedBox(height: 20),

          // ── E-Wallet ──────────────────────────────────────────────────────
          const Text('E-Wallet',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.muted)),
          const SizedBox(height: 8),
          _OptionTile(
            badgeLabel: 'GoPay',
            badgeColor: const Color(0xFF00AA5B),
            label: 'GoPay',
            onTap: () {},
          ),
          _OptionTile(
            badgeLabel: 'OVO',
            badgeColor: const Color(0xFF4C3494),
            label: 'OVO',
            onTap: () {},
          ),
          const SizedBox(height: 20),

          // ── Credit / Debit Card ───────────────────────────────────────────
          const Text('Credit / Debit Card',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.muted)),
          const SizedBox(height: 8),
          _OptionTile(
            icon: Icons.credit_card_outlined,
            label: 'Credit / Debit Card',
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

// ── Saved method card ─────────────────────────────────────────────────────────

class _SavedMethodTile extends StatelessWidget {
  final String label;
  final String subtitle;
  final Color color;
  const _SavedMethodTile(
      {required this.label, required this.subtitle, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 26,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Center(
              child: Text(label,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w800)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w600)),
                Text(subtitle,
                    style: const TextStyle(
                        fontSize: 10, color: AppColors.muted)),
              ],
            ),
          ),
          const Icon(Icons.more_vert, size: 18, color: AppColors.muted),
        ],
      ),
    );
  }
}

// ── Option list tile ──────────────────────────────────────────────────────────

class _OptionTile extends StatelessWidget {
  final IconData? icon;
  final String? badgeLabel;
  final Color? badgeColor;
  final String label;
  final VoidCallback onTap;
  const _OptionTile(
      {this.icon,
      this.badgeLabel,
      this.badgeColor,
      required this.label,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: badgeLabel != null
          ? Container(
              width: 44,
              height: 26,
              decoration: BoxDecoration(
                color: badgeColor,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Center(
                child: Text(
                  badgeLabel!.substring(0, badgeLabel!.length.clamp(0, 3)),
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w800),
                ),
              ),
            )
          : Icon(icon, color: AppColors.primary, size: 22),
      title: Text(label, style: const TextStyle(fontSize: 12)),
      trailing:
          const Icon(Icons.chevron_right, size: 18, color: AppColors.muted),
      onTap: onTap,
    );
  }
}
