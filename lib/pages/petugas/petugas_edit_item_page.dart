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

/// Halaman Edit Item Petugas:
/// Mengubah nama, jumlah stok, harga barang, kategori, dan foto produk.
class PetugasEditItemPage extends StatefulWidget {
  final StockItem item;
  const PetugasEditItemPage({super.key, required this.item});

  @override
  State<PetugasEditItemPage> createState() => _PetugasEditItemPageState();
}

class _PetugasEditItemPageState extends State<PetugasEditItemPage> {
  final _formKey = GlobalKey<FormState>();
  late final _nameC = TextEditingController(text: widget.item.name);
  late final _subC = TextEditingController(text: widget.item.sub);
  late final _qtyC = TextEditingController(text: '${widget.item.qty}');
  late final _priceC = TextEditingController(text: '${widget.item.price}');
  late final _descC = TextEditingController(text: widget.item.description);
  late final _imageUrlC =
      TextEditingController(text: widget.item.imageUrl ?? '');

  Uint8List? _newImageBytes;
  String? _newImageFilename;
  bool _isLoading = false;
  late bool _isSpecialOffer = widget.item.isSpecialOffer;

  // Kategori dipilih dari item yang ada
  late String _selectedCategory = widget.item.category;
  late String _selectedSlug = widget.item.categorySlug;

  @override
  void initState() {
    super.initState();
    _imageUrlC.addListener(() {
      setState(() {});
    });
    // Pastikan slug valid, jika tidak default ke shelter
    final validSlugs = _categories.map((c) => c['slug'] as String).toSet();
    if (!validSlugs.contains(_selectedSlug)) {
      _selectedSlug = 'shelter';
      _selectedCategory = 'Shelter & Sleeping';
    }
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
        _newImageBytes = bytes;
        _newImageFilename = file.name;
        _imageUrlC.clear();
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memilih gambar: $e'),
          backgroundColor: Colors.red.shade700,
        ),
      );
    }
  }

  void _clearImage() {
    setState(() {
      _newImageBytes = null;
      _newImageFilename = null;
      _imageUrlC.clear();
    });
  }

  void _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      String? finalImageUrl = widget.item.imageUrl;

      // 1. Jika petugas memilih gambar baru dari galeri
      if (_newImageBytes != null) {
        try {
          final uploadedUrl = await ApiService.uploadImage(
            _newImageBytes!,
            _newImageFilename ??
                'stock_${DateTime.now().millisecondsSinceEpoch}.jpg',
          );
          if (uploadedUrl != null && uploadedUrl.isNotEmpty) {
            finalImageUrl = uploadedUrl;
          } else {
            finalImageUrl =
                'data:image/jpeg;base64,${base64Encode(_newImageBytes!)}';
          }
        } catch (_) {
          finalImageUrl =
              'data:image/jpeg;base64,${base64Encode(_newImageBytes!)}';
        }
      } else if (_imageUrlC.text.trim().isNotEmpty) {
        finalImageUrl = _imageUrlC.text.trim();
      }

      // 2. Kirim update ke API backend dengan kategori
      final success = await ApiService.updateStock(
        id: widget.item.id,
        name: _nameC.text.trim(),
        qty: int.parse(_qtyC.text.trim()),
        price: int.parse(_priceC.text.trim()),
        imageUrl: finalImageUrl,
        sub: _subC.text.trim(),
        category: _selectedCategory,
        categorySlug: _selectedSlug,
        isSpecialOffer: _isSpecialOffer,
        description: _descC.text.trim(),
      );

      if (!mounted) return;

      if (success) {
        // Refresh daftar stok & produk agar muncul di semua halaman
        ApiService.getStock().then((list) => stockNotifier.value = list);
        ApiService.getProducts().then((list) => productsNotifier.value = list);

        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Data barang "${_nameC.text}" berhasil diperbarui!'),
            backgroundColor: AppColors.primaryDark,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              ApiService.lastError ?? 'Gagal memperbarui stok barang di server.',
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

  Future<void> _delete() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus barang?'),
        content: Text('Hapus "${widget.item.name}" dari inventaris toko?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (ok != true) return;

    final success = await ApiService.deleteStock(widget.item.id);
    if (!mounted) return;

    if (success) {
      ApiService.getStock().then((list) => stockNotifier.value = list);
      ApiService.getProducts().then((list) => productsNotifier.value = list);
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Barang berhasil dihapus')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            ApiService.lastError ?? 'Gagal menghapus item dari server',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildImagePreview() {
    // 1. Gambar baru dari picker
    if (_newImageBytes != null) {
      return Stack(
        alignment: Alignment.topRight,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.memory(
              _newImageBytes!,
              width: double.infinity,
              height: 140,
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

    // 2. URL gambar yang diketik
    final enteredUrl = _imageUrlC.text.trim();
    if (enteredUrl.isNotEmpty) {
      final resolvedUrl = enteredUrl.startsWith('/')
          ? '${ApiService.baseUrl}$enteredUrl'
          : enteredUrl;

      return Stack(
        alignment: Alignment.topRight,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              resolvedUrl,
              width: double.infinity,
              height: 140,
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

    // 3. Fallback kosong
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        Icon(
          Icons.add_photo_alternate_outlined,
          size: 36,
          color: AppColors.primary,
        ),
        SizedBox(height: 6),
        Text(
          'Ketuk untuk mengganti foto barang',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.primaryDark,
          ),
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
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'Edit Barang Inventaris',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, size: 22),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red, size: 22),
            onPressed: _delete,
            tooltip: 'Hapus barang',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Foto Produk:',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 8),

              // Kotak Ubah/Pilih Gambar
              InkWell(
                onTap: _pickImage,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  height: 140,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.fieldBg,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: _buildImagePreview(),
                ),
              ),
              const SizedBox(height: 10),

              // Field URL Gambar
              AppTextField(
                label: 'Tautan / URL Gambar',
                hint: 'https://...',
                controller: _imageUrlC,
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: 16),

              // ── Kategori Produk ────────────────────────────────────────────
              _buildCategorySelector(),
              const SizedBox(height: 16),

              // Field Nama
              AppTextField(
                label: 'Nama Barang',
                hint: 'Contoh: Tenda Dome',
                controller: _nameC,
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Nama barang wajib diisi'
                    : null,
              ),
              const SizedBox(height: 14),

              // Field Deskripsi Singkat
              AppTextField(
                label: 'Deskripsi Singkat (opsional)',
                hint: 'Contoh: Kapasitas 4 orang, waterproof',
                controller: _subC,
              ),
              const SizedBox(height: 14),

              // Field Stok
              AppTextField(
                label: 'Jumlah Stok',
                hint: '0',
                controller: _qtyC,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Stok wajib diisi';
                  }
                  final parsed = int.tryParse(v.trim());
                  if (parsed == null || parsed < 0) {
                    return 'Stok harus berupa angka';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // Field Harga
              AppTextField(
                label: 'Harga (Rp)',
                hint: 'Rp 0',
                controller: _priceC,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Harga wajib diisi';
                  }
                  final parsed = int.tryParse(v.trim());
                  if (parsed == null || parsed < 0) {
                    return 'Harga harus berupa angka';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // Field Deskripsi Lengkap
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

              // Tombol Simpan
              PrimaryButton(
                text: 'Simpan Perubahan',
                isLoading: _isLoading,
                onPressed: _save,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
