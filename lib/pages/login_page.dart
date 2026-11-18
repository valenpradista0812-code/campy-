import 'package:flutter/material.dart';
import '../data.dart';
import '../services/api_service.dart';
import '../theme/app_colors.dart';
import '../widgets/common_widgets.dart';
import 'admins/admin_login_page.dart';
import 'admins/admin_shell.dart';
import 'admins/super_admin_register_page.dart';
import 'forgot_password_page.dart';
import 'main_shell.dart';
import 'petugas/petugas_login_page.dart';
import 'petugas/petugas_shell.dart';
import 'signup_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
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
      final isOnline = await ApiService.isBackendConnected();
      if (!isOnline) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Server backend offline (${ApiService.baseUrl}). Pastikan backend sedang berjalan.',
            ),
            backgroundColor: Colors.red.shade700,
          ),
        );
        return;
      }

      final res = await ApiService.login(
        _emailC.text.trim(),
        _passC.text.trim(),
      );

      if (!mounted) return;

      if (res['success'] == true) {
        wishlistNotifier.value = await ApiService.getWishlist();
        if (!mounted) return;

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Login berhasil!')));
        final role = ApiService.currentUserRole;
        final destination = role == 'admin'
            ? const AdminShell()
            : role == 'petugas'
            ? const PetugasShell()
            : const MainShell();
        Navigator.of(
          context,
        ).pushReplacement(MaterialPageRoute(builder: (_) => destination));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(res['message'] ?? 'Login gagal.'),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 60),
                const CampyLogo(color: AppColors.primary, size: 64),
                const SizedBox(height: 40),
                AppTextField(
                  label: 'Email',
                  hint: 'email@example.com',
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
                      (v == null || v.length < 6) ? 'Minimal 6 karakter' : null,
                ),
                Align(
                  alignment: Alignment.center,
                  child: TextButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const ForgotPasswordPage(),
                      ),
                    ),
                    child: const Text(
                      'Forgot Password?',
                      style: TextStyle(fontSize: 11, color: AppColors.primary),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                PrimaryButton(
                  text: 'Log In',
                  isLoading: _isLoading,
                  onPressed: _login,
                ),
                const SizedBox(height: 12),
                OutlineButton(
                  text: 'Register',
                  onPressed: () => Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const SignUpPage()),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const AdminLoginPage(),
                        ),
                      ),
                      child: const Text(
                        'Login as Admin',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const Text(
                      '|',
                      style: TextStyle(fontSize: 11, color: AppColors.muted),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const PetugasLoginPage(),
                        ),
                      ),
                      child: const Text(
                        'Login as Petugas',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const SuperAdminRegisterPage(),
                    ),
                  ),
                  child: const Text(
                    'Daftar Akun Super Admin',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryDark,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
