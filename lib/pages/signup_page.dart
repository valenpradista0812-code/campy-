import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/common_widgets.dart';
import 'login_page.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameC = TextEditingController();
  final _emailC = TextEditingController();
  final _phoneC = TextEditingController();
  final _passC = TextEditingController();

  @override
  void dispose() {
    _nameC.dispose();
    _emailC.dispose();
    _phoneC.dispose();
    _passC.dispose();
    super.dispose();
  }

  void _register() {
    if (!_formKey.currentState!.validate()) return;
    // TODO: panggil API / Firebase Auth di sini
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Registrasi berhasil (dummy)')),
    );
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
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
                const SizedBox(height: 40),
                const CampyLogo(color: AppColors.primary, size: 56),
                const SizedBox(height: 28),
                AppTextField(
                  label: 'Name',
                  hint: 'Nama lengkap',
                  controller: _nameC,
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Nama wajib diisi' : null,
                ),
                const SizedBox(height: 14),
                AppTextField(
                  label: 'Email',
                  hint: 'email@example.com',
                  controller: _emailC,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Email wajib diisi';
                    if (!v.contains('@')) return 'Email tidak valid';
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                AppTextField(
                  label: 'Phone',
                  hint: '0812-3456-7890',
                  controller: _phoneC,
                  keyboardType: TextInputType.phone,
                  validator: (v) => (v == null || v.length < 8)
                      ? 'Nomor telepon tidak valid'
                      : null,
                ),
                const SizedBox(height: 14),
                AppTextField(
                  label: 'Password',
                  hint: '••••••••',
                  controller: _passC,
                  isPassword: true,
                  validator: (v) => (v == null || v.length < 6)
                      ? 'Minimal 6 karakter'
                      : null,
                ),
                const SizedBox(height: 28),
                PrimaryButton(text: 'Register', onPressed: _register),
                const SizedBox(height: 12),
                OutlineButton(
                  text: 'Log In',
                  onPressed: () => Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const LoginPage()),
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
