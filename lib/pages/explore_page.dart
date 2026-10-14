import 'package:flutter/material.dart';
import '../data.dart';
import '../theme.dart';
import '../widgets/common.dart';
import 'category_page.dart';

class ExplorePage extends StatelessWidget {
  const ExplorePage({super.key});

  @override
  Widget build(BuildContext context) {
    final cats = <_Cat>[
      _Cat('Shelter &\nSleeping', Icons.cabin_outlined, 'Shelter & Sleeping',
          shelterItems),
      _Cat('Camp Kitchen\n& Cooking', Icons.soup_kitchen_outlined,
          'Camp Kitchen & Cooking', kitchenItems),
      _Cat('Lighting & Power', Icons.lightbulb_outline, 'Lightning & Power',
          lightingItems),
      _Cat('Apparel &\nPersonal Gear', Icons.backpack_outlined, 'Apparel',
          apparelItems),
    ];

    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 14, bottom: 12),
          child: Text('Find Products',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: SearchField(),
        ),
        const SizedBox(height: 14),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            itemCount: cats.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.82,
            ),
            itemBuilder: (_, i) {
              final c = cats[i];
              return InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) =>
                      CategoryPage(title: c.title, items: c.items),
                )),
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
                          child: ProductImage(fallback: c.icon, size: 80),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Text(c.label,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 10)),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _Cat {
  final String label;
  final IconData icon;
  final String title;
  final List<Product> items;
  _Cat(this.label, this.icon, this.title, this.items);
}
