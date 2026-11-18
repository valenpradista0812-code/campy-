import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../staff_data.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/staff_widgets.dart';
import 'admin_shell.dart';

/// Halaman Register Admin — dapat diakses dari halaman login admin.
/// Admin yang sudah login juga dapat menambahkan admin/petugas baru dari sini.
class AdminRegisterPage extends StatefulWidget {
  /// Jika [requireAuth] = true, halaman ini membutuhkan admin yang sudah login
  /// (diakses dari dalam AdminShell / AdminAddPage).
  /// Jika false, halaman berdiri sendiri (self-registration).
  final bool requireAuth;

  const AdminRegisterPage({super.key, this.requireAuth = false});

  @override
  State<AdminRegisterPage> createState() => _AdminRegisterPageState();
}

class _AdminRegisterPageState extends State<AdminRegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameC = TextEditingController();
  final _emailC = TextEditingController();
  final _passwordC = TextEditingController();
  final _confirmPasswordC = TextEditingController();
  final _phoneC = TextEditingController();
  final _detailC = TextEditingController();
  final _locationC = TextEditingController();

  String _selectedRole = 'admin';
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _nameC.dispose();
    _emailC.dispose();
    _passwordC.dispose();
    _confirmPasswordC.dispose();
    _phoneC.dispose();
    _detailC.dispose();
    _locationC.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      AdminUser? result;

      if (_selectedRole == 'admin') {
        result = await ApiService.createAdmin(
          username: _nameC.text.trim(),
          email: _emailC.text.trim(),
          password: _passwordC.text,
          detail: _detailC.text.trim(),
          location: _locationC.text.trim(),
        );
      } else {
        result = await ApiService.createPetugas(
          username: _nameC.text.trim(),
          email: _emailC.text.trim(),
          password: _passwordC.text,
          phone: _phoneC.text.trim(),
          detail: _detailC.text.trim(),
          location: _locationC.text.trim(),
        );
      }

      if (!mounted) return;

      if (result != null) {
        // Refresh daftar di notifier
        if (_selectedRole == 'admin') {
          ApiService.getAdmins().then((list) => adminsNotifier.value = list);
        } else {
          ApiService.getPetugasList()
              .then((list) => petugasNotifier.value = list);
        }

        final roleName = _selectedRole == 'admin' ? 'Admin' : 'Petugas';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$roleName "${result.username}" berhasil didaftarkan!'),
            backgroundColor: AppColors.primaryDark,
          ),
        );

        if (widget.requireAuth) {
          // Kembali ke halaman sebelumnya (dari dalam panel admin)
          Navigator.of(context).pop();
        } else {
          // Self-registration: masuk ke panel admin
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const AdminShell()),
            (route) => false,
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(ApiService.lastError ?? 'Registrasi gagal. Coba lagi.'),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final roleTitle = _selectedRole == 'admin' ? 'Admin' : 'Petugas';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, size: 22),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: widget.requireAuth
            ? Text(
                'Tambah Akun $roleTitle',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              )
            : null,
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                // ── Header ───────────────────────────────────────────────────
                if (!widget.requireAuth) ...[
                  Center(
                    child: const CampyLogo(color: AppColors.primary, size: 60),
                  ),
                  const SizedBox(height: 10),
                  const Center(
                    child: Text(
                      'Daftar Akun Staff',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryDark,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Center(
                    child: Text(
                      'Buat akun admin atau petugas baru',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.muted,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                ] else ...[
                  const SizedBox(height: 8),
                ],

                // ── Pilih Role ───────────────────────────────────────────────
                const Text(
                  'Pilih Role Akun:',
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
                      child: _RoleButton(
                        label: 'Admin',
                        icon: Icons.admin_panel_settings_outlined,
                        isSelected: _selectedRole == 'admin',
                        onTap: () => setState(() => _selectedRole = 'admin'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _RoleButton(
                        label: 'Petugas',
                        icon: Icons.badge_outlined,
                        isSelected: _selectedRole == 'petugas',
                        onTap: () => setState(() => _selectedRole = 'petugas'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // ── Info role ────────────────────────────────────────────────
                _RoleInfoBanner(role: _selectedRole),
                const SizedBox(height: 20),

                // ── Form Fields ──────────────────────────────────────────────
                AppTextField(
                  label: 'Nama / Username',
                  hint: _selectedRole == 'admin'
                      ? 'Nama lengkap admin'
                      : 'Nama lengkap petugas',
                  controller: _nameC,
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Nama wajib diisi' : null,
                ),
                const SizedBox(height: 14),

                AppTextField(
                  label: 'Email',
                  hint: _selectedRole == 'admin'
                      ? 'admin@campy.com'
                      : 'petugas@campy.com',
                  controller: _emailC,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Email wajib diisi';
                    }
                    if (!v.contains('@') || !v.contains('.')) {
                      return 'Format email tidak valid';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                // Password
                _PasswordField(
                  label: 'Password',
                  hint: 'Minimal 8 karakter',
                  controller: _passwordC,
                  obscure: _obscurePassword,
                  onToggle: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Password wajib diisi';
                    if (v.length < 8) return 'Password minimal 8 karakter';
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                // Konfirmasi password
                _PasswordField(
                  label: 'Konfirmasi Password',
                  hint: 'Ulangi password',
                  controller: _confirmPasswordC,
                  obscure: _obscureConfirm,
                  onToggle: () =>
                      setState(() => _obscureConfirm = !_obscureConfirm),
                  validator: (v) {
                    if (v == null || v.isEmpty) {
                      return 'Konfirmasi password wajib diisi';
                    }
                    if (v != _passwordC.text) {
                      return 'Password tidak cocok';
                    }
                    return null;
                  },
                ),

                // Field nomor telepon (hanya untuk petugas)
                if (_selectedRole == 'petugas') ...[
                  const SizedBox(height: 14),
                  AppTextField(
                    label: 'Nomor Telepon',
                    hint: '08123456789',
                    controller: _phoneC,
                    keyboardType: TextInputType.phone,
                  ),
                ],

                const SizedBox(height: 14),
                AppTextField(
                  label: 'Detail Tugas',
                  hint: _selectedRole == 'admin'
                      ? 'Contoh: Mengelola sistem dan data pengguna'
                      : 'Contoh: Pengelola stok barang inventaris',
                  controller: _detailC,
                ),
                const SizedBox(height: 14),
                AppTextField(
                  label: 'Lokasi / Toko',
                  hint: 'Contoh: Campy HQ Jakarta',
                  controller: _locationC,
                ),
                const SizedBox(height: 28),

                // ── Tombol Daftar ────────────────────────────────────────────
                PrimaryButton(
                  text: 'Daftarkan $roleTitle',
                  isLoading: _isLoading,
                  onPressed: _register,
                ),
                const SizedBox(height: 16),

                // Link ke login (hanya jika bukan dari dalam panel admin)
                if (!widget.requireAuth)
                  Center(
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).maybePop(),
                      child: RichText(
                        text: const TextSpan(
                          text: 'Sudah punya akun? ',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.muted,
                          ),
                          children: [
                            TextSpan(
                              text: 'Masuk di sini',
                              style: TextStyle(
                                color: AppColors.primaryDark,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// WIDGET: Tombol pilih role
// ============================================================

class _RoleButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.fieldBg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? Colors.white : AppColors.muted,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: isSelected ? Colors.white : AppColors.textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// WIDGET: Banner info role
// ============================================================

class _RoleInfoBanner extends StatelessWidget {
  final String role;
  const _RoleInfoBanner({required this.role});

  @override
  Widget build(BuildContext context) {
    final isAdmin = role == 'admin';
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: Container(
        key: ValueKey(role),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.lightGreen,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.primary.withOpacity(0.3)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              isAdmin
                  ? Icons.admin_panel_settings_outlined
                  : Icons.badge_outlined,
              size: 16,
              color: AppColors.primaryDark,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                isAdmin
                    ? 'Admin memiliki akses penuh: manajemen pengguna, produk, dan laporan.'
                    : 'Petugas memiliki akses terbatas: manajemen stok dan produk.',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.primaryDark,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// WIDGET: Input password dengan toggle visibilitas
// ============================================================

class _PasswordField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final bool obscure;
  final VoidCallback onToggle;
  final String? Function(String?)? validator;

  const _PasswordField({
    required this.label,
    required this.hint,
    required this.controller,
    required this.obscure,
    required this.onToggle,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          obscureText: obscure,
          validator: validator,
          style: const TextStyle(fontSize: 13),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              fontSize: 12,
              color: AppColors.muted,
            ),
            filled: true,
            fillColor: AppColors.fieldBg,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
            ),
            suffixIcon: IconButton(
              onPressed: onToggle,
              icon: Icon(
                obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                size: 18,
                color: AppColors.muted,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

