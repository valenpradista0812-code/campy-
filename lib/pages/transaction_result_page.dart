import 'package:flutter/material.dart';
import '../data.dart';
import '../theme/app_colors.dart';
import 'main_shell.dart';
import 'payment_page.dart';

class TransactionResultPage extends StatelessWidget {
  final bool success;
  final int total;
  const TransactionResultPage(
      {super.key, required this.success, required this.total});

  @override
  Widget build(BuildContext context) {
    final color = success ? Colors.green : Colors.red;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          success ? 'Transaction Success' : 'Transaction Failed',
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 24),

            // ── Status icon ─────────────────────────────────────────────────
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                success ? Icons.check_circle : Icons.cancel,
                size: 60,
                color: color,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              success ? 'Thank you!' : 'Failed',
              style:
                  const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              success
                  ? 'Your transaction was successful'
                  : 'Your transaction was failed',
              style:
                  const TextStyle(fontSize: 12, color: AppColors.muted),
            ),
            const SizedBox(height: 32),

            // ── Details card ────────────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  _Row('Done', '01/14/2024'),
                  const SizedBox(height: 8),
                  _Row('Time', '10:13 AM'),
                  const SizedBox(height: 8),
                  _Row('To', 'Valen Pradista'),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600)),
                      Text(rupiah(total),
                          style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF003087),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text('BCA',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),

            // ── Action button ───────────────────────────────────────────────
            SizedBox(
              width: 180,
              height: 44,
              child: ElevatedButton(
                onPressed: () {
                  if (success) {
                    // Kosongkan cart setelah pembayaran berhasil
                    cartNotifier.value = [];
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const MainShell()),
                      (_) => false,
                    );
                  } else {
                    // Kembali ke halaman payment untuk mencoba lagi
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                          builder: (_) => PaymentPage(total: total)),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: Text(
                  success ? 'PAID' : 'Try Again',
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w700),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  const _Row(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style:
                const TextStyle(fontSize: 11, color: AppColors.muted)),
        Text(value,
            style: const TextStyle(
                fontSize: 11, fontWeight: FontWeight.w500)),
      ],
    );
  }
}
