import 'package:flutter/material.dart';
import '../../data.dart';
import '../../staff_data.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/staff_widgets.dart';
import 'petugas_edit_item_page.dart';

class PetugasHomePage extends StatelessWidget {
  const PetugasHomePage({super.key});

  void _openEdit(BuildContext context, StockItem item) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => PetugasEditItemPage(item: item)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 12),
        const CampyLogo(color: AppColors.primary, size: 30),
        const SizedBox(height: 8),
        const Text('Welcome Petugas',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        const SizedBox(height: 14),
        const Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text('Special Offer',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: ValueListenableBuilder<List<StockItem>>(
            valueListenable: stockNotifier,
            builder: (context, items, _) {
              if (items.isEmpty) {
                return const Center(
                  child: Text('No items yet. Tap Add Item to create one.',
                      style: TextStyle(fontSize: 12, color: AppColors.muted)),
                );
              }
              return GridView.builder(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                itemCount: items.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.82,
                ),
                itemBuilder: (_, i) {
                  final item = items[i];
                  return InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () => _openEdit(context, item),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Center(
                              child: StockImage(item: item, size: 64),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(item.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontSize: 11, fontWeight: FontWeight.w600)),
                          Text('${item.qty} Tersedia',
                              style: const TextStyle(
                                  fontSize: 9, color: AppColors.muted)),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: Text(rupiah(item.price),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700)),
                              ),
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: AppColors.accent,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Icon(Icons.edit,
                                    size: 13, color: Colors.white),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
