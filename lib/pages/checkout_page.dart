import 'package:flutter/material.dart';
import '../data.dart';
import '../theme/app_colors.dart';
import '../widgets/common_widgets.dart';
import 'payment_page.dart';

class CheckoutPage extends StatelessWidget {
  const CheckoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Checkout',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, size: 22),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: ValueListenableBuilder<List<CartItem>>(
        valueListenable: cartNotifier,
        builder: (context, items, _) {
          if (items.isEmpty) {
            return const Center(child: Text('Your cart is empty'));
          }
          final total = items.fold<int>(0, (s, e) => s + e.unitPrice * e.qty);
          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // ── Cart items ───────────────────────────────────────────
                    ...items.map((item) => _CheckoutItem(item: item)),
                    const SizedBox(height: 14),

                    // ── Delivery ─────────────────────────────────────────────
                    _SectionCard(
                      title: 'Delivery Method',
                      child: Row(
                        children: [
                          const Icon(Icons.store_outlined,
                              size: 18, color: AppColors.primary),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Self Pick-Up',
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600)),
                                Text('Jl. Campy No. 1, Jakarta',
                                    style: TextStyle(
                                        fontSize: 10, color: AppColors.muted)),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right,
                              size: 16, color: AppColors.muted),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // ── Payment method ────────────────────────────────────────
                    _SectionCard(
                      title: 'Payment Method',
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 22,
                            decoration: BoxDecoration(
                              color: Colors.blue.shade800,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Center(
                              child: Text('BCA',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 8,
                                      fontWeight: FontWeight.w700)),
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Expanded(
                              child: Text('BCA Transfer',
                                  style: TextStyle(fontSize: 12))),
                          const Icon(Icons.chevron_right,
                              size: 16, color: AppColors.muted),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ── Total + Pay button ────────────────────────────────────────
              Container(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border:
                      Border(top: BorderSide(color: AppColors.border)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total',
                            style: TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w600)),
                        Text(rupiah(total),
                            style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (_) => PaymentPage(total: total)),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text('Pay',
                            style: TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ── Item tile ─────────────────────────────────────────────────────────────────

class _CheckoutItem extends StatelessWidget {
  final CartItem item;
  const _CheckoutItem({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.imageBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: ProductImage(
              asset: item.product.asset,
              fallback: item.product.icon,
              size: 36,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.product.name,
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w600)),
                Text(item.product.sub,
                    style: const TextStyle(
                        fontSize: 10, color: AppColors.muted)),
                Text('Qty: ${item.qty}',
                    style: const TextStyle(
                        fontSize: 10, color: AppColors.muted)),
              ],
            ),
          ),
          Text(rupiah(item.unitPrice * item.qty),
              style: const TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

// ── Section card ──────────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.muted,
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}
