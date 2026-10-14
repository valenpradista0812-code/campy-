import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/common_widgets.dart';
import 'main_shell.dart';
import 'signup_page.dart';
import 'home_page.dart';
import 'home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailC = TextEditingController();
  final _passC = TextEditingController();

  @override
  void dispose() {
    _emailC.dispose();
    _passC.dispose();
    super.dispose();
  }

  void _login() {
    if (!_formKey.currentState!.validate()) return;
    // TODO: panggil API / Firebase Auth di sini
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Login berhasil (dummy)')),
    );
    // Navigate to main shell after login
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const MainShell()),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Login berhasil (dummy)')),
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
                const SizedBox(height: 60),
                const CampyLogo(color: AppColors.primary, size: 64),
                const SizedBox(height: 40),
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
                const SizedBox(height: 16),
                AppTextField(
                  label: 'Password',
                  hint: '••••••••',
                  controller: _passC,
                  isPassword: true,
                  validator: (v) => (v == null || v.length < 6)
                      ? 'Minimal 6 karakter'
                      : null,
                ),
                Align(
                  alignment: Alignment.center,
                  child: TextButton(
                    onPressed: () {},
                    child: const Text('Forgot Password?',
                        style: TextStyle(
                            fontSize: 11, color: AppColors.primary)),
                  ),
                ),
                const SizedBox(height: 4),
                PrimaryButton(text: 'Log In', onPressed: _login),
                const SizedBox(height: 12),
                OutlineButton(
                  text: 'Register',
                  onPressed: () => Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const SignUpPage()),
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
