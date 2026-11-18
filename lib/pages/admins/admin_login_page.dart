import 'package:flutter/material.dart';
import '../../widgets/staff_widgets.dart';
import 'admin_shell.dart';
import 'super_admin_register_page.dart';

class AdminLoginPage extends StatelessWidget {
  const AdminLoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return StaffLoginForm(
      roleLabel: 'Admin',
      emailHint: 'admin@example.com',
      destination: (_) => const AdminShell(),
      registerPage: const SuperAdminRegisterPage(),
      registerLabel: 'Daftar sebagai Super Admin',
    );
  }
}
