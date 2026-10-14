import 'package:flutter/material.dart';
import '../data.dart';
import '../theme.dart';
import '../widgets/common.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        const Center(child: CampyLogo()),
        const SizedBox(height: 12),
        const SearchField(),
        const SizedBox(height: 16),
        const Center(
          child: Text('Welcome to Campy',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        ),
        const Center(
          child: Text('Help your camping feels easy',
              style: TextStyle(fontSize: 10, color: AppColors.muted)),
        ),
        const SizedBox(height: 14),
        const Text('Special Offer',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
        const SizedBox(height: 10),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: specialOffers.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.78,
          ),
          itemBuilder: (_, i) => _OfferCard(product: specialOffers[i]),
        ),
      ],
    );
  }
}

class _OfferCard extends StatelessWidget {
  final Product product;
  const _OfferCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.imageBg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: ProductImage(
                  asset: product.asset, fallback: product.icon, size: 56),
            ),
          ),
          const SizedBox(height: 6),
          Text(product.name,
              style:
                  const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
          Text(product.sub,
              style: const TextStyle(fontSize: 8, color: AppColors.muted)),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('\$${(product.price / 1000).toStringAsFixed(2)}',
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w700)),
              InkWell(
                onTap: () {
                  final items = [...cartNotifier.value];
                  final idx =
                      items.indexWhere((e) => e.product.name == product.name);
                  if (idx >= 0) {
                    items[idx].qty++;
                  } else {
                    items.add(CartItem(product, 1, product.price));
                  }
                  cartNotifier.value = items;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('${product.name} added to cart'),
                        duration: const Duration(seconds: 1)),
                  );
                },
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: const Icon(Icons.add, size: 14, color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
