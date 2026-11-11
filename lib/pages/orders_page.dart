import 'package:flutter/material.dart';
import '../data.dart';
import '../theme/app_colors.dart';
import '../widgets/common_widgets.dart';
import 'order_detail_page.dart';

class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Orders',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, size: 22),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Latest 30 Days Offer:',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          ...sampleOrders.map((o) => _OrderTile(order: o)),
        ],
      ),
    );
  }
}

class _OrderTile extends StatelessWidget {
  final AppOrder order;
  const _OrderTile({required this.order});

  @override
  Widget build(BuildContext context) {
    final isActive = order.status == 'active';
    return InkWell(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => OrderDetailPage(order: order),
        ),
      ),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          // Product icon
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
              size: 36,
            ),
          ),
          const SizedBox(width: 12),
          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(order.product.name,
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(order.date,
                    style: const TextStyle(
                        fontSize: 10, color: AppColors.muted)),
                Text('Qty: ${order.qty}',
                    style: const TextStyle(
                        fontSize: 10, color: AppColors.muted)),
              ],
            ),
          ),
          // Status + price
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(rupiah(order.product.price * order.qty),
                  style: const TextStyle(
                      fontSize: 11, fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isActive
                      ? AppColors.lightGreen
                      : AppColors.fieldBg,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  isActive ? 'Active' : 'Completed',
                  style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: isActive
                          ? AppColors.primary
                          : AppColors.muted),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
}
