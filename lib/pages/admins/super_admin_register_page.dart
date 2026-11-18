import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common_widgets.dart';
import 'admin_login_page.dart';
import 'admin_shell.dart';

/// Halaman Register Khusus Super Admin
/// Super Admin memiliki kewenangan tertinggi untuk mendaftarkan dan mengelola
/// Admin lain serta Petugas toko.
class SuperAdminRegisterPage extends StatefulWidget {
  const SuperAdminRegisterPage({super.key});

  @override
  State<SuperAdminRegisterPage> createState() => _SuperAdminRegisterPageState();
}

class _SuperAdminRegisterPageState extends State<SuperAdminRegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameC = TextEditingController();
  final _emailC = TextEditingController();
  final _passwordC = TextEditingController();
  final _confirmPasswordC = TextEditingController();
  final _phoneC = TextEditingController();
  final _detailC = TextEditingController(text: 'Kepala Administrator');
  final _locationC = TextEditingController(text: 'Campy HQ');

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

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final res = await ApiService.registerSuperAdmin(
        email: _emailC.text.trim(),
        password: _passwordC.text,
        name: _nameC.text.trim(),
        phone: _phoneC.text.trim(),
        detail: _detailC.text.trim(),
        location: _locationC.text.trim(),
      );

      if (!mounted) return;

      if (res['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              res['message'] ?? 'Akun Super Admin berhasil dibuat!',
            ),
            backgroundColor: AppColors.primaryDark,
          ),
        );

        // Langsung masuk ke AdminShell sebagai Super Admin
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const AdminShell()),
          (route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              res['message'] ?? 'Gagal mendaftar akun Super Admin.',
            ),
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, size: 24),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      const CampyLogo(color: AppColors.primary, size: 68),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD4AF37), // Emas
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(
                          Icons.workspace_premium,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Badge Super Admin
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF4D6),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFE2B734)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.stars_rounded,
                          size: 15,
                          color: Color(0xFFB38600),
                        ),
                        SizedBox(width: 6),
                        Text(
                          'REGISTRASI SUPER ADMIN',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                            color: Color(0xFF8A6500),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                const Text(
                  'Buat Akun Super Admin',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryDark,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Akses penuh untuk mendaftarkan dan mengelola Admin lain serta Petugas toko.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.muted,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 20),

                // Card info otoritas Super Admin
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.lightGreen,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.35),
                    ),
                  ),
                  child: const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.shield_outlined,
                        color: AppColors.primaryDark,
                        size: 20,
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hak Istimewa Super Admin',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primaryDark,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              '• Menambahkan & menghapus akun Admin lain\n'
                              '• Menambahkan & memonitor Petugas inventaris\n'
                              '• Akses penuh ke seluruh kontrol dan katalog toko',
                              style: TextStyle(
                                fontSize: 10.5,
                                color: AppColors.textDark,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Field Nama Lengkap / Username
                AppTextField(
                  label: 'Nama Lengkap Super Admin',
                  hint: 'Contoh: Ahmad Fauzi (Super Admin)',
                  controller: _nameC,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Nama lengkap wajib diisi';
                    }
                    if (v.trim().length < 3) {
                      return 'Nama minimal terdiri dari 3 karakter';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                // Field Email
                AppTextField(
                  label: 'Email Super Admin',
                  hint: 'superadmin@campy.com',
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

                // Field Password
                _SuperAdminPasswordField(
                  label: 'Password',
                  hint: 'Minimal 6 karakter',
                  controller: _passwordC,
                  obscure: _obscurePassword,
                  onToggle: () => setState(
                    () => _obscurePassword = !_obscurePassword,
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Password wajib diisi';
                    if (v.length < 6) return 'Password minimal 6 karakter';
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                // Field Konfirmasi Password
                _SuperAdminPasswordField(
                  label: 'Konfirmasi Password',
                  hint: 'Ketik ulang password',
                  controller: _confirmPasswordC,
                  obscure: _obscureConfirm,
                  onToggle: () => setState(
                    () => _obscureConfirm = !_obscureConfirm,
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) {
                      return 'Konfirmasi password wajib diisi';
                    }
                    if (v != _passwordC.text) {
                      return 'Konfirmasi password tidak cocok';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                // Field Telepon
                AppTextField(
                  label: 'Nomor Telepon (WhatsApp)',
                  hint: '081234567890',
                  controller: _phoneC,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 14),

                // Field Detail / Jabatan
                AppTextField(
                  label: 'Detail Jabatan / Peran',
                  hint: 'Contoh: Kepala Administrator Sistem Campy',
                  controller: _detailC,
                ),
                const SizedBox(height: 14),

                // Field Lokasi / Markas
                AppTextField(
                  label: 'Lokasi Kantor / Cabang',
                  hint: 'Contoh: Campy HQ Jakarta Pusat',
                  controller: _locationC,
                ),
                const SizedBox(height: 26),

                // Tombol Submit
                PrimaryButton(
                  text: 'Daftar sebagai Super Admin',
                  isLoading: _isLoading,
                  onPressed: _handleRegister,
                ),
                const SizedBox(height: 18),

                // Link ke Login Admin
                Center(
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (_) => const AdminLoginPage(),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(6),
                      child: RichText(
                        text: const TextSpan(
                          text: 'Sudah memiliki akun Super Admin? ',
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
                ),
                const SizedBox(height: 28),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SuperAdminPasswordField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final bool obscure;
  final VoidCallback onToggle;
  final String? Function(String?)? validator;

  const _SuperAdminPasswordField({
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
            hintStyle: const TextStyle(fontSize: 12, color: AppColors.muted),
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
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 1.5,
              ),
            ),
            suffixIcon: IconButton(
              onPressed: onToggle,
              icon: Icon(
                obscure
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
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
