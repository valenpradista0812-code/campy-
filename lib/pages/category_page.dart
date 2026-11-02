import 'package:flutter/material.dart';
import '../data.dart';
import '../theme/app_colors.dart';
import '../widgets/common_widgets.dart';

/// One reusable page for: Shelter & Sleeping, Camp Kitchen & Cooking,
/// Lightning & Power, and Apparel.
class CategoryPage extends StatelessWidget {
  final String title;
  final List<Product> items;
  const CategoryPage({super.key, required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, size: 22),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        itemCount: items.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.95,
        ),
        itemBuilder: (_, i) {
          final p = items[i];
          return InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: () {
              final cart = [...cartNotifier.value];
              final idx = cart.indexWhere((e) => e.product.name == p.name);
              if (idx >= 0) {
                cart[idx].qty++;
              } else {
                cart.add(CartItem(p, 1, p.price));
              }
              cartNotifier.value = cart;
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${p.name} added to cart'),
                  duration: const Duration(milliseconds: 1200),
                ),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child:
                          ProductImage(asset: p.asset, fallback: p.icon, size: 54),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      p.name,
                      style: const TextStyle(
                          fontSize: 11, fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      rupiah(p.price),
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
