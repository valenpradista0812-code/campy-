
import 'package:flutter/material.dart';

class Product {
  final String name;
  final String sub;
  final int price;
  final String? asset;
  final IconData icon;

  const Product({
    required this.name,
    required this.sub,
    required this.price,
    this.asset,
    required this.icon,
  });
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
  return 'Rp ${value.toString().replaceAllMapped(
    RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
    (match) => '${match[1]}.',
  )}';
}

// Special Offers
const List<Product> specialOffers = [
  Product(
    name: 'Camping Tent',
    sub: '2 Person Tent',
    price: 150000,
    icon: Icons.cabin,
  ),
  Product(
    name: 'Sleeping Bag',
    sub: 'Outdoor Sleeping',
    price: 75000,
    icon: Icons.bed,
  ),
];

// Shelter & Sleeping
const List<Product> shelterItems = [
  Product(
    name: 'Camping Tent',
    sub: '2 Person Tent',
    price: 150000,
    icon: Icons.cabin,
  ),
  Product(
    name: 'Family Tent',
    sub: '4 Person Tent',
    price: 250000,
    icon: Icons.house,
  ),
  Product(
    name: 'Sleeping Bag',
    sub: 'Outdoor Sleeping',
    price: 75000,
    icon: Icons.bed,
  ),
];

// Camp Kitchen & Cooking
const List<Product> kitchenItems = [
  Product(
    name: 'Portable Stove',
    sub: 'Camping Stove',
    price: 50000,
    icon: Icons.local_fire_department,
  ),
  Product(
    name: 'Cooking Set',
    sub: 'Outdoor Cooking',
    price: 65000,
    icon: Icons.soup_kitchen,
  ),
];

// Lighting & Power
const List<Product> lightingItems = [
  Product(
    name: 'Camping Lantern',
    sub: 'LED Lantern',
    price: 35000,
    icon: Icons.lightbulb,
  ),
  Product(
    name: 'Flashlight',
    sub: 'Portable Light',
    price: 20000,
    icon: Icons.flashlight_on,
  ),
];

// Apparel & Personal Gear
const List<Product> apparelItems = [
  Product(
    name: 'Hiking Backpack',
    sub: 'Outdoor Backpack',
    price: 80000,
    icon: Icons.backpack,
  ),
  Product(
    name: 'Hiking Jacket',
    sub: 'Outdoor Apparel',
    price: 60000,
    icon: Icons.checkroom,
  ),
];

List<Product> get allProducts {
  final map = <String, Product>{};
  for (final p in [
    ...specialOffers,
    ...shelterItems,
    ...kitchenItems,
    ...lightingItems,
    ...apparelItems,
  ]) {
    map[p.name] = p;
  }
  return map.values.toList();
}

final ValueNotifier<List<Product>> wishlistNotifier =
    ValueNotifier<List<Product>>([
  shelterItems[1],
  lightingItems[0],
]);

// ─── Transaction & Order models ───────────────────────────────────────────────

class AppTransaction {
  final String orderId;
  final int amount;
  final String date;
  final String status; // 'success' | 'failed'
  final String paymentMethod;

  const AppTransaction({
    required this.orderId,
    required this.amount,
    required this.date,
    required this.status,
    required this.paymentMethod,
  });
}

class AppOrder {
  final String id;
  final Product product;
  final int qty;
  final String date;
  final String status; // 'active' | 'completed'

  const AppOrder({
    required this.id,
    required this.product,
    required this.qty,
    required this.date,
    required this.status,
  });
}

const List<AppTransaction> sampleTransactions = [
  AppTransaction(
    orderId: '#ORD-20241014',
    amount: 350000,
    date: '14/10/2024',
    status: 'success',
    paymentMethod: 'BCA',
  ),
  AppTransaction(
    orderId: '#ORD-20240930',
    amount: 250000,
    date: '30/09/2024',
    status: 'success',
    paymentMethod: 'DANA',
  ),
  AppTransaction(
    orderId: '#ORD-20240915',
    amount: 150000,
    date: '15/09/2024',
    status: 'failed',
    paymentMethod: 'GoPay',
  ),
];

final List<AppOrder> sampleOrders = [
  AppOrder(
    id: '#ORD-20241014',
    product: shelterItems[0],
    qty: 1,
    date: '14/10/2024 – 16/10/2024',
    status: 'active',
  ),
  AppOrder(
    id: '#ORD-20240930',
    product: kitchenItems[0],
    qty: 2,
    date: '30/09/2024 – 01/10/2024',
    status: 'completed',
  ),
  AppOrder(
    id: '#ORD-20240915',
    product: shelterItems[2],
    qty: 1,
    date: '15/09/2024 – 17/09/2024',
    status: 'completed',
  ),
];
