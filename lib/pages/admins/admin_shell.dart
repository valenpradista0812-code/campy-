import 'package:flutter/material.dart';
import '../../services/api_service.dart';
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
    final roleName = ApiService.isSuperAdmin ? 'Super Admin' : 'Admin';

    return Scaffold(
      body: SafeArea(
        child: IndexedStack(
          index: _index,
          children: [
            const AdminHomePage(),
            StaffProfileView(
              name: ApiService.currentUserName ?? 'Staff',
              email: ApiService.currentUserEmail ?? '',
              role: roleName,
            ),
          ],
        ),
      ),
      bottomNavigationBar: StaffBottomBar(
        index: _index,
        onTab: (i) => setState(() => _index = i),
        centerLabel: 'Add Staff',
        onCenter: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const AdminAddPage(),
          ),
        ),
      ),
    );
  }
}
