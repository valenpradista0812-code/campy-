import 'package:flutter/material.dart';
import '../data.dart';
import '../services/api_service.dart';
import '../theme/app_colors.dart';
import '../widgets/common_widgets.dart';
import 'checkout_page.dart';

class ProductDetailPage extends StatefulWidget {
  final Product product;
  const ProductDetailPage({super.key, required this.product});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  int _qty = 1;
  int _days = 1;

  bool get _isFav {
    return wishlistNotifier.value
        .any((p) => p.name == widget.product.name || (p.id.isNotEmpty && p.id == widget.product.id));
  }

  void _toggleFav() async {
    final prevList = [...wishlistNotifier.value];
    final isAlreadyFav = _isFav;

    if (isAlreadyFav) {
      wishlistNotifier.value = prevList
          .where((p) => p.name != widget.product.name && (widget.product.id.isEmpty || p.id != widget.product.id))
          .toList();
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${widget.product.name} removed from wishlist'),
          duration: const Duration(seconds: 1),
        ),
      );
      if (widget.product.id.isNotEmpty) {
        final ok = await ApiService.removeWishlist(widget.product.id);
        if (!ok && mounted) {
          wishlistNotifier.value = prevList; // rollback
          setState(() {});
        }
      }
    } else {
      wishlistNotifier.value = [...prevList, widget.product];
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${widget.product.name} added to wishlist'),
          duration: const Duration(seconds: 1),
        ),
      );
      if (widget.product.id.isNotEmpty) {
        final ok = await ApiService.addWishlist(widget.product.id);
        if (!ok && mounted) {
          wishlistNotifier.value = prevList; // rollback
          setState(() {});
        }
      }
    }
  }

  void _addToCart() {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();

    final p = widget.product;
    final items = [...cartNotifier.value];
    final idx = items.indexWhere((e) => e.product.name == p.name);
    final inCart = idx >= 0 ? items[idx].qty : 0;

    if (p.stock <= 0) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Produk habis (Out of stock)'),
          duration: Duration(milliseconds: 1200),
        ),
      );
      return;
    }

    if (inCart + _qty > p.stock) {
      messenger.showSnackBar(
        SnackBar(
          content: Text('Stok tidak mencukupi (Tersisa: ${p.stock}, di cart: $inCart)'),
          duration: const Duration(milliseconds: 1200),
        ),
      );
      return;
    }

    if (idx >= 0) {
      items[idx].qty += _qty;
    } else {
      items.add(CartItem(p, _qty, p.price));
    }
    cartNotifier.value = items;
    messenger.showSnackBar(
      SnackBar(
        content: Text('${p.name} ($_qty items) added to cart'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _rentNow() {
    final messenger = ScaffoldMessenger.of(context);
    final p = widget.product;
    final items = [...cartNotifier.value];
    final idx = items.indexWhere((e) => e.product.name == p.name);
    final inCart = idx >= 0 ? items[idx].qty : 0;

    if (p.stock <= 0) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Produk habis (Out of stock)'),
          duration: Duration(milliseconds: 1200),
        ),
      );
      return;
    }

    if (inCart + _qty > p.stock) {
      messenger.showSnackBar(
        SnackBar(
          content: Text('Stok tidak mencukupi (Tersisa: ${p.stock})'),
          duration: const Duration(milliseconds: 1200),
        ),
      );
      return;
    }

    if (idx >= 0) {
      items[idx].qty += _qty;
    } else {
      items.add(CartItem(p, _qty, p.price));
    }
    cartNotifier.value = items;
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const CheckoutPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    final totalPrice = p.price * _qty * _days;
    final isSoldOut = p.stock <= 0;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Product Details',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, size: 22),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isFav ? Icons.favorite : Icons.favorite_border,
              color: _isFav ? Colors.red : AppColors.muted,
              size: 20,
            ),
            onPressed: _toggleFav,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // ── Showcase image ─────────────────────────────────────────
                Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    color: AppColors.imageBg,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: ProductImage(
                      asset: p.asset,
                      imageUrl: p.imageUrl,
                      fallback: p.icon,
                      size: 96,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // ── Title & Price ──────────────────────────────────────────
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            p.name,
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            p.sub,
                            style: const TextStyle(
                                fontSize: 11, color: AppColors.muted),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          rupiah(p.price),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                        const Text(
                          '/ day',
                          style: TextStyle(
                              fontSize: 10, color: AppColors.muted),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // ── Category & Stock Badges (Real Database Info) ───────────
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.fieldBg,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.category_outlined,
                              size: 13, color: AppColors.primary),
                          const SizedBox(width: 4),
                          Text(
                            p.category,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _StockBadge(stock: p.stock),
                    if (p.isSpecialOffer)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade50,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.amber.shade300),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.local_offer_outlined,
                                size: 12, color: Colors.amber),
                            SizedBox(width: 4),
                            Text(
                              'Special Offer',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFFB78103),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const Divider(height: 28),

                // ── Selectors (Duration & Quantity) ────────────────────────
                Row(
                  children: [
                    // Quantity
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Quantity',
                              style: TextStyle(
                                  fontSize: 11, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove, size: 16),
                                  onPressed: _qty > 1
                                      ? () => setState(() => _qty--)
                                      : null,
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(
                                      minWidth: 32, minHeight: 32),
                                ),
                                Text('$_qty',
                                    style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700)),
                                IconButton(
                                  icon: const Icon(Icons.add, size: 16),
                                  onPressed: (!isSoldOut && _qty < p.stock)
                                      ? () => setState(() => _qty++)
                                      : null,
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(
                                      minWidth: 32, minHeight: 32),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),
                    // Rental Days
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Rental Duration',
                              style: TextStyle(
                                  fontSize: 11, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove, size: 16),
                                  onPressed: _days > 1
                                      ? () => setState(() => _days--)
                                      : null,
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(
                                      minWidth: 32, minHeight: 32),
                                ),
                                Text('$_days Day${_days > 1 ? 's' : ''}',
                                    style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700)),
                                IconButton(
                                  icon: const Icon(Icons.add, size: 16),
                                  onPressed: () => setState(() => _days++),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(
                                      minWidth: 32, minHeight: 32),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Divider(height: 28),

                // ── Description (From Database) ────────────────────────────
                const Text('Description',
                    style:
                        TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                Text(
                  p.description.trim().isNotEmpty
                      ? p.description.trim()
                      : 'Tidak ada deskripsi tambahan untuk produk ini.',
                  style: const TextStyle(
                      fontSize: 11, height: 1.5, color: AppColors.muted),
                ),
                const SizedBox(height: 18),

                // ── Detail Informasi Produk (From Database) ────────────────
                const Text('Detail Barang',
                    style:
                        TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                _ChecklistRow('Kategori: ${p.category}'),
                if (p.sub.isNotEmpty) _ChecklistRow('Varian / Model: ${p.sub}'),
                _ChecklistRow('Stok Tersedia: ${p.stock} unit'),
                _ChecklistRow('Harga Sewa: ${rupiah(p.price)} / hari'),
              ],
            ),
          ),

          // ── Bottom action bar ────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: AppColors.border)),
            ),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Total Estimate',
                        style: TextStyle(fontSize: 10, color: AppColors.muted)),
                    Text(
                      rupiah(totalPrice),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton(
                    onPressed: isSoldOut ? null : _addToCart,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      disabledForegroundColor: AppColors.muted,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(isSoldOut ? 'Sold Out' : 'Add to Cart',
                        style: const TextStyle(
                            fontSize: 11, fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: isSoldOut ? null : _rentNow,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: AppColors.border,
                      disabledForegroundColor: AppColors.muted,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(isSoldOut ? 'Unavailable' : 'Rent Now',
                        style: const TextStyle(
                            fontSize: 11, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StockBadge extends StatelessWidget {
  final int stock;
  const _StockBadge({required this.stock});

  @override
  Widget build(BuildContext context) {
    final available = stock > 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: available ? AppColors.lightGreen : const Color(0xFFFBE4E4),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        available ? 'Stock: $stock' : 'Out of stock',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: available ? AppColors.primaryDark : const Color(0xFFB3261E),
        ),
      ),
    );
  }
}

class _FeatureChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _FeatureChip(this.icon, this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.fieldBg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(label,
              style:
                  const TextStyle(fontSize: 10, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _ChecklistRow extends StatelessWidget {
  final String text;
  const _ChecklistRow(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          const Icon(Icons.check_circle, size: 14, color: AppColors.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text,
                style: const TextStyle(
                    fontSize: 11, color: AppColors.textDark)),
          ),
        ],
      ),
    );
  }
}
