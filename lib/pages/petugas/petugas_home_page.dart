import 'package:flutter/material.dart';
import '../../data.dart';
import '../../services/api_service.dart';
import '../../staff_data.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/staff_widgets.dart';
import 'petugas_add_item_page.dart';
import 'petugas_edit_item_page.dart';

class PetugasHomePage extends StatefulWidget {
  const PetugasHomePage({super.key});

  @override
  State<PetugasHomePage> createState() => _PetugasHomePageState();
}

class _PetugasHomePageState extends State<PetugasHomePage> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _refreshStock();
  }

  Future<void> _refreshStock() async {
    setState(() => _isLoading = true);
    try {
      final list = await ApiService.getStock();
      if (mounted) {
        stockNotifier.value = list;
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _openEdit(BuildContext context, StockItem item) async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => PetugasEditItemPage(item: item)));
    _refreshStock();
  }

  void _openAdd(BuildContext context) async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const PetugasAddItemPage()));
    _refreshStock();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 12),
        const CampyLogo(color: AppColors.primary, size: 30),
        const SizedBox(height: 8),
        Text(
          'Halo, ${ApiService.currentUserName ?? 'Petugas'}',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 2),
        const Text(
          'Panel Pengelolaan Stok & Inventaris',
          style: TextStyle(fontSize: 11, color: AppColors.muted),
        ),
        const SizedBox(height: 14),

        // Header baris daftar barang & tombol tambah
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Daftar Inventaris Barang',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
              ),
              InkWell(
                onTap: () => _openAdd(context),
                borderRadius: BorderRadius.circular(6),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.add_circle, size: 16, color: AppColors.primary),
                      SizedBox(width: 4),
                      Text(
                        'Tambah Barang',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // Konten Grid / List Inventaris
        Expanded(
          child: RefreshIndicator(
            onRefresh: _refreshStock,
            child: ValueListenableBuilder<List<StockItem>>(
              valueListenable: stockNotifier,
              builder: (context, items, _) {
                if (items.isEmpty && _isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (items.isEmpty) {
                  if (ApiService.lastError != null) {
                    return ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.5,
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.warning_amber_rounded,
                                    size: 40,
                                    color: Colors.amber,
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    'Gagal memuat stok: ${ApiService.lastError}',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.red,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  ElevatedButton.icon(
                                    onPressed: _refreshStock,
                                    icon: const Icon(Icons.refresh, size: 16),
                                    label: const Text('Coba Lagi'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }

                  return ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.5,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.inventory_2_outlined,
                                size: 48,
                                color: AppColors.muted,
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                'Belum ada barang di inventaris.',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textDark,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Ketuk tombol di bawah untuk menambah barang baru.',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.muted,
                                ),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                ),
                                onPressed: () => _openAdd(context),
                                icon: const Icon(Icons.add, size: 16),
                                label: const Text('Tambah Barang Sekarang'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                }

                return GridView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
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
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.border),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x0A000000),
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: AppColors.imageBg,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: StockImage(item: item, size: 68),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              item.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textDark,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${item.qty} Stok',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.muted,
                                  ),
                                ),
                                const Icon(
                                  Icons.edit_outlined,
                                  size: 14,
                                  color: AppColors.primary,
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              rupiah(item.price),
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primaryDark,
                              ),
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
        ),
      ],
    );
  }
}
