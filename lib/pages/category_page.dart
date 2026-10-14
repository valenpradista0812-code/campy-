import 'package:flutter/material.dart';
import '../data.dart';
import '../theme.dart';
import '../widgets/common.dart';

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
          return Container(
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
                        ProductImage(asset: p.asset, fallback: p.icon, size: 64),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(p.name, style: const TextStyle(fontSize: 9)),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
