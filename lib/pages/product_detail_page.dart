import 'package:flutter/material.dart';
import '../data.dart';
import '../theme/app_colors.dart';
import '../widgets/common_widgets.dart';

/// Detail barang: gambar, nama, harga, jumlah stok, deskripsi,
/// dan tombol tambah ke cart di bagian bawah.
class ProductDetailPage extends StatelessWidget {
  final Product product;
  const ProductDetailPage({super.key, required this.product});

  void _addToCart(BuildContext context) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();

    final cart = [...cartNotifier.value];
    final idx = cart.indexWhere((e) => e.product.name == product.name);
    final inCart = idx >= 0 ? cart[idx].qty : 0;

    if (inCart >= product.stock) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Stock limit reached'),
          duration: Duration(milliseconds: 1200),
        ),
      );
      return;
    }

    if (idx >= 0) {
      cart[idx].qty++;
    } else {
      cart.add(CartItem(product, 1, product.price));
    }
    cartNotifier.value = cart;

    messenger.showSnackBar(
      SnackBar(
        content: Text('${product.name} added to cart'),
        duration: const Duration(milliseconds: 1200),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Detail',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, size: 22),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    height: 220,
                    decoration: BoxDecoration(
                      color: AppColors.imageBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: ProductImage(
                        asset: product.asset,
                        fallback: product.icon,
                        size: 120,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(product.name,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text(product.sub,
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textGrey)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Text(rupiah(product.price),
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary)),
                      const Spacer(),
                      _StockBadge(stock: product.stock),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text('Description',
                      style:
                          TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  Text(product.description,
                      style: const TextStyle(
                          fontSize: 12,
                          height: 1.5,
                          color: AppColors.textDark)),
                ],
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: ValueListenableBuilder<List<CartItem>>(
              valueListenable: cartNotifier,
              builder: (context, _, __) {
                final inCart = cartQtyOf(product);
                final soldOut = product.stock <= 0;
                final maxed = !soldOut && inCart >= product.stock;
                return Container(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(top: BorderSide(color: AppColors.border)),
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed:
                          (soldOut || maxed) ? null : () => _addToCart(context),
                      icon: const Icon(Icons.add, size: 18),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        disabledBackgroundColor: AppColors.border,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      label: Text(
                        soldOut
                            ? 'Out of Stock'
                            : maxed
                                ? 'Max Stock in Cart'
                                : inCart > 0
                                    ? 'Add to Cart ($inCart in cart)'
                                    : 'Add to Cart',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
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

class _StockBadge extends StatelessWidget {
  final int stock;
  const _StockBadge({required this.stock});

  @override
  Widget build(BuildContext context) {
    final available = stock > 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: available ? AppColors.lightGreen : const Color(0xFFFBE4E4),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        available ? 'Stock: $stock' : 'Out of stock',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: available ? AppColors.primaryDark : const Color(0xFFB3261E),
        ),
      ),
    );
  }
}
