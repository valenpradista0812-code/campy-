import 'package:flutter/material.dart';
import '../data.dart';
import '../services/api_service.dart';
import '../theme/app_colors.dart';
import '../widgets/common_widgets.dart';
import 'order_detail_page.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    final orders = await ApiService.getOrders();
    if (!mounted) return;
    ordersNotifier.value = orders;
    setState(() {
      _isLoading = false;
      _error = ApiService.lastError;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Orders',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        ),
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, size: 22),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: ValueListenableBuilder<List<AppOrder>>(
          valueListenable: ordersNotifier,
          builder: (context, orders, _) {
            if (orders.isEmpty && _isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (orders.isEmpty && _error != null) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.6,
                    child: Center(child: Text('Gagal memuat pesanan: $_error')),
                  ),
                ],
              );
            }
            if (orders.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.6,
                    child: const Center(child: Text('Belum ada pesanan.')),
                  ),
                ],
              );
            }
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              children: [
                const Text(
                  'Pesanan Terbaru:',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 10),
                ...orders.map((order) => _OrderTile(order: order)),
              ],
            );
          },
        ),
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
    final isCancelled = order.status == 'cancelled';
    return InkWell(
      onTap: () => Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => OrderDetailPage(order: order))),
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
                  Text(
                    order.product.name,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    order.date,
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.muted,
                    ),
                  ),
                  Text(
                    'Qty: ${order.qty}',
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.muted,
                    ),
                  ),
                ],
              ),
            ),
            // Status + price
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  rupiah(order.total),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: isActive ? AppColors.lightGreen : AppColors.fieldBg,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    isActive
                        ? 'Active'
                        : (isCancelled ? 'Cancelled' : 'Completed'),
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: isActive ? AppColors.primary : AppColors.muted,
                    ),
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
