import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../staff_data.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/staff_widgets.dart';

/// Item Edits: ubah nama, jumlah, dan harga barang.
class PetugasEditItemPage extends StatefulWidget {
  final StockItem item;
  const PetugasEditItemPage({super.key, required this.item});

  @override
  State<PetugasEditItemPage> createState() => _PetugasEditItemPageState();
}

class _PetugasEditItemPageState extends State<PetugasEditItemPage> {
  final _formKey = GlobalKey<FormState>();
  late final _nameC = TextEditingController(text: widget.item.name);
  late final _qtyC = TextEditingController(text: '${widget.item.qty}');
  late final _priceC = TextEditingController(text: '${widget.item.price}');

  @override
  void dispose() {
    _nameC.dispose();
    _qtyC.dispose();
    _priceC.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final updated = widget.item.copyWith(
      name: _nameC.text.trim(),
      qty: int.parse(_qtyC.text),
      price: int.parse(_priceC.text),
    );
    stockNotifier.value = [
      for (final s in stockNotifier.value) s.id == updated.id ? updated : s,
    ];
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Item updated')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    return Scaffold(
      appBar: staffFormAppBar(context, 'Item Edits'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 96,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.imageBg,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(child: StockImage(item: item, size: 60)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primaryDark)),
                        const SizedBox(height: 2),
                        Text('${item.qty} Available',
                            style: const TextStyle(
                                fontSize: 10, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              AppTextField(
                label: 'Product Name',
                hint: 'Add product name',
                controller: _nameC,
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Nama produk wajib diisi'
                    : null,
              ),
              const SizedBox(height: 14),
              AppTextField(
                label: 'Product Quantity',
                hint: 'Add quantity amount',
                controller: _qtyC,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (v) =>
                    int.tryParse(v ?? '') == null ? 'Jumlah wajib diisi' : null,
              ),
              const SizedBox(height: 14),
              AppTextField(
                label: 'Product Price',
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
                  child: PrimaryButton(text: 'Save', onPressed: _save),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
