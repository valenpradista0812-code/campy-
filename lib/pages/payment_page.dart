import 'package:flutter/material.dart';
import '../data.dart';
import '../theme/app_colors.dart';
import 'transaction_result_page.dart';

class PaymentPage extends StatelessWidget {
  final int total;
  const PaymentPage({super.key, required this.total});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Payment',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, size: 22),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 12),

            // ── Total payment banner ────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.lightGreen,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  const Text('Total Payment',
                      style:
                          TextStyle(fontSize: 11, color: AppColors.muted)),
                  const SizedBox(height: 4),
                  Text(rupiah(total),
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary)),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // ── QR Code ────────────────────────────────────────────────────
            Container(
              width: 200,
              height: 200,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.border, width: 2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: CustomPaint(painter: _QrPainter()),
            ),
            const SizedBox(height: 12),
            const Text(
              'Scan to pay with your preferred method',
              style: TextStyle(fontSize: 11, color: AppColors.muted),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // ── Payment method logos ────────────────────────────────────────
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: const [
                _Badge('BCA', Color(0xFF003087)),
                _Badge('DANA', Color(0xFF108EE9)),
                _Badge('GoPay', Color(0xFF00AA5B)),
                _Badge('OVO', Color(0xFF4C3494)),
                _Badge('mandiri', Color(0xFFE4A202)),
              ],
            ),
            const Spacer(),

            // ── Pay button ─────────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                      builder: (_) =>
                          TransactionResultPage(success: true, total: total)),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Save Code QR & Pay',
                    style:
                        TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () => Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                    builder: (_) =>
                        TransactionResultPage(success: false, total: total)),
              ),
              child: const Text('Simulate Failed Transaction',
                  style: TextStyle(fontSize: 11, color: AppColors.muted)),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

// ── Simple QR-like pattern using CustomPainter ────────────────────────────────

class _QrPainter extends CustomPainter {
  static const _grid = [
    [1,1,1,1,1,1,1,0,1,0,1,1,1,1,1],
    [1,0,0,0,0,0,1,0,0,1,1,0,0,0,1],
    [1,0,1,1,1,0,1,0,1,0,1,0,1,0,1],
    [1,0,1,1,1,0,1,0,0,1,1,0,1,0,1],
    [1,0,1,1,1,0,1,0,1,0,0,0,1,0,1],
    [1,0,0,0,0,0,1,0,1,1,0,0,0,0,1],
    [1,1,1,1,1,1,1,0,1,0,1,1,1,1,1],
    [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
    [1,1,0,1,1,0,1,0,1,1,0,1,1,0,1],
    [0,1,0,1,0,0,0,1,0,1,0,0,1,0,1],
    [1,0,1,0,1,0,1,0,1,0,1,0,1,0,1],
    [0,1,0,1,0,0,0,1,0,1,0,0,1,0,0],
    [1,1,1,1,1,0,1,0,1,0,1,0,1,0,1],
    [1,0,0,0,0,0,1,0,0,1,0,1,0,1,0],
    [1,1,1,1,1,1,1,0,1,0,1,0,1,1,1],
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black87;
    final cell = size.width / _grid.length;
    for (var r = 0; r < _grid.length; r++) {
      for (var c = 0; c < _grid[r].length; c++) {
        if (_grid[r][c] == 1) {
          canvas.drawRect(
            Rect.fromLTWH(
                c * cell + 0.5, r * cell + 0.5, cell - 1, cell - 1),
            paint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  const _Badge(this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(label,
          style: const TextStyle(
              color: Colors.white,
              fontSize: 9,
              fontWeight: FontWeight.w700)),
    );
  }
}
