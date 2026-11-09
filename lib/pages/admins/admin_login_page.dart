import 'package:flutter/material.dart';
import '../../staff_data.dart';
import '../../widgets/staff_widgets.dart';
import 'admin_shell.dart';

class AdminLoginPage extends StatelessWidget {
  const AdminLoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return StaffLoginForm(
      roleLabel: 'Admin',
      emailHint: kAdminEmail,
      verify: verifyAdmin,
      destination: (_) => const AdminShell(),
    );
  }
}
