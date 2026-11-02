import 'package:flutter/material.dart';
import '../data.dart';
import '../theme/app_colors.dart';

class HistoryTransactionPage extends StatelessWidget {
  const HistoryTransactionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('History Transaction',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, size: 22),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Bank card ────────────────────────────────────────────────────
          Container(
            height: 130,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('A BCA',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w800)),
                    const Spacer(),
                    Container(
                      width: 30,
                      height: 22,
                      decoration: BoxDecoration(
                        color: Colors.amber.shade300,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                const Text(
                  '\u2022\u2022\u2022\u2022  \u2022\u2022\u2022\u2022  \u2022\u2022\u2022\u2022  1234',
                  style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      letterSpacing: 2),
                ),
                const SizedBox(height: 4),
                const Text('Valen Pradista',
                    style: TextStyle(color: Colors.white, fontSize: 11)),
              ],
            ),
          ),
          const SizedBox(height: 22),

          // ── Transaction list ─────────────────────────────────────────────
          const Text('Latest 30 Days Transactions:',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          ...sampleTransactions.map((t) => _TransactionTile(t: t)),
        ],
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final AppTransaction t;
  const _TransactionTile({required this.t});

  @override
  Widget build(BuildContext context) {
    final ok = t.status == 'success';
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: ok
            ? AppColors.lightGreen.withValues(alpha: 0.5)
            : Colors.red.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
            color: ok ? AppColors.primary.withValues(alpha: 0.3) : Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(
            ok ? Icons.arrow_upward : Icons.arrow_downward,
            size: 16,
            color: ok ? AppColors.primary : Colors.red,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(t.orderId,
                    style: const TextStyle(
                        fontSize: 11, fontWeight: FontWeight.w600)),
                Text(t.date,
                    style: const TextStyle(
                        fontSize: 10, color: AppColors.muted)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(rupiah(t.amount),
                  style: const TextStyle(
                      fontSize: 11, fontWeight: FontWeight.w700)),
              Text(ok ? 'Success' : 'Failed',
                  style: TextStyle(
                      fontSize: 9,
                      color: ok ? AppColors.primary : Colors.red,
                      fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }
}
