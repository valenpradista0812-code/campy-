import 'package:flutter/material.dart';
import '../data.dart';
import '../services/api_service.dart';
import '../theme/app_colors.dart';
import '../widgets/common_widgets.dart';
import 'ai_chat_page.dart';
import 'product_detail_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _selectedCategory = 'Semua';

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    catalogLoading.value = true;
    catalogError.value = null;
    final prods = await ApiService.getProducts();
    productsNotifier.value = prods;
    catalogError.value = ApiService.lastError;
    catalogLoading.value = false;
  }

  List<Product> _getFilteredProducts(List<Product> all) {
    if (_selectedCategory == 'Semua') return all;
    return all
        .where((p) =>
            p.category.toLowerCase() == _selectedCategory.toLowerCase() ||
            p.categorySlug.toLowerCase() == _selectedCategory.toLowerCase())
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AiChatPage()),
          );
        },
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        icon: const Icon(Icons.auto_awesome, size: 18),
        label: const Text(
          'Tanya AI',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: AnimatedBuilder(
        animation: Listenable.merge([
          productsNotifier,
          catalogLoading,
          catalogError,
        ]),
        builder: (context, _) {
          final all = allProducts;
          final offers = specialOffers;
          final filtered = _getFilteredProducts(all);

          if (catalogLoading.value && all.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (catalogError.value != null && all.isEmpty) {
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
                          const Icon(Icons.wifi_off_rounded, size: 48, color: Colors.amber),
                          const SizedBox(height: 12),
                          Text(
                            'Gagal memuat katalog: ${catalogError.value}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: AppColors.muted, fontSize: 12),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            onPressed: _refresh,
                            icon: const Icon(Icons.refresh, size: 16),
                            label: const Text('Coba Lagi'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          }

          return ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            children: [
              const Center(
                child: CampyLogo(color: AppColors.primary, size: 48),
              ),
              const SizedBox(height: 12),
              const SearchField(),
              const SizedBox(height: 16),
              const Center(
                child: Text(
                  'Welcome to Campy',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
              const Center(
                child: Text(
                  'Help your camping feels easy',
                  style: TextStyle(fontSize: 10, color: AppColors.muted),
                ),
              ),
              const SizedBox(height: 16),

              // ── Gemini AI Assistant Banner ──────────────────────────────
              Container(
                margin: const EdgeInsets.only(bottom: 18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF5F7C5B), Color(0xFF7A9376)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AiChatPage()),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.auto_awesome,
                              color: Colors.white,
                              size: 26,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Text(
                                      'Tanya Campy AI',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.amber.shade400,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Text(
                                        'Gemini',
                                        style: TextStyle(
                                          color: Colors.black87,
                                          fontSize: 9,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Konsultasi alat camping & tips mendaki dengan asisten cerdas',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: Colors.white70,
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // ── Bagian Special Offers (Jika ada) ─────────────────────────
              if (offers.isNotEmpty) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Special Offer',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                    ),
                    Text(
                      '${offers.length} Promo',
                      style: const TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: offers.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.78,
                  ),
                  itemBuilder: (_, i) => _OfferCard(product: offers[i]),
                ),
                const SizedBox(height: 20),
              ],

              // ── Bagian Semua Alat Camping (Dari Database) ────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Semua Alat Camping',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                  Text(
                    '${all.length} Total Alat',
                    style: const TextStyle(fontSize: 11, color: AppColors.muted),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Filter kategori langsung dari data yang ada di database
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    'Semua',
                    ...{
                      ...all
                          .map((p) => p.category.trim())
                          .where((c) => c.isNotEmpty)
                    }
                  ].map((cat) {
                    final isSelected = _selectedCategory == cat;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(cat),
                        selected: isSelected,
                        selectedColor: AppColors.primary,
                        backgroundColor: AppColors.fieldBg,
                        labelStyle: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? Colors.white : AppColors.textDark,
                        ),
                        side: BorderSide(
                          color: isSelected ? AppColors.primary : AppColors.border,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        onSelected: (_) => setState(() => _selectedCategory = cat),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 12),

              // Grid Produk
              if (filtered.isEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  alignment: Alignment.center,
                  child: Column(
                    children: const [
                      Icon(Icons.inventory_2_outlined, size: 40, color: AppColors.muted),
                      SizedBox(height: 8),
                      Text(
                        'Belum ada alat camping di database.',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textDark),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Petugas dapat menambahkan barang melalui panel Petugas.',
                        style: TextStyle(fontSize: 10, color: AppColors.muted),
                      ),
                    ],
                  ),
                )
              else
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filtered.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.78,
                  ),
                  itemBuilder: (_, i) => _OfferCard(product: filtered[i]),
                ),
            ],
          );
        },
      ),
    ),
    );
  }
}

class _OfferCard extends StatelessWidget {
  final Product product;
  const _OfferCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => ProductDetailPage(product: product)),
      ),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(8),
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
                  asset: product.asset,
                  imageUrl: product.imageUrl,
                  fallback: product.icon,
                  size: 56,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              product.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
            ),
            Text(
              product.sub.isNotEmpty ? product.sub : product.category,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 8, color: AppColors.muted),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  rupiah(product.price),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                InkWell(
                  onTap: () {
                    final items = [...cartNotifier.value];
                    final idx = items.indexWhere(
                      (e) =>
                          e.product.name == product.name ||
                          (e.product.id.isNotEmpty &&
                              e.product.id == product.id),
                    );
                    if (idx >= 0) {
                      items[idx].qty++;
                    } else {
                      items.add(CartItem(product, 1, product.price));
                    }
                    cartNotifier.value = items;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${product.name} added to cart'),
                        duration: const Duration(seconds: 1),
                      ),
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
      ),
    );
  }
}
