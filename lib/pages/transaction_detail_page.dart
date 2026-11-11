import 'package:flutter/material.dart';
import '../data.dart';
import '../theme/app_colors.dart';
import 'payment_page.dart';

class TransactionDetailPage extends StatelessWidget {
  final AppTransaction transaction;
  const TransactionDetailPage({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final ok = transaction.status == 'success';
    final color = ok ? Colors.green : Colors.red;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Transaction Details',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, size: 22),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 10),
          // ── Status icon & badge ──────────────────────────────────────────
          Center(
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                ok ? Icons.check_circle : Icons.cancel,
                size: 46,
                color: color,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              ok ? 'Payment Successful' : 'Payment Failed',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 4),
          Center(
            child: Text(
              ok
                  ? 'Your transaction has been processed and verified.'
                  : 'Payment was not completed. Please try again.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11, color: AppColors.muted),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              rupiah(transaction.amount),
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: ok ? AppColors.primaryDark : Colors.red.shade700,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // ── Receipt Card ─────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
              color: AppColors.fieldBg,
            ),
            child: Column(
              children: [
                _ReceiptRow('Transaction ID',
                    'TRX-${transaction.orderId.replaceAll('#', '')}-901'),
                const SizedBox(height: 8),
                _ReceiptRow('Order ID', transaction.orderId),
                const SizedBox(height: 8),
                _ReceiptRow('Date & Time', '${transaction.date}, 10:13 WIB'),
                const SizedBox(height: 8),
                _ReceiptRow('Recipient', 'Valen Pradista'),
                const Divider(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Payment Method',
                        style: TextStyle(
                            fontSize: 11, color: AppColors.muted)),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF003087),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            transaction.paymentMethod,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 8,
                                fontWeight: FontWeight.w700),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text('${transaction.paymentMethod} Transfer',
                            style: const TextStyle(
                                fontSize: 11, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Status',
                        style: TextStyle(
                            fontSize: 11, color: AppColors.muted)),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        ok ? 'SUCCESS' : 'FAILED',
                        style: TextStyle(
                            color: color,
                            fontSize: 9,
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // ── Actions ──────────────────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Receipt downloaded successfully!'),
                  ),
                );
              },
              icon: const Icon(Icons.download, size: 16),
              label: const Text('Download Receipt',
                  style: TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w600)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
          const SizedBox(height: 10),
          if (!ok)
            SizedBox(
              width: double.infinity,
              height: 44,
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => PaymentPage(total: transaction.amount),
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Retry Payment',
                    style: TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w600)),
              ),
            ),
        ],
      ),
    );
  }
}

class _ReceiptRow extends StatelessWidget {
  final String label;
  final String value;
  const _ReceiptRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 11, color: AppColors.muted)),
        Text(value,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
      ],
    );
  }
}

