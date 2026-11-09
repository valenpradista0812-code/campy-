
import 'package:flutter/material.dart';

class Product {
  final String name;
  final String sub;
  final int price;
  final String? asset;
  final IconData icon;
  final String description;
  final int stock;

  const Product({
    required this.name,
    required this.sub,
    required this.price,
    this.asset,
    required this.icon,
    this.description = 'No description available.',
    this.stock = 0,
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

// ─── Product catalogue ────────────────────────────────────────────────────────

const Product _campingTent = Product(
  name: 'Camping Tent',
  sub: '2 Person Tent',
  price: 150000,
  icon: Icons.cabin,
  stock: 8,
  description:
      'Lightweight dome tent for two people. Waterproof flysheet, double '
      'layer ventilation and a quick-pitch frame that sets up in minutes. '
      'Comes with pegs, guy ropes and a carry bag.',
);

const Product _familyTent = Product(
  name: 'Family Tent',
  sub: '4 Person Tent',
  price: 250000,
  icon: Icons.house,
  stock: 5,
  description:
      'Spacious tent for up to four people with a separate sleeping area and '
      'a covered vestibule for your gear. Tall ceiling, mesh windows and a '
      'sturdy fibreglass frame for stable camping.',
);

const Product _sleepingBag = Product(
  name: 'Sleeping Bag',
  sub: 'Outdoor Sleeping',
  price: 75000,
  icon: Icons.bed,
  stock: 12,
  description:
      'Warm and soft mummy-style sleeping bag suitable for mountain and '
      'lowland camping. Zipper on both sides, hooded design and compact '
      'enough to fit in a backpack.',
);

const Product _portableStove = Product(
  name: 'Portable Stove',
  sub: 'Camping Stove',
  price: 50000,
  icon: Icons.local_fire_department,
  stock: 10,
  description:
      'Compact single-burner gas stove with adjustable flame and a stable '
      'folding stand. Perfect for boiling water and quick trail meals. '
      'Gas canister not included.',
);

const Product _cookingSet = Product(
  name: 'Cooking Set',
  sub: 'Outdoor Cooking',
  price: 65000,
  icon: Icons.soup_kitchen,
  stock: 7,
  description:
      'Nesting cookware set with two pots, a pan, a lid and utensils. '
      'Made from lightweight aluminium with heat-resistant handles, and '
      'packs together into a single carry pouch.',
);

const Product _campingLantern = Product(
  name: 'Camping Lantern',
  sub: 'LED Lantern',
  price: 35000,
  icon: Icons.lightbulb,
  stock: 15,
  description:
      'Bright rechargeable LED lantern with three brightness modes. Hangs '
      'from the tent ceiling or stands on a table, and lasts up to 12 hours '
      'on a full charge.',
);

const Product _flashlight = Product(
  name: 'Flashlight',
  sub: 'Portable Light',
  price: 20000,
  icon: Icons.flashlight_on,
  stock: 20,
  description:
      'Pocket-sized, water-resistant flashlight with a focused beam for '
      'night walks and trail use. Durable aluminium body with a wrist strap.',
);

const Product _hikingBackpack = Product(
  name: 'Hiking Backpack',
  sub: 'Outdoor Backpack',
  price: 80000,
  icon: Icons.backpack,
  stock: 6,
  description:
      'Comfortable 40L hiking backpack with padded shoulder straps, chest '
      'and hip belts, a rain cover and multiple compartments to keep your '
      'gear organised.',
);

const Product _hikingJacket = Product(
  name: 'Hiking Jacket',
  sub: 'Outdoor Apparel',
  price: 60000,
  icon: Icons.checkroom,
  stock: 9,
  description:
      'Windproof and water-repellent jacket that stays light and breathable '
      'on the trail. Adjustable hood and cuffs, with zipped pockets for '
      'small essentials.',
);

// Special Offers
const List<Product> specialOffers = [_campingTent, _sleepingBag];

// Shelter & Sleeping
const List<Product> shelterItems = [_campingTent, _familyTent, _sleepingBag];

// Camp Kitchen & Cooking
const List<Product> kitchenItems = [_portableStove, _cookingSet];

// Lighting & Power
const List<Product> lightingItems = [_campingLantern, _flashlight];

// Apparel & Personal Gear
const List<Product> apparelItems = [_hikingBackpack, _hikingJacket];

/// Number of units of [product] currently in the cart.
int cartQtyOf(Product product) {
  final idx =
      cartNotifier.value.indexWhere((e) => e.product.name == product.name);
  return idx >= 0 ? cartNotifier.value[idx].qty : 0;
}

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
