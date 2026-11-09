import 'package:flutter/material.dart';
import '../../staff_data.dart';
import '../../widgets/staff_widgets.dart';
import 'admin_add_page.dart';
import 'admin_home_page.dart';

class AdminShell extends StatefulWidget {
  const AdminShell({super.key});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: IndexedStack(
          index: _index,
          children: const [
            AdminHomePage(),
            StaffProfileView(
              name: kAdminName,
              email: kAdminEmail,
              role: 'Admin',
            ),
          ],
        ),
      ),
      bottomNavigationBar: StaffBottomBar(
        index: _index,
        onTab: (i) => setState(() => _index = i),
        centerLabel: 'Add Admin',
        onCenter: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const AdminAddPage()),
        ),
      ),
    );
  }
}
