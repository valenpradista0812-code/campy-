import 'package:flutter/material.dart';
import '../data.dart';
import '../theme/app_colors.dart';
import '../widgets/common_widgets.dart';
import 'payment_methods_page.dart';
import 'payment_page.dart';

enum DeliveryMethod {
  pickup,
  delivery,
}

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  DeliveryMethod _selectedMethod = DeliveryMethod.pickup;
  static const int _deliveryFeeAmount = 20000;

  int get _deliveryFee =>
      _selectedMethod == DeliveryMethod.delivery ? _deliveryFeeAmount : 0;

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
          final subtotal =
              items.fold<int>(0, (s, e) => s + e.unitPrice * e.qty);
          final grandTotal = subtotal + _deliveryFee;

          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // ── Cart items ───────────────────────────────────────────
                    ...items.map((item) => _CheckoutItem(item: item)),
                    const SizedBox(height: 14),

                    // ── Delivery Method ───────────────────────────────────────
                    _SectionCard(
                      title: 'Delivery Method',
                      child: Column(
                        children: [
                          _DeliveryOptionTile(
                            isSelected:
                                _selectedMethod == DeliveryMethod.pickup,
                            icon: Icons.store_outlined,
                            title: 'Self Pick-Up',
                            subtitle: 'Jl. Campy No. 1, Jakarta',
                            feeBadge: 'Free',
                            isFree: true,
                            onTap: () {
                              setState(() {
                                _selectedMethod = DeliveryMethod.pickup;
                              });
                            },
                          ),
                          const SizedBox(height: 10),
                          _DeliveryOptionTile(
                            isSelected:
                                _selectedMethod == DeliveryMethod.delivery,
                            icon: Icons.local_shipping_outlined,
                            title: 'Delivery',
                            subtitle: 'Jl. Campy No. 1, Jakarta Selatan',
                            feeBadge: '+${rupiah(_deliveryFeeAmount)}',
                            isFree: false,
                            onTap: () {
                              setState(() {
                                _selectedMethod = DeliveryMethod.delivery;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // ── Payment method ────────────────────────────────────────
                    _SectionCard(
                      title: 'Payment Method',
                      child: InkWell(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const PaymentMethodsPage(),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(6),
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
                                  style: TextStyle(fontSize: 12)),
                            ),
                            const Icon(Icons.chevron_right,
                                size: 16, color: AppColors.muted),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Summary + Pay button ──────────────────────────────────────
              Container(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: AppColors.border)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Subtotal',
                            style: TextStyle(
                                fontSize: 11, color: AppColors.muted)),
                        Text(rupiah(subtotal),
                            style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Delivery Fee',
                            style: TextStyle(
                                fontSize: 11, color: AppColors.muted)),
                        Text(
                          _deliveryFee == 0 ? 'Free' : rupiah(_deliveryFee),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: _deliveryFee == 0
                                ? AppColors.primary
                                : AppColors.textDark,
                          ),
                        ),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Divider(height: 1, color: AppColors.border),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total',
                            style: TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w600)),
                        Text(rupiah(grandTotal),
                            style: const TextStyle(
                                fontSize: 14,
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
                              builder: (_) => PaymentPage(total: grandTotal)),
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

// ── Delivery Option Tile ──────────────────────────────────────────────────────

class _DeliveryOptionTile extends StatelessWidget {
  final bool isSelected;
  final IconData icon;
  final String title;
  final String subtitle;
  final String feeBadge;
  final bool isFree;
  final VoidCallback onTap;

  const _DeliveryOptionTile({
    required this.isSelected,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.feeBadge,
    required this.isFree,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.lightGreen.withValues(alpha: 0.25)
                : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.border,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                isSelected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_off,
                size: 18,
                color: isSelected ? AppColors.primary : AppColors.muted,
              ),
              const SizedBox(width: 8),
              Icon(icon,
                  size: 20,
                  color: isSelected ? AppColors.primary : AppColors.muted),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w600,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                          fontSize: 10, color: AppColors.muted),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isFree
                      ? Colors.green.withValues(alpha: 0.1)
                      : (isSelected
                          ? AppColors.primary.withValues(alpha: 0.15)
                          : AppColors.fieldBg),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  feeBadge,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: isFree
                        ? Colors.green.shade700
                        : (isSelected
                            ? AppColors.primaryDark
                            : AppColors.textDark),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
