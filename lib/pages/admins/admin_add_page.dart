import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../staff_data.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/staff_widgets.dart';

/// Add New Staff (Super Admin, Admin, or Petugas).
/// Super Admin dapat menambahkan Admin lain dan Petugas dari halaman ini.
class AdminAddPage extends StatefulWidget {
  final String initialRole;
  const AdminAddPage({super.key, this.initialRole = 'admin'});

  @override
  State<AdminAddPage> createState() => _AdminAddPageState();
}

class _AdminAddPageState extends State<AdminAddPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameC = TextEditingController();
  final _emailC = TextEditingController();
  final _passwordC = TextEditingController();
  final _phoneC = TextEditingController();
  final _detailC = TextEditingController();
  final _locationC = TextEditingController();
  late String _selectedRole;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedRole = widget.initialRole;
  }

  @override
  void dispose() {
    _nameC.dispose();
    _emailC.dispose();
    _passwordC.dispose();
    _phoneC.dispose();
    _detailC.dispose();
    _locationC.dispose();
    super.dispose();
  }

  void _add() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      if (_selectedRole == 'admin' || _selectedRole == 'super_admin') {
        final roleLabel = _selectedRole == 'super_admin' ? 'Super Admin' : 'Admin';
        final newAdmin = await ApiService.createAdmin(
          username: _nameC.text.trim(),
          email: _emailC.text.trim(),
          password: _passwordC.text,
          detail: _detailC.text.trim(),
          location: _locationC.text.trim(),
          role: _selectedRole,
        );

        if (!mounted) return;

        if (newAdmin != null) {
          ApiService.getAdmins().then((list) {
            adminsNotifier.value = list;
          });

          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$roleLabel baru berhasil ditambahkan!'),
              backgroundColor: AppColors.primaryDark,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(ApiService.lastError ?? 'Gagal menambahkan $roleLabel'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        final newPetugas = await ApiService.createPetugas(
          username: _nameC.text.trim(),
          email: _emailC.text.trim(),
          password: _passwordC.text,
          phone: _phoneC.text.trim(),
          detail: _detailC.text.trim(),
          location: _locationC.text.trim(),
        );

        if (!mounted) return;

        if (newPetugas != null) {
          ApiService.getPetugasList().then((list) {
            petugasNotifier.value = list;
          });

          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Petugas baru berhasil ditambahkan!'),
              backgroundColor: AppColors.primaryDark,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(ApiService.lastError ?? 'Gagal menambahkan petugas'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final roleTitle = _selectedRole == 'super_admin'
        ? 'Super Admin'
        : _selectedRole == 'admin'
            ? 'Admin'
            : 'Petugas';

    return Scaffold(
      appBar: staffFormAppBar(context, 'Tambah Staff ($roleTitle)'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Pilih Role Akun yang Ingin Ditambahkan:',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: ChoiceChip(
                      label: const Center(child: Text('Admin')),
                      selected: _selectedRole == 'admin',
                      selectedColor: AppColors.primary,
                      labelStyle: TextStyle(
                        color: _selectedRole == 'admin'
                            ? Colors.white
                            : AppColors.textDark,
                        fontWeight: FontWeight.w600,
                      ),
                      onSelected: (val) {
                        if (val) setState(() => _selectedRole = 'admin');
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ChoiceChip(
                      label: const Center(child: Text('Petugas')),
                      selected: _selectedRole == 'petugas',
                      selectedColor: AppColors.primary,
                      labelStyle: TextStyle(
                        color: _selectedRole == 'petugas'
                            ? Colors.white
                            : AppColors.textDark,
                        fontWeight: FontWeight.w600,
                      ),
                      onSelected: (val) {
                        if (val) setState(() => _selectedRole = 'petugas');
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ChoiceChip(
                      label: const Center(child: Text('Super Admin')),
                      selected: _selectedRole == 'super_admin',
                      selectedColor: const Color(0xFFD4AF37),
                      labelStyle: TextStyle(
                        color: _selectedRole == 'super_admin'
                            ? Colors.white
                            : AppColors.textDark,
                        fontWeight: FontWeight.w600,
                      ),
                      onSelected: (val) {
                        if (val) setState(() => _selectedRole = 'super_admin');
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Penjelasan Role yang dipilih
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: _selectedRole == 'super_admin'
                      ? const Color(0xFFFFF9E6)
                      : AppColors.lightGreen,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _selectedRole == 'super_admin'
                        ? const Color(0xFFE2B734)
                        : AppColors.primary.withOpacity(0.3),
                  ),
                ),
                child: Text(
                  _selectedRole == 'super_admin'
                      ? 'Super Admin: Akses penuh dan dapat mengelola Admin lain & Petugas.'
                      : _selectedRole == 'admin'
                          ? 'Admin: Mengelola katalog produk, pesanan, dan sistem toko.'
                          : 'Petugas: Mengelola stok inventaris barang dan update status.',
                  style: TextStyle(
                    fontSize: 11,
                    color: _selectedRole == 'super_admin'
                        ? const Color(0xFF8A6500)
                        : AppColors.primaryDark,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              AppTextField(
                label: 'Nama / Username',
                hint: _selectedRole == 'petugas'
                    ? 'Nama lengkap petugas'
                    : 'Nama lengkap admin',
                controller: _nameC,
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Nama wajib diisi'
                    : null,
              ),
              const SizedBox(height: 12),
              AppTextField(
                label: 'Email',
                hint: _selectedRole == 'petugas'
                    ? 'petugas@campy.com'
                    : 'admin@campy.com',
                controller: _emailC,
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Email wajib diisi';
                  if (!v.contains('@')) return 'Email tidak valid';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              AppTextField(
                label: 'Password',
                hint: 'Minimal 6 karakter',
                controller: _passwordC,
                isPassword: true,
                validator: (v) => (v == null || v.length < 6)
                    ? 'Password minimal 6 karakter'
                    : null,
              ),
              if (_selectedRole == 'petugas') ...[
                const SizedBox(height: 12),
                AppTextField(
                  label: 'Nomor Telepon',
                  hint: '08123456789',
                  controller: _phoneC,
                  keyboardType: TextInputType.phone,
                ),
              ],
              const SizedBox(height: 12),
              AppTextField(
                label: 'Detail Tugas / Jabatan',
                hint: _selectedRole == 'petugas'
                    ? 'Pengelola stok & barang inventaris...'
                    : 'Administrator sistem & kelola toko...',
                controller: _detailC,
              ),
              const SizedBox(height: 12),
              AppTextField(
                label: 'Location / Lokasi Cabang Toko',
                hint: 'Contoh: Campy Store Jakarta',
                controller: _locationC,
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                text: 'Simpan $roleTitle',
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
