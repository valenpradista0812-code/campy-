import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../../staff_data.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/staff_widgets.dart';

/// Add Item: unggah gambar, nama, jumlah, dan harga barang baru.
class PetugasAddItemPage extends StatefulWidget {
  const PetugasAddItemPage({super.key});

  @override
  State<PetugasAddItemPage> createState() => _PetugasAddItemPageState();
}

class _PetugasAddItemPageState extends State<PetugasAddItemPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameC = TextEditingController();
  final _qtyC = TextEditingController();
  final _priceC = TextEditingController();
  Uint8List? _imageBytes;

  @override
  void dispose() {
    _nameC.dispose();
    _qtyC.dispose();
    _priceC.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final file = await ImagePicker()
          .pickImage(source: ImageSource.gallery, maxWidth: 1024);
      if (file == null) return;
      final bytes = await file.readAsBytes();
      if (!mounted) return;
      setState(() => _imageBytes = bytes);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal memilih gambar')),
      );
    }
  }

  void _add() {
    if (!_formKey.currentState!.validate()) return;
    stockNotifier.value = [
      ...stockNotifier.value,
      StockItem(
        id: nextStockId(),
        name: _nameC.text.trim(),
        qty: int.parse(_qtyC.text),
        price: int.parse(_priceC.text),
        imageBytes: _imageBytes,
      ),
    ];
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Item added')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: staffFormAppBar(context, 'Add Item'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Product image',
                  style: TextStyle(fontSize: 12, color: AppColors.textGrey)),
              const SizedBox(height: 6),
              InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: _pickImage,
                child: CustomPaint(
                  painter: const _DashedBorderPainter(AppColors.primary),
                  child: Container(
                    width: double.infinity,
                    height: 150,
                    decoration: BoxDecoration(
                      color: AppColors.imageBg,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: _imageBytes != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.memory(_imageBytes!,
                                fit: BoxFit.contain),
                          )
                        : const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_photo_alternate_outlined,
                                  size: 32, color: AppColors.textGrey),
                              SizedBox(height: 8),
                              Text('Drop your images here or',
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: AppColors.textGrey)),
                              SizedBox(height: 2),
                              Text('Select click to browse',
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFF3B82F6),
                                      fontWeight: FontWeight.w600)),
                            ],
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: 'Product name',
                hint: 'Add product name',
                controller: _nameC,
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Nama produk wajib diisi'
                    : null,
              ),
              const SizedBox(height: 14),
              AppTextField(
                label: 'Product quantity',
                hint: 'Add quantity amount',
                controller: _qtyC,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (v) =>
                    int.tryParse(v ?? '') == null ? 'Jumlah wajib diisi' : null,
              ),
              const SizedBox(height: 14),
              AppTextField(
                label: 'Product price',
                hint: 'Add product price',
                controller: _priceC,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (v) =>
                    int.tryParse(v ?? '') == null ? 'Harga wajib diisi' : null,
              ),
              const SizedBox(height: 28),
              Center(
                child: SizedBox(
                  width: 190,
                  child: PrimaryButton(text: 'Add', onPressed: _add),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  final Color color;
  const _DashedBorderPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(
          Offset.zero & size, const Radius.circular(10)));
    for (final metric in path.computeMetrics()) {
      double d = 0;
      while (d < metric.length) {
        canvas.drawPath(metric.extractPath(d, d + 6), paint);
        d += 10;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter old) => old.color != color;
}
