import 'package:flutter/material.dart';
import '../data.dart';
import '../theme/app_colors.dart';
import '../widgets/common_widgets.dart';
import 'product_detail_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';

  final List<String> _categories = const [
    'All',
    'Shelter',
    'Kitchen',
    'Lighting',
    'Apparel',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Product> _filterProducts() {
    final query = _searchController.text.trim().toLowerCase();
    return allProducts.where((p) {
      // Category filter
      if (_selectedCategory == 'Shelter') {
        if (!shelterItems.any((item) => item.name == p.name)) return false;
      } else if (_selectedCategory == 'Kitchen') {
        if (!kitchenItems.any((item) => item.name == p.name)) return false;
      } else if (_selectedCategory == 'Lighting') {
        if (!lightingItems.any((item) => item.name == p.name)) return false;
      } else if (_selectedCategory == 'Apparel') {
        if (!apparelItems.any((item) => item.name == p.name)) return false;
      }

      // Query filter
      if (query.isEmpty) return true;
      return p.name.toLowerCase().contains(query) ||
          p.sub.toLowerCase().contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final results = _filterProducts();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        titleSpacing: 0,
        title: TextField(
          controller: _searchController,
          autofocus: true,
          onChanged: (_) => setState(() {}),
          style: const TextStyle(fontSize: 13),
          decoration: InputDecoration(
            hintText: 'Search tents, bags, stoves...',
            hintStyle:
                const TextStyle(fontSize: 12, color: AppColors.muted),
            border: InputBorder.none,
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, size: 18),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {});
                    },
                  )
                : null,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, size: 22),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: Column(
        children: [
          // ── Category filter pills ────────────────────────────────────────
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: _categories.map((cat) {
                final isSelected = _selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    selected: isSelected,
                    label: Text(cat),
                    labelStyle: TextStyle(
                      fontSize: 11,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w400,
                      color: isSelected ? Colors.white : AppColors.textDark,
                    ),
                    backgroundColor: AppColors.fieldBg,
                    selectedColor: AppColors.primary,
                    checkmarkColor: Colors.white,
                    showCheckmark: false,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.border,
                      ),
                    ),
                    onSelected: (val) {
                      setState(() {
                        _selectedCategory = cat;
                      });
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          const Divider(height: 1, color: AppColors.border),

          // ── Results count / hint ─────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Results (${results.length})',
                  style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.muted),
                ),
              ],
            ),
          ),

          // ── Results list ─────────────────────────────────────────────────
          Expanded(
            child: results.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off_outlined,
                            size: 48, color: AppColors.muted),
                        const SizedBox(height: 10),
                        const Text(
                          'No products found',
                          style: TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Try searching with other keywords or categories.',
                          style:
                              TextStyle(fontSize: 11, color: AppColors.muted),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: results.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, i) {
                      final product = results[i];
                      return InkWell(
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                ProductDetailPage(product: product),
                          ),
                        ),
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: AppColors.imageBg,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: ProductImage(
                                  asset: product.asset,
                                  fallback: product.icon,
                                  size: 38,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product.name,
                                      style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      product.sub,
                                      style: const TextStyle(
                                          fontSize: 10,
                                          color: AppColors.muted),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      rupiah(product.price),
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add_shopping_cart,
                                    size: 18, color: AppColors.primary),
                                onPressed: () {
                                  final cart = [...cartNotifier.value];
                                  final idx = cart.indexWhere((e) =>
                                      e.product.name == product.name);
                                  if (idx >= 0) {
                                    cart[idx].qty++;
                                  } else {
                                    cart.add(CartItem(
                                        product, 1, product.price));
                                  }
                                  cartNotifier.value = cart;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          '${product.name} added to cart'),
                                      duration:
                                          const Duration(seconds: 1),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

