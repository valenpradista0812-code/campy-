import 'package:flutter/material.dart';
import '../data.dart';
import '../services/api_service.dart';
import '../theme/app_colors.dart';
import '../widgets/common_widgets.dart';
import 'product_detail_page.dart';

/// Reusable CategoryPage:
/// Mengambil dan menyaring produk langsung dari database (productsNotifier) secara real-time.
class CategoryPage extends StatefulWidget {
  final String title;
  final String? categorySlug;
  final List<Product>? initialItems;

  const CategoryPage({
    super.key,
    required this.title,
    this.categorySlug,
    this.initialItems,
  });

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  bool _isRefreshing = false;

  Future<void> _refresh() async {
    setState(() => _isRefreshing = true);
    try {
      final prods = await ApiService.getProducts();
      productsNotifier.value = prods;
    } finally {
      if (mounted) setState(() => _isRefreshing = false);
    }
  }

  List<Product> _filterCategoryProducts(List<Product> allProds) {
    final titleLower = widget.title.toLowerCase();
    final slug = widget.categorySlug?.toLowerCase() ?? '';

    if (slug == 'shelter' || titleLower.contains('shelter')) {
      return shelterItems;
    } else if (slug == 'kitchen' || titleLower.contains('kitchen') || titleLower.contains('cook')) {
      return kitchenItems;
    } else if (slug == 'lighting' || slug == 'lightning' || titleLower.contains('light')) {
      return lightingItems;
    } else if (slug == 'apparel' || titleLower.contains('apparel') || titleLower.contains('gear')) {
      return apparelItems;
    }

    return allProds.where((p) {
      if (slug.isNotEmpty && p.categorySlug.toLowerCase() == slug) return true;
      return p.category.toLowerCase().contains(titleLower);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          widget.title,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        ),
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, size: 22),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, size: 20),
            tooltip: 'Segarkan data',
            onPressed: _refresh,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: ValueListenableBuilder<List<Product>>(
          valueListenable: productsNotifier,
          builder: (context, allProds, _) {
            final items = _filterCategoryProducts(allProds);

            if (items.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.6,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.inventory_2_outlined,
                              size: 56,
                              color: AppColors.muted,
                            ),
                            const SizedBox(height: 14),
                            Text(
                              'Belum ada alat untuk kategori "${widget.title}".',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textDark,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Barang yang ditambahkan di inventaris akan otomatis muncul di sini.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.muted,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                              ),
                              onPressed: _refresh,
                              icon: const Icon(Icons.refresh, size: 16),
                              label: const Text('Muat Ulang'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }

            return GridView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
              itemCount: items.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.82,
              ),
              itemBuilder: (_, i) {
                final p = items[i];
                return InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ProductDetailPage(product: p),
                    ),
                  ),
                  child: Container(
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
                              asset: p.asset,
                              imageUrl: p.imageUrl,
                              fallback: p.icon,
                              size: 58,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          p.name,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          p.sub,
                          style: const TextStyle(
                            fontSize: 8,
                            color: AppColors.muted,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              rupiah(p.price),
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              '${p.stock} stok',
                              style: const TextStyle(
                                fontSize: 9,
                                color: AppColors.muted,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
