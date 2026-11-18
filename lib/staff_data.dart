import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'data.dart';

// ─── Admin User Model ────────────────────────────────────────────────────────

class AdminUser {
  final dynamic id;
  final String username;
  final String email;
  final String detail;
  final String location;
  final String role;

  const AdminUser({
    required this.id,
    required this.username,
    required this.email,
    this.detail = '',
    this.location = '',
    this.role = 'admin',
  });

  factory AdminUser.fromJson(Map<String, dynamic> json) {
    return AdminUser(
      id: json['id'] ?? '',
      username:
          json['username'] as String? ??
          json['name'] as String? ??
          json['full_name'] as String? ??
          '',
      email: json['email'] as String? ?? '',
      detail: json['detail'] as String? ?? '',
      location: json['location'] as String? ?? '',
      role: json['role'] as String? ?? 'admin',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'username': username,
    'email': email,
    'detail': detail,
    'location': location,
    'role': role,
  };

  AdminUser copyWith({
    dynamic id,
    String? username,
    String? email,
    String? detail,
    String? location,
    String? role,
  }) {
    return AdminUser(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      detail: detail ?? this.detail,
      location: location ?? this.location,
      role: role ?? this.role,
    );
  }
}

final ValueNotifier<List<AdminUser>> adminsNotifier =
    ValueNotifier<List<AdminUser>>([]);

final ValueNotifier<List<AdminUser>> petugasNotifier =
    ValueNotifier<List<AdminUser>>([]);

// ─── Stock Item Model (Petugas Inventory) ────────────────────────────────────

class StockItem {
  final dynamic id;
  final String name;
  final int qty;
  final int price;
  final IconData icon;
  final String iconName;
  final String? imageUrl;
  final Uint8List? imageBytes;
  final String sub;
  final String category;
  final String categorySlug;
  final bool isSpecialOffer;
  final String description;

  const StockItem({
    required this.id,
    required this.name,
    required this.qty,
    required this.price,
    this.icon = Icons.inventory_2,
    this.iconName = 'inventory_2',
    this.imageUrl,
    this.imageBytes,
    this.sub = '',
    this.category = 'Shelter & Sleeping',
    this.categorySlug = 'shelter',
    this.isSpecialOffer = false,
    this.description = '',
  });

  factory StockItem.fromJson(Map<String, dynamic> json) {
    final iconStr = json['icon'] as String? ?? 'inventory_2';
    return StockItem(
      id: json['id'] ?? '',
      name: json['name'] as String? ?? '',
      qty:
          (json['qty'] as num?)?.toInt() ??
          (json['stock'] as num?)?.toInt() ??
          0,
      price: (json['price'] as num?)?.toInt() ?? 0,
      icon: iconFromName(iconStr),
      iconName: iconStr,
      imageUrl: json['image_url'] as String?,
      sub: json['sub'] as String? ?? '',
      category: json['category'] as String? ?? 'Shelter & Sleeping',
      categorySlug: json['category_slug'] as String? ?? 'shelter',
      isSpecialOffer: json['is_special_offer'] == true,
      description: json['description'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'qty': qty,
    'price': price,
    'icon': iconName,
    'image_url': imageUrl,
    'sub': sub,
    'category': category,
    'category_slug': categorySlug,
    'is_special_offer': isSpecialOffer,
    'description': description,
  };

  StockItem copyWith({
    dynamic id,
    String? name,
    int? qty,
    int? price,
    IconData? icon,
    String? iconName,
    String? imageUrl,
    Uint8List? imageBytes,
    String? sub,
    String? category,
    String? categorySlug,
    bool? isSpecialOffer,
    String? description,
  }) {
    return StockItem(
      id: id ?? this.id,
      name: name ?? this.name,
      qty: qty ?? this.qty,
      price: price ?? this.price,
      icon: icon ?? this.icon,
      iconName: iconName ?? this.iconName,
      imageUrl: imageUrl ?? this.imageUrl,
      imageBytes: imageBytes ?? this.imageBytes,
      sub: sub ?? this.sub,
      category: category ?? this.category,
      categorySlug: categorySlug ?? this.categorySlug,
      isSpecialOffer: isSpecialOffer ?? this.isSpecialOffer,
      description: description ?? this.description,
    );
  }
}

final ValueNotifier<List<StockItem>> stockNotifier =
    ValueNotifier<List<StockItem>>([]);
