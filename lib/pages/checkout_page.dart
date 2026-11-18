import 'package:flutter/material.dart';
import '../data.dart';
import '../services/api_service.dart';
import '../theme/app_colors.dart';
import '../widgets/common_widgets.dart';
import 'payment_methods_page.dart';
import 'payment_page.dart';

enum DeliveryMethod { pickup, delivery }

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  DeliveryMethod _selectedMethod = DeliveryMethod.pickup;
  bool _isCalculating = true;
  bool _isPlacingOrder = false;
  int? _serverSubtotal;
  int? _serverDeliveryFee;
  int? _serverTotal;
  String? _quoteError;
  String? _deliveryAddress;

  @override
  void initState() {
    super.initState();
    _recalculate();
    if (ApiService.isAuthenticated) {
      ApiService.getProfile().then((profile) {
        if (!mounted) return;
        setState(() {
          _deliveryAddress = profile?['address'] as String?;
        });
      });
    }
  }

  Future<void> _recalculate() async {
    if (mounted) {
      setState(() {
        _isCalculating = true;
        _quoteError = null;
      });
    }
    final quote = await ApiService.calculateCheckout(
      items: cartNotifier.value,
      deliveryMethod: _selectedMethod.name,
    );
    if (!mounted) return;
    setState(() {
      _isCalculating = false;
      _serverSubtotal = (quote?['subtotal'] as num?)?.toInt();
      _serverDeliveryFee = (quote?['deliveryFee'] as num?)?.toInt();
      _serverTotal = (quote?['total'] as num?)?.toInt();
      _quoteError = quote == null ? ApiService.lastError : null;
    });
  }

  Future<void> _placeOrder() async {
    if (!ApiService.isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan login untuk membuat pesanan.')),
      );
      return;
    }

    setState(() => _isPlacingOrder = true);
    final result = await ApiService.createOrder(
      items: cartNotifier.value,
      deliveryMethod: _selectedMethod.name,
      paymentMethod: selectedPaymentMethod.value,
      deliveryAddress: _deliveryAddress,
    );
    if (!mounted) return;
    setState(() => _isPlacingOrder = false);

    if (result['success'] != true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result['message'] as String? ?? 'Pesanan gagal dibuat.',
          ),
          backgroundColor: Colors.red.shade700,
        ),
      );
      return;
    }

    final order = result['data'] as Map<String, dynamic>;
    final orderId = order['id'] as String;
    final total = (order['total'] as num).toInt();
    ordersNotifier.value = [
      AppOrder.fromJson(order),
      ...ordersNotifier.value.where((item) => item.id != orderId),
    ];
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PaymentPage(
          total: total,
          orderId: orderId,
          paymentMethod: selectedPaymentMethod.value,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Checkout',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        ),
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
          final subtotal = _serverSubtotal;
          final deliveryFee = _serverDeliveryFee;
          final grandTotal = _serverTotal;

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
                              _recalculate();
                            },
                          ),
                          const SizedBox(height: 10),
                          _DeliveryOptionTile(
                            isSelected:
                                _selectedMethod == DeliveryMethod.delivery,
                            icon: Icons.local_shipping_outlined,
                            title: 'Delivery',
                            subtitle: (_deliveryAddress != null &&
                                    _deliveryAddress!.isNotEmpty)
                                ? _deliveryAddress!
                                : 'Dikirim ke alamat profil akun Anda',
                            feeBadge: '+${rupiah(20000)}',
                            isFree: false,
                            onTap: () {
                              setState(() {
                                _selectedMethod = DeliveryMethod.delivery;
                              });
                              _recalculate();
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
                                child: Text(
                                  'BCA',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 8,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: ValueListenableBuilder<String>(
                                valueListenable: selectedPaymentMethod,
                                builder: (context, method, _) => Text(
                                  '$method Transfer',
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                            ),
                            const Icon(
                              Icons.chevron_right,
                              size: 16,
                              color: AppColors.muted,
                            ),
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
                        const Text(
                          'Subtotal',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.muted,
                          ),
                        ),
                        Text(
                          subtotal == null ? '...' : rupiah(subtotal),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Delivery Fee',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.muted,
                          ),
                        ),
                        Text(
                          deliveryFee == null
                              ? '...'
                              : (deliveryFee == 0
                                    ? 'Free'
                                    : rupiah(deliveryFee)),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: deliveryFee == 0
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
                        const Text(
                          'Total',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          grandTotal == null ? '...' : rupiah(grandTotal),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: ElevatedButton(
                        onPressed:
                            _isCalculating ||
                                _isPlacingOrder ||
                                grandTotal == null
                            ? null
                            : _placeOrder,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: _isPlacingOrder
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                _isCalculating ? 'Calculating...' : 'Pay',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
              if (_quoteError != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                  child: Text(
                    'Gagal menghitung checkout: $_quoteError',
                    style: TextStyle(color: Colors.red.shade700, fontSize: 11),
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
                Text(
                  item.product.name,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  item.product.sub,
                  style: const TextStyle(fontSize: 10, color: AppColors.muted),
                ),
                Text(
                  'Qty: ${item.qty}',
                  style: const TextStyle(fontSize: 10, color: AppColors.muted),
                ),
              ],
            ),
          ),
          Text(
            rupiah(item.unitPrice * item.qty),
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
          ),
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
          Text(
            title,
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.muted,
              fontWeight: FontWeight.w500,
            ),
          ),
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
              Icon(
                icon,
                size: 20,
                color: isSelected ? AppColors.primary : AppColors.muted,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w600,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 2),
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
