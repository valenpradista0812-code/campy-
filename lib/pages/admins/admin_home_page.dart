import 'package:flutter/material.dart';
import '../../data.dart';
import '../../services/api_service.dart';
import '../../staff_data.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/staff_widgets.dart';
import '../petugas/petugas_add_item_page.dart';
import '../petugas/petugas_edit_item_page.dart';
import 'admin_add_page.dart';
import 'admin_edit_page.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  String _query = '';
  String _activeTab = 'admin'; // 'admin', 'petugas', or 'barang'
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  Future<void> _refreshData() async {
    setState(() => _isLoading = true);
    try {
      if (_activeTab == 'admin') {
        final list = await ApiService.getAdmins();
        if (mounted) adminsNotifier.value = list;
      } else if (_activeTab == 'petugas') {
        final list = await ApiService.getPetugasList();
        if (mounted) petugasNotifier.value = list;
      } else {
        final list = await ApiService.getStock();
        if (mounted) stockNotifier.value = list;
        final prods = await ApiService.getProducts();
        if (mounted) productsNotifier.value = prods;
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _confirmDelete(AdminUser staff) async {
    final isPetugas = staff.role == 'petugas';
    final roleName = isPetugas ? 'Petugas' : 'Admin';

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'Hapus $roleName?',
          style: const TextStyle(fontSize: 15),
        ),
        content: Text(
          '${staff.username} akan dihapus dari daftar $roleName.',
          style: const TextStyle(fontSize: 12),
        ),
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

    final success = isPetugas
        ? await ApiService.deletePetugas(staff.id)
        : await ApiService.deleteAdmin(staff.id);

    if (!mounted) return;

    if (success) {
      if (isPetugas) {
        petugasNotifier.value =
            petugasNotifier.value.where((p) => p.id != staff.id).toList();
      } else {
        adminsNotifier.value =
            adminsNotifier.value.where((a) => a.id != staff.id).toList();
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$roleName berhasil dihapus')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            ApiService.lastError ?? 'Gagal menghapus $roleName dari server',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _confirmDeleteStock(StockItem item) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus barang?'),
        content: Text('Hapus "${item.name}" dari inventaris barang?'),
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

    final success = await ApiService.deleteStock(item.id);
    if (!mounted) return;

    if (success) {
      _refreshData();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Barang berhasil dihapus')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ApiService.lastError ?? 'Gagal menghapus barang'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _getSearchHint() {
    if (_activeTab == 'admin') return 'Search Admin';
    if (_activeTab == 'petugas') return 'Search Petugas';
    return 'Search Barang / Alat Camping';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 12),
        const CampyLogo(color: AppColors.primary, size: 30),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SearchField(
            hint: _getSearchHint(),
            onChanged: (v) => setState(() => _query = v.trim().toLowerCase()),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Howdy, ${ApiService.currentUserName ?? 'Admin'}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: ApiService.isSuperAdmin
                    ? const Color(0xFFD4AF37)
                    : AppColors.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (ApiService.isSuperAdmin) ...[
                    const Icon(Icons.stars, color: Colors.white, size: 12),
                    const SizedBox(width: 4),
                  ],
                  Text(
                    ApiService.isSuperAdmin ? 'Super Admin' : 'Admin',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        const Text(
          'Welcome Back To Your Panel',
          style: TextStyle(fontSize: 10, color: AppColors.textDark),
        ),
        const SizedBox(height: 14),

        // ── Tab filter: Admin vs Petugas vs Barang ───────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              _buildTabButton('admin', 'Admin'),
              const SizedBox(width: 8),
              _buildTabButton('petugas', 'Petugas'),
              const SizedBox(width: 8),
              _buildTabButton('barang', 'Barang (Alat)'),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // ── List Header with Add button ──────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _getHeaderTitle(),
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
              ),
              InkWell(
                onTap: () async {
                  if (_activeTab == 'barang') {
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const PetugasAddItemPage(),
                      ),
                    );
                  } else {
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => AdminAddPage(initialRole: _activeTab),
                      ),
                    );
                  }
                  _refreshData();
                },
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Row(
                    children: [
                      const Icon(Icons.add_circle_outline, size: 16, color: AppColors.primary),
                      const SizedBox(width: 4),
                      Text(
                        _getAddButtonText(),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
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

        // ── Content View (Staff List or Barang Grid) ─────────────────────────
        Expanded(
          child: RefreshIndicator(
            onRefresh: _refreshData,
            child: _activeTab == 'barang'
                ? _buildBarangView()
                : _buildStaffView(),
          ),
        ),
      ],
    );
  }

  Widget _buildTabButton(String tabKey, String label) {
    final isSelected = _activeTab == tabKey;
    return Expanded(
      child: InkWell(
        onTap: () {
          if (_activeTab != tabKey) {
            setState(() => _activeTab = tabKey);
            _refreshData();
          }
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : AppColors.fieldBg,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.border,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: isSelected ? Colors.white : AppColors.textDark,
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _getHeaderTitle() {
    if (_activeTab == 'admin') return 'Daftar Admin';
    if (_activeTab == 'petugas') return 'Daftar Petugas';
    return 'Daftar Inventaris Barang';
  }

  String _getAddButtonText() {
    if (_activeTab == 'admin') return 'Tambah Admin';
    if (_activeTab == 'petugas') return 'Tambah Petugas';
    return 'Tambah Barang';
  }

  // ── Barang / Alat View (Admin can view and manage inventory) ───────────────
  Widget _buildBarangView() {
    return ValueListenableBuilder<List<StockItem>>(
      valueListenable: stockNotifier,
      builder: (context, items, _) {
        final filtered = items
            .where(
              (item) =>
                  _query.isEmpty ||
                  item.name.toLowerCase().contains(_query) ||
                  item.category.toLowerCase().contains(_query) ||
                  item.sub.toLowerCase().contains(_query),
            )
            .toList();

        if (filtered.isEmpty && _isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (filtered.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.inventory_2_outlined, size: 48, color: AppColors.muted),
                const SizedBox(height: 10),
                const Text(
                  'Belum ada barang di inventaris.',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textDark),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Ketuk "Tambah Barang" untuk menambahkan alat baru.',
                  style: TextStyle(fontSize: 11, color: AppColors.muted),
                ),
              ],
            ),
          );
        }

        return GridView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
          itemCount: filtered.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.80,
          ),
          itemBuilder: (_, i) {
            final item = filtered[i];
            return Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x08000000),
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
                        child: StockImage(item: item, size: 60),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                  Text(
                    item.category,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 8,
                      color: AppColors.muted,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        rupiah(item.price),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryDark,
                        ),
                      ),
                      Text(
                        '${item.qty} Stok',
                        style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: AppColors.muted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      InkWell(
                        onTap: () async {
                          await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => PetugasEditItemPage(item: item),
                            ),
                          );
                          _refreshData();
                        },
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                          child: Icon(Icons.edit_outlined, size: 16, color: AppColors.primary),
                        ),
                      ),
                      const SizedBox(width: 6),
                      InkWell(
                        onTap: () => _confirmDeleteStock(item),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                          child: Icon(Icons.delete_outline, size: 16, color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ── Staff View (Admin / Petugas list) ──────────────────────────────────────
  Widget _buildStaffView() {
    final activeNotifier =
        _activeTab == 'admin' ? adminsNotifier : petugasNotifier;

    return ValueListenableBuilder<List<AdminUser>>(
      valueListenable: activeNotifier,
      builder: (context, all, _) {
        final filtered = all
            .where(
              (item) =>
                  _query.isEmpty ||
                  item.username.toLowerCase().contains(_query) ||
                  item.email.toLowerCase().contains(_query),
            )
            .toList();

        if (filtered.isEmpty && _isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (filtered.isEmpty) {
          if (ApiService.lastError != null) {
            return Center(
              child: Text(
                'Gagal memuat: ${ApiService.lastError}',
                style: const TextStyle(fontSize: 11, color: Colors.red),
              ),
            );
          }
          return Center(
            child: Text(
              _activeTab == 'admin'
                  ? 'Belum ada data admin'
                  : 'Belum ada data petugas',
              style: const TextStyle(fontSize: 12, color: AppColors.muted),
            ),
          );
        }

        return ListView.separated(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
          itemCount: filtered.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (_, i) {
            final item = filtered[i];
            return Container(
              height: 52,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: kStaffTile,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                item.username,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (item.role == 'super_admin') ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 1.5,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFD4AF37),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'SUPER',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 8.5,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        Text(
                          item.email,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 10,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: () async {
                      await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => AdminEditPage(admin: item),
                        ),
                      );
                      _refreshData();
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(6),
                      child: Icon(
                        Icons.settings,
                        size: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  InkWell(
                    onTap: () => _confirmDelete(item),
                    child: const Padding(
                      padding: EdgeInsets.all(6),
                      child: Icon(
                        Icons.delete_outline,
                        size: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
