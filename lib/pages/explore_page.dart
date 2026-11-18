import 'package:flutter/material.dart';
import '../data.dart';
import '../services/api_service.dart';
import '../theme/app_colors.dart';
import '../widgets/common_widgets.dart';
import 'category_page.dart';

class ExplorePage extends StatelessWidget {
  const ExplorePage({super.key});

  Future<void> _refresh() async {
    final prods = await ApiService.getProducts();
    productsNotifier.value = prods;
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _refresh,
      child: ValueListenableBuilder<List<Product>>(
        valueListenable: productsNotifier,
        builder: (context, _, __) {
          final cats = <_Cat>[
            _Cat(
              'Shelter &\nSleeping',
              Icons.cabin_outlined,
              'Shelter & Sleeping',
              'shelter',
              shelterItems,
            ),
            _Cat(
              'Camp Kitchen\n& Cooking',
              Icons.soup_kitchen_outlined,
              'Camp Kitchen & Cooking',
              'kitchen',
              kitchenItems,
            ),
            _Cat(
              'Lighting & Power',
              Icons.lightbulb_outline,
              'Lighting & Power',
              'lighting',
              lightingItems,
            ),
            _Cat(
              'Apparel &\nPersonal Gear',
              Icons.backpack_outlined,
              'Apparel & Personal Gear',
              'apparel',
              apparelItems,
            ),
          ];

          final knownSlugs = {'shelter', 'kitchen', 'lighting', 'apparel'};
          final otherCategories = <_Cat>[];
          final otherGroup = <String, List<Product>>{};
          for (final p in productsNotifier.value) {
            final s = p.categorySlug.toLowerCase();
            final c = p.category.toLowerCase();
            if (!knownSlugs.contains(s) &&
                !c.contains('shelter') &&
                !c.contains('kitchen') &&
                !c.contains('cook') &&
                !c.contains('light') &&
                !c.contains('apparel') &&
                !c.contains('gear')) {
              otherGroup.putIfAbsent(p.category, () => []).add(p);
            }
          }
          for (final entry in otherGroup.entries) {
            otherCategories.add(
              _Cat(
                entry.key,
                Icons.category_outlined,
                entry.key,
                entry.key.toLowerCase().replaceAll(' ', '-'),
                entry.value,
              ),
            );
          }
          final allCats = [...cats, ...otherCategories];

          return Column(
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 14, bottom: 12),
                child: Text(
                  'Kategori Alat Camping',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: SearchField(),
              ),
              const SizedBox(height: 14),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  itemCount: allCats.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.82,
                  ),
                  itemBuilder: (_, i) {
                    final c = allCats[i];
                    return InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => CategoryPage(
                            title: c.title,
                            categorySlug: c.slug,
                            initialItems: c.items,
                          ),
                        ),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.border),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x06000000),
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: ProductImage(fallback: c.icon, size: 70),
                              ),
                            ),
                            Text(
                              c.label,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Text(
                                '${c.items.length} alat tersedia',
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: AppColors.muted,
                                ),
                              ),
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
        },
      ),
    );
  }
}

class _Cat {
  final String label;
  final IconData icon;
  final String title;
  final String slug;
  final List<Product> items;
  _Cat(this.label, this.icon, this.title, this.slug, this.items);
}
