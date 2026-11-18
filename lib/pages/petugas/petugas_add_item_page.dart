import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../../data.dart';
import '../../services/api_service.dart';
import '../../staff_data.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/staff_widgets.dart';

/// Daftar kategori yang sesuai dengan halaman user (Explore)
const List<Map<String, dynamic>> _categories = [
  {
    'label': 'Shelter & Sleeping',
    'slug': 'shelter',
    'icon': Icons.cabin_outlined,
  },
  {
    'label': 'Camp Kitchen & Cooking',
    'slug': 'kitchen',
    'icon': Icons.soup_kitchen_outlined,
  },
  {
    'label': 'Lighting & Power',
    'slug': 'lighting',
    'icon': Icons.lightbulb_outline,
  },
  {
    'label': 'Apparel & Personal Gear',
    'slug': 'apparel',
    'icon': Icons.backpack_outlined,
  },
];

/// Halaman Add Item Petugas:
/// Menambahkan barang inventaris baru beserta foto produk dan kategori.
class PetugasAddItemPage extends StatefulWidget {
  const PetugasAddItemPage({super.key});

  @override
  State<PetugasAddItemPage> createState() => _PetugasAddItemPageState();
}

class _PetugasAddItemPageState extends State<PetugasAddItemPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameC = TextEditingController();
  final _subC = TextEditingController();
  final _qtyC = TextEditingController();
  final _priceC = TextEditingController();
  final _descC = TextEditingController();
  final _imageUrlC = TextEditingController();

  Uint8List? _imageBytes;
  String? _imageFilename;
  bool _isLoading = false;
  bool _isSpecialOffer = false;

  // Kategori default
  String _selectedCategory = 'Shelter & Sleeping';
  String _selectedSlug = 'shelter';

  @override
  void initState() {
    super.initState();
    _imageUrlC.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _nameC.dispose();
    _subC.dispose();
    _qtyC.dispose();
    _priceC.dispose();
    _descC.dispose();
    _imageUrlC.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final file = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        imageQuality: 85,
      );
      if (file == null) return;
      final bytes = await file.readAsBytes();
      if (!mounted) return;
      setState(() {
        _imageBytes = bytes;
        _imageFilename = file.name;
        _imageUrlC.clear();
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memilih gambar dari perangkat: $e'),
          backgroundColor: Colors.red.shade700,
        ),
      );
    }
  }

  void _clearImage() {
    setState(() {
      _imageBytes = null;
      _imageFilename = null;
      _imageUrlC.clear();
    });
  }

  void _add() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      String? finalImageUrl;

      // 1. Jika ada file gambar lokal yang dipilih
      if (_imageBytes != null) {
        try {
          final uploadedUrl = await ApiService.uploadImage(
            _imageBytes!,
            _imageFilename ??
                'stock_${DateTime.now().millisecondsSinceEpoch}.jpg',
          );
          if (uploadedUrl != null && uploadedUrl.isNotEmpty) {
            finalImageUrl = uploadedUrl;
          } else {
            finalImageUrl =
                'data:image/jpeg;base64,${base64Encode(_imageBytes!)}';
          }
        } catch (_) {
          finalImageUrl =
              'data:image/jpeg;base64,${base64Encode(_imageBytes!)}';
        }
      } else if (_imageUrlC.text.trim().isNotEmpty) {
        finalImageUrl = _imageUrlC.text.trim();
      }

      // 2. Simpan barang ke database via API dengan kategori
      final newItem = await ApiService.addStock(
        name: _nameC.text.trim(),
        qty: int.parse(_qtyC.text.trim()),
        price: int.parse(_priceC.text.trim()),
        imageUrl: finalImageUrl,
        sub: _subC.text.trim().isEmpty ? null : _subC.text.trim(),
        category: _selectedCategory,
        categorySlug: _selectedSlug,
        isSpecialOffer: _isSpecialOffer,
        description: _descC.text.trim().isEmpty ? null : _descC.text.trim(),
      );

      if (!mounted) return;

      if (newItem != null) {
        // Refresh daftar stok & produk agar muncul di semua halaman
        ApiService.getStock().then((list) => stockNotifier.value = list);
        ApiService.getProducts().then((list) => productsNotifier.value = list);

        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Barang "${newItem.name}" berhasil ditambahkan!'),
            backgroundColor: AppColors.primaryDark,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              ApiService.lastError ??
                  'Gagal menambahkan barang ke inventaris. Periksa koneksi backend.',
            ),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan: $e'),
          backgroundColor: Colors.red.shade700,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildImagePreview() {
    final enteredUrl = _imageUrlC.text.trim();

    if (_imageBytes != null) {
      return Stack(
        alignment: Alignment.topRight,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.memory(
              _imageBytes!,
              width: double.infinity,
              height: 150,
              fit: BoxFit.contain,
            ),
          ),
          IconButton(
            onPressed: _clearImage,
            icon: const CircleAvatar(
              radius: 14,
              backgroundColor: Colors.red,
              child: Icon(Icons.close, size: 16, color: Colors.white),
            ),
          ),
        ],
      );
    }

    if (enteredUrl.isNotEmpty) {
      return Stack(
        alignment: Alignment.topRight,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              enteredUrl,
              width: double.infinity,
              height: 150,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const Center(
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Text(
                    'URL gambar tidak dapat dimuat',
                    style: TextStyle(color: Colors.red, fontSize: 11),
                  ),
                ),
              ),
            ),
          ),
          IconButton(
            onPressed: _clearImage,
            icon: const CircleAvatar(
              radius: 14,
              backgroundColor: Colors.red,
              child: Icon(Icons.close, size: 16, color: Colors.white),
            ),
          ),
        ],
      );
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        Icon(
          Icons.add_photo_alternate_outlined,
          size: 40,
          color: AppColors.primary,
        ),
        SizedBox(height: 8),
        Text(
          'Ketuk untuk memilih foto dari galeri',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.primaryDark,
          ),
        ),
        SizedBox(height: 2),
        Text(
          'Format JPG, PNG, atau WEBP',
          style: TextStyle(fontSize: 10, color: AppColors.muted),
        ),
      ],
    );
  }

  /// Widget pemilihan kategori berbentuk choice chips
  Widget _buildCategorySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Kategori Produk',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _categories.map((cat) {
            final isSelected = _selectedSlug == cat['slug'];
            return ChoiceChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    cat['icon'] as IconData,
                    size: 16,
                    color: isSelected ? Colors.white : AppColors.primaryDark,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    cat['label'] as String,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : AppColors.textDark,
                    ),
                  ),
                ],
              ),
              selected: isSelected,
              selectedColor: AppColors.primary,
              backgroundColor: AppColors.fieldBg,
              side: BorderSide(
                color: isSelected ? AppColors.primary : AppColors.border,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              onSelected: (_) {
                setState(() {
                  _selectedCategory = cat['label'] as String;
                  _selectedSlug = cat['slug'] as String;
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: staffFormAppBar(context, 'Tambah Barang Baru'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Foto Produk (Pilih salah satu cara):',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 8),

              // ── Kotak Picker Gambar ───────────────────────────────────────
              InkWell(
                onTap: _pickImage,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.fieldBg,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: _imageBytes != null || _imageUrlC.text.isNotEmpty
                          ? AppColors.primary
                          : AppColors.border,
                      width: _imageBytes != null ? 1.5 : 1.0,
                    ),
                  ),
                  child: _buildImagePreview(),
                ),
              ),
              const SizedBox(height: 10),

              // ── Field Masukkan URL Gambar (Opsional) ──────────────────────
              AppTextField(
                label: 'Atau Masukkan Tautan / URL Gambar',
                hint: 'https://example.com/gambar-tenda.jpg',
                controller: _imageUrlC,
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: 16),

              // ── Kategori Produk ────────────────────────────────────────────
              _buildCategorySelector(),
              const SizedBox(height: 16),

              // ── Nama Barang ───────────────────────────────────────────────
              AppTextField(
                label: 'Nama Barang / Produk',
                hint: 'Contoh: Tenda Camping Dome 4P',
                controller: _nameC,
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Nama barang wajib diisi'
                    : null,
              ),
              const SizedBox(height: 14),

              // ── Deskripsi Singkat (Sub) ────────────────────────────────────
              AppTextField(
                label: 'Deskripsi Singkat (opsional)',
                hint: 'Contoh: Kapasitas 4 orang, waterproof',
                controller: _subC,
              ),
              const SizedBox(height: 14),

              // ── Jumlah Stok ───────────────────────────────────────────────
              AppTextField(
                label: 'Jumlah Stok Tersedia',
                hint: 'Contoh: 10',
                controller: _qtyC,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Jumlah stok wajib diisi';
                  }
                  final parsed = int.tryParse(v.trim());
                  if (parsed == null || parsed < 0) {
                    return 'Jumlah stok harus angka 0 atau lebih';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // ── Harga Sewa / Beli ─────────────────────────────────────────
              AppTextField(
                label: 'Harga (Rp)',
                hint: 'Contoh: 150000',
                controller: _priceC,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Harga wajib diisi';
                  }
                  final parsed = int.tryParse(v.trim());
                  if (parsed == null || parsed < 0) {
                    return 'Harga harus angka 0 atau lebih';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // ── Deskripsi Lengkap (opsional) ──────────────────────────────
              AppTextField(
                label: 'Deskripsi Lengkap (opsional)',
                hint: 'Jelaskan detail fitur, bahan, ukuran...',
                controller: _descC,
                maxLines: 3,
              ),
              const SizedBox(height: 14),

              // ── Toggle Special Offer ───────────────────────────────────────
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text(
                  'Tampilkan sebagai Special Offer',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
                subtitle: const Text(
                  'Barang akan muncul di bagian "Special Offers" halaman user',
                  style: TextStyle(fontSize: 11, color: AppColors.muted),
                ),
                value: _isSpecialOffer,
                activeColor: AppColors.primary,
                onChanged: (val) => setState(() => _isSpecialOffer = val),
              ),
              const SizedBox(height: 20),

              // ── Tombol Simpan ─────────────────────────────────────────────
              PrimaryButton(
                text: 'Simpan Barang',
                isLoading: _isLoading,
                onPressed: _add,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
