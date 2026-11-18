import 'package:flutter/material.dart';

/// Helper to map string icon identifiers from backend to Flutter Material IconData
IconData iconFromName(String? name) {
  switch (name?.toLowerCase()) {
    case 'cabin':
      return Icons.cabin;
    case 'house':
      return Icons.house;
    case 'bed':
      return Icons.bed;
    case 'local_fire_department':
      return Icons.local_fire_department;
    case 'soup_kitchen':
      return Icons.soup_kitchen;
    case 'lightbulb':
      return Icons.lightbulb;
    case 'flashlight_on':
      return Icons.flashlight_on;
    case 'backpack':
      return Icons.backpack;
    case 'checkroom':
      return Icons.checkroom;
    case 'hiking':
      return Icons.hiking;
    case 'bedtime':
      return Icons.bedtime;
    default:
      return Icons.inventory_2;
  }
}

class Product {
  final String id;
  final String name;
  final String sub;
  final String category;
  final String categorySlug;
  final int price;
  final bool isSpecialOffer;
  final String? asset;
  final String? imageUrl;
  final IconData icon;
  final String iconName;
  final String description;
  final int stock;

  const Product({
    this.id = '',
    required this.name,
    required this.sub,
    this.category = 'General',
    this.categorySlug = 'general',
    required this.price,
    this.isSpecialOffer = false,
    this.asset,
    this.imageUrl,
    required this.icon,
    this.iconName = 'inventory_2',
    this.description = 'No description available.',
    this.stock = 0,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    final iconStr = json['icon'] as String? ?? 'inventory_2';
    return Product(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? '',
      sub: json['sub'] as String? ?? '',
      category: json['category'] as String? ?? 'General',
      categorySlug: json['category_slug'] as String? ?? 'general',
      price: (json['price'] as num?)?.toInt() ?? 0,
      isSpecialOffer: json['is_special_offer'] == true,
      asset: json['asset'] as String?,
      imageUrl: json['image_url'] as String?,
      icon: iconFromName(iconStr),
      iconName: iconStr,
      description:
          json['description'] as String? ?? 'No description available.',
      stock: (json['stock'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'sub': sub,
    'category': category,
    'category_slug': categorySlug,
    'price': price,
    'is_special_offer': isSpecialOffer,
    'asset': asset,
    'image_url': imageUrl,
    'icon': iconName,
    'description': description,
    'stock': stock,
  };
}

class CartItem {
  final Product product;
  int qty;
  final int unitPrice;

  CartItem(this.product, this.qty, this.unitPrice);
}

final ValueNotifier<List<CartItem>> cartNotifier =
    ValueNotifier<List<CartItem>>([]);

String rupiah(int value) {
  return 'Rp ${value.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (match) => '${match[1]}.')}';
}

// ─── Global Notifiers (Live API State) ─────────────────────────────────────────

final ValueNotifier<List<Product>> productsNotifier =
    ValueNotifier<List<Product>>([]);
final ValueNotifier<bool> catalogLoading = ValueNotifier<bool>(true);
final ValueNotifier<String?> catalogError = ValueNotifier<String?>(null);

final ValueNotifier<List<Product>> wishlistNotifier =
    ValueNotifier<List<Product>>([]);

final ValueNotifier<List<AppOrder>> ordersNotifier =
    ValueNotifier<List<AppOrder>>([]);

final ValueNotifier<List<AppTransaction>> transactionsNotifier =
    ValueNotifier<List<AppTransaction>>([]);
final ValueNotifier<String> selectedPaymentMethod = ValueNotifier<String>(
  'BCA',
);

// ─── Dynamic Category Getters ─────────────────────────────────────────────────

List<Product> get allProducts => productsNotifier.value;

List<Product> get specialOffers =>
    allProducts.where((p) => p.isSpecialOffer).toList();

List<Product> get shelterItems => allProducts
    .where(
      (p) =>
          p.categorySlug == 'shelter' ||
          p.category.toLowerCase().contains('shelter') ||
          p.category.toLowerCase().contains('sleep') ||
          p.category.toLowerCase().contains('tenda') ||
          p.category.toLowerCase().contains('tent'),
    )
    .toList();

List<Product> get kitchenItems => allProducts
    .where(
      (p) =>
          p.categorySlug == 'kitchen' ||
          p.category.toLowerCase().contains('kitchen') ||
          p.category.toLowerCase().contains('cook') ||
          p.category.toLowerCase().contains('kompor') ||
          p.category.toLowerCase().contains('masak'),
    )
    .toList();

List<Product> get lightingItems => allProducts
    .where(
      (p) =>
          p.categorySlug == 'lighting' ||
          p.categorySlug == 'lightning' ||
          p.category.toLowerCase().contains('light') ||
          p.category.toLowerCase().contains('lampu') ||
          p.category.toLowerCase().contains('senter'),
    )
    .toList();

List<Product> get apparelItems => allProducts
    .where(
      (p) =>
          p.categorySlug == 'apparel' ||
          p.category.toLowerCase().contains('apparel') ||
          p.category.toLowerCase().contains('gear') ||
          p.category.toLowerCase().contains('jaket') ||
          p.category.toLowerCase().contains('tas') ||
          p.category.toLowerCase().contains('carrier'),
    )
    .toList();

/// Number of units of [product] currently in the cart.
int cartQtyOf(Product product) {
  final idx = cartNotifier.value.indexWhere(
    (e) =>
        e.product.name == product.name ||
        (e.product.id.isNotEmpty && e.product.id == product.id),
  );
  return idx >= 0 ? cartNotifier.value[idx].qty : 0;
}

// ─── Transaction & Order models ───────────────────────────────────────────────

class AppOrderItem {
  final String productId;
  final String productName;
  final String? productSub;
  final int qty;
  final int unitPrice;

  const AppOrderItem({
    required this.productId,
    required this.productName,
    this.productSub,
    required this.qty,
    required this.unitPrice,
  });

  factory AppOrderItem.fromJson(Map<String, dynamic> json) {
    return AppOrderItem(
      productId: json['product_id']?.toString() ?? '',
      productName: json['product_name'] as String? ?? 'Item Campy',
      productSub: json['product_sub'] as String?,
      qty: (json['qty'] as num?)?.toInt() ?? 1,
      unitPrice: (json['unit_price'] as num?)?.toInt() ?? 0,
    );
  }
}

class AppTransaction {
  final String id;
  final String orderId;
  final int amount;
  final String date;
  final String time;
  final String status; // 'success' | 'failed'
  final String paymentMethod;
  final String recipient;

  const AppTransaction({
    this.id = '',
    required this.orderId,
    required this.amount,
    required this.date,
    this.time = '',
    required this.status,
    required this.paymentMethod,
    this.recipient = 'Campy',
  });

  factory AppTransaction.fromJson(Map<String, dynamic> json) {
    return AppTransaction(
      id: json['id']?.toString() ?? '',
      orderId: json['order_id'] as String? ?? '',
      amount: (json['amount'] as num?)?.toInt() ?? 0,
      date: json['date'] as String? ?? '',
      time: json['time'] as String? ?? '',
      status: json['status'] as String? ?? 'success',
      paymentMethod: json['payment_method'] as String? ?? 'BCA',
      recipient: json['recipient'] as String? ?? 'Campy',
    );
  }
}

class AppOrder {
  final String id;
  final Product product;
  final List<AppOrderItem> items;
  final int qty;
  final int subtotal;
  final int deliveryFee;
  final int total;
  final String deliveryMethod;
  final String paymentMethod;
  final String location;
  final String date;
  final String status; // 'active' | 'completed' | 'cancelled'

  const AppOrder({
    required this.id,
    required this.product,
    this.items = const [],
    required this.qty,
    this.subtotal = 0,
    this.deliveryFee = 0,
    this.total = 0,
    this.deliveryMethod = 'pickup',
    this.paymentMethod = 'BCA',
    this.location = '',
    required this.date,
    required this.status,
  });

  factory AppOrder.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] ?? json['order_items'];
    final itemsList = <AppOrderItem>[];
    if (rawItems is List) {
      for (final it in rawItems) {
        if (it is Map<String, dynamic>) {
          itemsList.add(AppOrderItem.fromJson(it));
        }
      }
    }

    final pName =
        json['product_name'] as String? ??
        (itemsList.isNotEmpty ? itemsList.first.productName : 'Item Campy');
    final pSub =
        json['product_sub'] as String? ??
        (itemsList.isNotEmpty ? itemsList.first.productSub ?? '' : '');
    final uPrice =
        (json['unit_price'] as num?)?.toInt() ??
        (itemsList.isNotEmpty ? itemsList.first.unitPrice : 0);

    // Try finding matching product in catalogue
    Product? foundProd;
    try {
      foundProd = allProducts.firstWhere(
        (p) =>
            p.name == pName ||
            (itemsList.isNotEmpty && p.id == itemsList.first.productId),
      );
    } catch (_) {}

    final displayProduct =
        foundProd ??
        Product(name: pName, sub: pSub, price: uPrice, icon: Icons.inventory_2);

    return AppOrder(
      id: json['id']?.toString() ?? '',
      product: displayProduct,
      items: itemsList,
      qty:
          (json['qty'] as num?)?.toInt() ??
          (itemsList.isNotEmpty
              ? itemsList.fold<int>(0, (s, e) => s + e.qty)
              : 1),
      subtotal: (json['subtotal'] as num?)?.toInt() ?? 0,
      deliveryFee: (json['delivery_fee'] as num?)?.toInt() ?? 0,
      total: (json['total'] as num?)?.toInt() ?? 0,
      deliveryMethod: json['delivery_method'] as String? ?? 'pickup',
      paymentMethod: json['payment_method'] as String? ?? 'BCA',
      location: json['location'] as String? ?? '',
      date: json['date'] as String? ?? '',
      status: json['status'] as String? ?? 'active',
    );
  }
}
