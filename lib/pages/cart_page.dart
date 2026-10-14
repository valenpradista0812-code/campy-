import 'package:flutter/material.dart';
import '../data.dart';
import '../theme.dart';
import '../widgets/common.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 14),
          child: Text('Cart',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
        ),
        Expanded(
          child: ValueListenableBuilder<List<CartItem>>(
            valueListenable: cartNotifier,
            builder: (context, items, _) {
              if (items.isEmpty) {
                return const Center(child: Text('Your cart is empty'));
              }
              return ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, i) => _CartTile(
                  item: items[i],
                  onChanged: () => cartNotifier.value = [...items],
                  onRemove: () {
                    final next = [...items]..removeAt(i);
                    cartNotifier.value = next;
                  },
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
          child: SizedBox(
            width: double.infinity,
            height: 40,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Go to Checkout',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            ),
          ),
        ),
      ],
    );
  }
}

class _CartTile extends StatelessWidget {
  final CartItem item;
  final VoidCallback onChanged;
  final VoidCallback onRemove;
  const _CartTile(
      {required this.item, required this.onChanged, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Stack(
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.imageBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ProductImage(
                    asset: item.product.asset,
                    fallback: item.product.icon,
                    size: 40),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.product.name,
                        style: const TextStyle(
                            fontSize: 10, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _QtyButton(
                          icon: Icons.remove,
                          onTap: () {
                            if (item.qty > 1) {
                              item.qty--;
                              onChanged();
                            }
                          },
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Text('${item.qty}',
                              style: const TextStyle(fontSize: 10)),
                        ),
                        _QtyButton(
                          icon: Icons.add,
                          onTap: () {
                            item.qty++;
                            onChanged();
                          },
                        ),
                        const Spacer(),
                        Text(rupiah(item.unitPrice * item.qty),
                            style: const TextStyle(fontSize: 7)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            right: 0,
            top: 0,
            child: InkWell(
              onTap: onRemove,
              child: const Icon(Icons.close, size: 12, color: AppColors.muted),
            ),
          ),
        ],
      ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _QtyButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Icon(icon, size: 14, color: AppColors.primary),
    );
  }
}
