import 'dart:typed_data';
import 'package:flutter/material.dart';

// ─── Akun login (dummy, belum terhubung ke backend) ──────────────────────────
// Ganti dengan API / Firebase Auth kalau backend sudah ada.

const String kAdminName = 'Valen';
const String kAdminEmail = 'admin@gmail.com';
const String kAdminPassword = 'admin123';

const String kPetugasName = 'Petugas';
const String kPetugasEmail = 'petugas@gmail.com';
const String kPetugasPassword = 'petugas123';

bool _sameEmail(String a, String b) => a.trim().toLowerCase() == b;

bool verifyAdmin(String email, String password) =>
    _sameEmail(email, kAdminEmail) && password == kAdminPassword;

bool verifyPetugas(String email, String password) =>
    _sameEmail(email, kPetugasEmail) && password == kPetugasPassword;

// ─── Admin list ──────────────────────────────────────────────────────────────

class AdminUser {
  final int id;
  final String username;
  final String email;
  final String detail;
  final String location;

  const AdminUser({
    required this.id,
    required this.username,
    required this.email,
    this.detail = '',
    this.location = '',
  });

  AdminUser copyWith({
    String? username,
    String? email,
    String? detail,
    String? location,
  }) {
    return AdminUser(
      id: id,
      username: username ?? this.username,
      email: email ?? this.email,
      detail: detail ?? this.detail,
      location: location ?? this.location,
    );
  }
}

int _nextAdminId = 6;
int nextAdminId() => _nextAdminId++;

final ValueNotifier<List<AdminUser>> adminsNotifier =
    ValueNotifier<List<AdminUser>>([
  const AdminUser(
    id: 1,
    username: 'Bagus Sawiryo',
    email: 'bagus@gmail.com',
    detail: 'Programmer magang yang telah memiliki pengalaman pekerjaan '
        'selama 1000 tahun.',
    location: 'Surabaya',
  ),
  const AdminUser(
    id: 2,
    username: 'Valen Pradista',
    email: 'valenpradista@gmail.com',
    detail: 'Pengelola utama panel Campy.',
    location: 'Malang',
  ),
  const AdminUser(
    id: 3,
    username: 'Rina Kusuma',
    email: 'rina@gmail.com',
    detail: 'Mengelola data petugas dan inventaris.',
    location: 'Sidoarjo',
  ),
  const AdminUser(
    id: 4,
    username: 'Dimas Aditya',
    email: 'dimas@gmail.com',
    detail: 'Admin layanan pelanggan.',
    location: 'Gresik',
  ),
  const AdminUser(
    id: 5,
    username: 'Sari Wulandari',
    email: 'sari@gmail.com',
    detail: 'Admin pembayaran dan transaksi.',
    location: 'Mojokerto',
  ),
]);

// ─── Stok barang (dikelola petugas) ──────────────────────────────────────────

class StockItem {
  final int id;
  final String name;
  final int qty;
  final int price;
  final IconData icon;
  final Uint8List? imageBytes;

  const StockItem({
    required this.id,
    required this.name,
    required this.qty,
    required this.price,
    this.icon = Icons.inventory_2,
    this.imageBytes,
  });

  StockItem copyWith({String? name, int? qty, int? price}) {
    return StockItem(
      id: id,
      name: name ?? this.name,
      qty: qty ?? this.qty,
      price: price ?? this.price,
      icon: icon,
      imageBytes: imageBytes,
    );
  }
}

int _nextStockId = 5;
int nextStockId() => _nextStockId++;

final ValueNotifier<List<StockItem>> stockNotifier =
    ValueNotifier<List<StockItem>>([
  const StockItem(
      id: 1, name: 'Tenda', qty: 24, price: 150000, icon: Icons.cabin),
  const StockItem(
      id: 2, name: 'Sleeping Bag', qty: 21, price: 75000, icon: Icons.bed),
  const StockItem(
      id: 3, name: 'Trekking Pole', qty: 10, price: 45000, icon: Icons.hiking),
  const StockItem(
      id: 4, name: 'Hammock', qty: 7, price: 90000, icon: Icons.bedtime),
]);
