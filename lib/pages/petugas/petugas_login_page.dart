import 'package:flutter/material.dart';
import '../../staff_data.dart';
import '../../widgets/staff_widgets.dart';
import 'petugas_shell.dart';

class PetugasLoginPage extends StatelessWidget {
  const PetugasLoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return StaffLoginForm(
      roleLabel: 'Petugas',
      emailHint: kPetugasEmail,
      verify: verifyPetugas,
      destination: (_) => const PetugasShell(),
    );
  }
}
