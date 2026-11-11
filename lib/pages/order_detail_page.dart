import 'package:flutter/material.dart';
import '../data.dart';
import '../theme/app_colors.dart';
import '../widgets/common_widgets.dart';
import 'help_page.dart';
import 'product_detail_page.dart';

class OrderDetailPage extends StatelessWidget {
  final AppOrder order;
  const OrderDetailPage({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final isActive = order.status == 'active';
    final total = order.product.price * order.qty;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Order Details - ${order.id}',
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, size: 22),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Status banner ────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isActive
                  ? AppColors.lightGreen
                  : AppColors.fieldBg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                  color: isActive ? AppColors.primary : AppColors.border),
            ),
            child: Row(
              children: [
                Icon(
                  isActive ? Icons.timelapse : Icons.check_circle,
                  color: isActive ? AppColors.primaryDark : AppColors.muted,
                  size: 26,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isActive ? 'Rental Active' : 'Completed',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: isActive
                              ? AppColors.primaryDark
                              : AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isActive
                            ? 'Equipment is currently in use. Please return on schedule.'
                            : 'This order has been completed and returned.',
                        style: const TextStyle(
                            fontSize: 10, color: AppColors.muted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── Timeline tracker ─────────────────────────────────────────────
          _CardContainer(
            title: 'Order Status Timeline',
            child: Column(
              children: [
                _TimelineStep(
                  title: 'Order Created',
                  time: '14 Oct 2024, 09:30 WIB',
                  isDone: true,
                  isLast: false,
                ),
                _TimelineStep(
                  title: 'KTP Verified & Approved',
                  time: '14 Oct 2024, 10:00 WIB',
                  isDone: true,
                  isLast: false,
                ),
                _TimelineStep(
                  title: 'Equipment Prepared & Handed Over',
                  time: '14 Oct 2024, 11:15 WIB',
                  isDone: true,
                  isLast: false,
                ),
                _TimelineStep(
                  title: isActive ? 'Rental Active (In Use)' : 'Rental Active',
                  time: '14 - 16 Oct 2024',
                  isDone: true,
                  isLast: !isActive,
                ),
                if (isActive)
                  _TimelineStep(
                    title: 'Scheduled Return & Inspection',
                    time: 'Est. 16 Oct 2024, 18:00 WIB',
                    isDone: false,
                    isLast: true,
                  ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // ── Rented Item ──────────────────────────────────────────────────
          _CardContainer(
            title: 'Rented Equipment',
            child: InkWell(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ProductDetailPage(product: order.product),
                ),
              ),
              borderRadius: BorderRadius.circular(8),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppColors.imageBg,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ProductImage(
                      asset: order.product.asset,
                      fallback: order.product.icon,
                      size: 38,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(order.product.name,
                            style: const TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 2),
                        Text(order.product.sub,
                            style: const TextStyle(
                                fontSize: 10, color: AppColors.muted)),
                        Text('Rental: ${order.date}',
                            style: const TextStyle(
                                fontSize: 10, color: AppColors.primary)),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('Qty: ${order.qty}',
                          style: const TextStyle(
                              fontSize: 10, color: AppColors.muted)),
                      const SizedBox(height: 2),
                      Text(rupiah(total),
                          style: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w700)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),

          // ── Pickup / Delivery Info ───────────────────────────────────────
          _CardContainer(
            title: 'Delivery & Return Location',
            child: Row(
              children: const [
                Icon(Icons.storefront_outlined,
                    size: 20, color: AppColors.primary),
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Campy Outdoor Store (Self Pick-Up)',
                          style: TextStyle(
                              fontSize: 11, fontWeight: FontWeight.w600)),
                      SizedBox(height: 2),
                      Text('Jl. Campy No. 1, Jakarta Selatan',
                          style: TextStyle(
                              fontSize: 10, color: AppColors.muted)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // ── Payment Details ──────────────────────────────────────────────
          _CardContainer(
            title: 'Payment Summary',
            child: Column(
              children: [
                _RowInfo('Subtotal Equipment', rupiah(total)),
                const SizedBox(height: 6),
                _RowInfo('Delivery / Pickup Fee', 'Free'),
                const SizedBox(height: 6),
                _RowInfo('Deposit Guarantee', 'Waived by KTP'),
                const Divider(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total Paid',
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w700)),
                    Text(rupiah(total),
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary)),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF003087),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text('BCA',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                              fontWeight: FontWeight.w700)),
                    ),
                    const SizedBox(width: 8),
                    const Text('BCA Virtual Account • Paid',
                        style: TextStyle(
                            fontSize: 10, color: AppColors.muted)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ── Actions ──────────────────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton.icon(
              onPressed: () {
                final cart = [...cartNotifier.value];
                cart.add(CartItem(order.product, order.qty, order.product.price));
                cartNotifier.value = cart;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${order.product.name} added to cart again!'),
                  ),
                );
              },
              icon: const Icon(Icons.repeat, size: 16),
              label: const Text('Rent Again',
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
          SizedBox(
            width: double.infinity,
            height: 44,
            child: OutlinedButton.icon(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const HelpPage()),
              ),
              icon: const Icon(Icons.support_agent, size: 16),
              label: const Text('Need Help with this Order?',
                  style: TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w600)),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _CardContainer extends StatelessWidget {
  final String title;
  final Widget child;
  const _CardContainer({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.muted)),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _TimelineStep extends StatelessWidget {
  final String title;
  final String time;
  final bool isDone;
  final bool isLast;

  const _TimelineStep({
    required this.title,
    required this.time,
    required this.isDone,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDone ? AppColors.primary : Colors.grey.shade300,
              ),
              child: isDone
                  ? const Icon(Icons.check, size: 10, color: Colors.white)
                  : null,
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 28,
                color: isDone ? AppColors.primary : Colors.grey.shade300,
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: isDone ? FontWeight.w600 : FontWeight.w500,
                      color: isDone ? AppColors.textDark : AppColors.muted,
                    )),
                const SizedBox(height: 1),
                Text(time,
                    style:
                        const TextStyle(fontSize: 9, color: AppColors.muted)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _RowInfo extends StatelessWidget {
  final String label;
  final String value;
  const _RowInfo(this.label, this.value);

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

