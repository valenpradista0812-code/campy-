import 'package:flutter/material.dart';
import '../../staff_data.dart';
import '../../widgets/staff_widgets.dart';
import 'petugas_add_item_page.dart';
import 'petugas_home_page.dart';

class PetugasShell extends StatefulWidget {
  const PetugasShell({super.key});

  @override
  State<PetugasShell> createState() => _PetugasShellState();
}

class _PetugasShellState extends State<PetugasShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: IndexedStack(
          index: _index,
          children: const [
            PetugasHomePage(),
            StaffProfileView(
              name: kPetugasName,
              email: kPetugasEmail,
              role: 'Petugas',
            ),
          ],
        ),
      ),
      bottomNavigationBar: StaffBottomBar(
        index: _index,
        onTab: (i) => setState(() => _index = i),
        centerLabel: 'Add Item',
        onCenter: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const PetugasAddItemPage()),
        ),
      ),
    );
  }
}
