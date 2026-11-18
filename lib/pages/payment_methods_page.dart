import 'package:flutter/material.dart';
import '../data.dart';
import '../theme/app_colors.dart';
import 'add_payment_method_page.dart';

class PaymentMethodsPage extends StatefulWidget {
  const PaymentMethodsPage({super.key});

  @override
  State<PaymentMethodsPage> createState() => _PaymentMethodsPageState();
}

class _PaymentMethodsPageState extends State<PaymentMethodsPage> {
  void _select(String method) {
    selectedPaymentMethod.value = method;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Payment Methods',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        ),
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, size: 22),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Selected Method ───────────────────────────────────────────────
          const Text(
            'Metode Pembayaran Aktif',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.muted,
            ),
          ),
          const SizedBox(height: 10),
          ValueListenableBuilder<String>(
            valueListenable: selectedPaymentMethod,
            builder: (context, current, _) {
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.primary),
                  color: AppColors.lightGreen.withValues(alpha: 0.3),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, size: 20, color: AppColors.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            current,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryDark,
                            ),
                          ),
                          const Text(
                            'Metode pembayaran saat ini untuk transaksi',
                            style: TextStyle(fontSize: 10, color: AppColors.muted),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const Divider(height: 24),

          // ── Bank Transfer ─────────────────────────────────────────────────
          const Text(
            'Bank Transfer',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.muted,
            ),
          ),
          const SizedBox(height: 8),
          _OptionTile(
            icon: Icons.account_balance_outlined,
            label: 'Bank Transfer',
            onTap: () => _select('Bank Transfer'),
          ),
          const SizedBox(height: 20),

          // ── E-Wallet ──────────────────────────────────────────────────────
          const Text(
            'E-Wallet',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.muted,
            ),
          ),
          const SizedBox(height: 8),
          _OptionTile(
            badgeLabel: 'GoPay',
            badgeColor: const Color(0xFF00AA5B),
            label: 'GoPay',
            onTap: () => _select('GoPay'),
          ),
          _OptionTile(
            badgeLabel: 'OVO',
            badgeColor: const Color(0xFF4C3494),
            label: 'OVO',
            onTap: () => _select('OVO'),
          ),
          const SizedBox(height: 20),

          // ── Credit / Debit Card ───────────────────────────────────────────
          const Text(
            'Credit / Debit Card',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.muted,
            ),
          ),
          const SizedBox(height: 8),
          _OptionTile(
            icon: Icons.credit_card_outlined,
            label: 'Credit / Debit Card',
            onTap: () => _select('Credit/Debit Card'),
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
  final VoidCallback onTap;
  const _SavedMethodTile({
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
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
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.muted,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.more_vert, size: 18, color: AppColors.muted),
          ],
        ),
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
  const _OptionTile({
    this.icon,
    this.badgeLabel,
    this.badgeColor,
    required this.label,
    required this.onTap,
  });

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
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            )
          : Icon(icon, color: AppColors.primary, size: 22),
      title: Text(label, style: const TextStyle(fontSize: 12)),
      trailing: const Icon(
        Icons.chevron_right,
        size: 18,
        color: AppColors.muted,
      ),
      onTap: onTap,
    );
  }
}
