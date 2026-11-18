import 'dart:convert';
import 'package:flutter/material.dart';
import '../pages/start_page.dart';
import '../services/api_service.dart';
import '../staff_data.dart';
import '../theme/app_colors.dart';
import 'common_widgets.dart';

/// Warna kartu daftar admin.
const Color kStaffTile = Color(0xFFA9C0A4);

/// Bottom bar admin & petugas: Home | tombol tengah (+) | Profile.
class StaffBottomBar extends StatelessWidget {
  final int index; // 0 = Home, 1 = Profile
  final ValueChanged<int> onTab;
  final String centerLabel;
  final VoidCallback onCenter;

  const StaffBottomBar({
    super.key,
    required this.index,
    required this.onTab,
    required this.centerLabel,
    required this.onCenter,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 62,
          child: Row(
            children: [
              Expanded(
                child: _NavItem(
                  icon: Icons.home,
                  label: 'Home',
                  selected: index == 0,
                  onTap: () => onTab(0),
                ),
              ),
              Expanded(
                child: Center(
                  child: Transform.translate(
                    offset: const Offset(0, -12),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: onCenter,
                      child: Container(
                        width: 58,
                        height: 58,
                        decoration: BoxDecoration(
                          color: AppColors.primaryDark,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x33000000),
                              blurRadius: 6,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.add,
                              color: Colors.white,
                              size: 28,
                            ),
                            Text(
                              centerLabel,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 8,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: _NavItem(
                  icon: Icons.person,
                  label: 'Profile',
                  selected: index == 1,
                  onTap: () => onTab(1),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.primaryDark : AppColors.muted;
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

/// Form login yang dipakai bersama oleh login admin dan login petugas.
class StaffLoginForm extends StatefulWidget {
  final String roleLabel;
  final String emailHint;
  final WidgetBuilder destination;

  /// Widget halaman register yang dapat dibuka dari form login (opsional).
  final Widget? registerPage;

  /// Label teks link ke halaman register (opsional).
  final String? registerLabel;

  const StaffLoginForm({
    super.key,
    required this.roleLabel,
    required this.emailHint,
    required this.destination,
    this.registerPage,
    this.registerLabel,
  });

  @override
  State<StaffLoginForm> createState() => _StaffLoginFormState();
}

class _StaffLoginFormState extends State<StaffLoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailC = TextEditingController();
  final _passC = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailC.dispose();
    _passC.dispose();
    super.dispose();
  }

  void _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final roleKey = widget.roleLabel.toLowerCase();
      final res = await ApiService.staffLogin(
        email: _emailC.text.trim(),
        password: _passC.text.trim(),
        role: roleKey,
      );

      if (!mounted) return;

      if (res['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login ${widget.roleLabel} berhasil!')),
        );
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: widget.destination),
          (route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(res['message'] ?? 'Email atau password salah'),
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
          icon: const Icon(Icons.chevron_left, size: 22),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 24),
                const CampyLogo(color: AppColors.primary, size: 64),
                const SizedBox(height: 12),
                Text(
                  'Login ${widget.roleLabel}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryDark,
                  ),
                ),
                const SizedBox(height: 32),
                AppTextField(
                  label: 'Email',
                  hint: widget.emailHint,
                  controller: _emailC,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Email wajib diisi';
                    }
                    if (!v.contains('@')) return 'Email tidak valid';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: 'Password',
                  hint: '••••••••',
                  controller: _passC,
                  isPassword: true,
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Password wajib diisi' : null,
                ),
                const SizedBox(height: 28),
                PrimaryButton(
                  text: 'Log In',
                  isLoading: _isLoading,
                  onPressed: _login,
                ),
                const SizedBox(height: 20),

                // ── Link Register (opsional) ──────────────────────────────
                if (widget.registerPage != null) ...[
                  Row(
                    children: [
                      const Expanded(child: Divider(color: AppColors.border)),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          'atau',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.muted,
                          ),
                        ),
                      ),
                      const Expanded(child: Divider(color: AppColors.border)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => widget.registerPage!,
                      ),
                    ),
                    child: Center(
                      child: RichText(
                        text: TextSpan(
                          text: 'Belum punya akun? ',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.muted,
                          ),
                          children: [
                            TextSpan(
                              text: widget.registerLabel ?? 'Daftar di sini',
                              style: const TextStyle(
                                color: AppColors.primaryDark,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 28),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Tab Profile admin & petugas, dengan tombol Logout.
class StaffProfileView extends StatelessWidget {
  final String name;
  final String email;
  final String role;
  const StaffProfileView({
    super.key,
    required this.name,
    required this.email,
    required this.role,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 32),
          CircleAvatar(
            radius: 44,
            backgroundColor: AppColors.lightGreen,
            child: const Icon(Icons.person, size: 52, color: AppColors.primary),
          ),
          const SizedBox(height: 14),
          Text(
            ApiService.currentUserName ?? name,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            ApiService.currentUserEmail ?? email,
            style: const TextStyle(fontSize: 12, color: AppColors.muted),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.lightGreen,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              role,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryDark,
              ),
            ),
          ),
          const Spacer(),
          OutlineButton(
            text: 'Logout',
            onPressed: () async {
              await ApiService.logout();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const StartPage()),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
    );
  }
}

/// Gambar barang: foto yang diunggah petugas, atau tautan gambar, atau ikon.
class StockImage extends StatelessWidget {
  final StockItem item;
  final double size;
  const StockImage({super.key, required this.item, this.size = 56});

  @override
  Widget build(BuildContext context) {
    final bytes = item.imageBytes;
    if (bytes != null) {
      return Image.memory(
        bytes,
        width: size,
        height: size,
        fit: BoxFit.contain,
      );
    }
    final url = item.imageUrl;
    if (url != null && url.isNotEmpty) {
      if (url.startsWith('data:image')) {
        try {
          final base64Part = url.split(',').last;
          final decoded = base64Decode(base64Part);
          return Image.memory(
            decoded,
            width: size,
            height: size,
            fit: BoxFit.contain,
          );
        } catch (_) {}
      }
      final resolvedUrl = url.startsWith('/') ? '${ApiService.baseUrl}$url' : url;
      return Image.network(
        resolvedUrl,
        width: size,
        height: size,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) =>
            Icon(item.icon, size: size, color: AppColors.primary),
      );
    }
    return Icon(item.icon, size: size, color: AppColors.primary);
  }
}

/// Judul AppBar halaman form admin / petugas.
AppBar staffFormAppBar(BuildContext context, String title) {
  return AppBar(
    centerTitle: true,
    title: Text(
      title,
      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
    ),
    leading: IconButton(
      icon: const Icon(Icons.chevron_left, size: 22),
      onPressed: () => Navigator.of(context).maybePop(),
    ),
  );
}
