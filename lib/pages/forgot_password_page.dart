import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/common.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _email = TextEditingController(text: 'valenpradista0812@gmail.com');
  final _old = TextEditingController();
  final _new = TextEditingController();
  final _code = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _old.dispose();
    _new.dispose();
    _code.dispose();
    super.dispose();
  }

  Widget _field(String label, TextEditingController c,
      {bool obscure = false, TextInputType? type}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(fontSize: 10, color: AppColors.muted)),
          const SizedBox(height: 4),
          SizedBox(
            height: 34,
            child: TextField(
              controller: c,
              obscureText: obscure,
              keyboardType: type,
              style: const TextStyle(fontSize: 11),
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.field,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
          child: Column(
            children: [
              const CampyLogo(size: 52),
              const SizedBox(height: 28),
              _field('Email', _email, type: TextInputType.emailAddress),
              _field('Old Password', _old, obscure: true),
              _field('New Password', _new, obscure: true),
              _field('Code Verification', _code, type: TextInputType.number),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 36,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6)),
                  ),
                  child: const Text('Change Password',
                      style: TextStyle(fontSize: 11)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
