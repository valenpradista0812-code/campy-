import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/common_widgets.dart';

class MyDetailsPage extends StatefulWidget {
  const MyDetailsPage({super.key});

  @override
  State<MyDetailsPage> createState() => _MyDetailsPageState();
}

class _MyDetailsPageState extends State<MyDetailsPage> {
  final _nameC =
      TextEditingController(text: 'Valen Pradista');
  final _emailC =
      TextEditingController(text: 'valenpradista@gmail.com');
  final _phoneC =
      TextEditingController(text: '+62 812-3456-7890');
  final _addressC =
      TextEditingController(text: 'Jl. Campy No. 1, Jakarta Selatan');

  @override
  void dispose() {
    _nameC.dispose();
    _emailC.dispose();
    _phoneC.dispose();
    _addressC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('My Details',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, size: 22),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
        child: Column(
          children: [
            // ── Profile photo ──────────────────────────────────────────────
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: AppColors.lightGreen,
                  child: const Icon(Icons.person,
                      size: 58, color: AppColors.primary),
                ),
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.camera_alt,
                        size: 16, color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),

            // ── Form fields ────────────────────────────────────────────────
            AppTextField(label: 'Full Name', controller: _nameC),
            const SizedBox(height: 14),
            AppTextField(
              label: 'Email',
              controller: _emailC,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 14),
            AppTextField(
              label: 'Phone Number',
              controller: _phoneC,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 14),
            AppTextField(label: 'Address', controller: _addressC),
            const SizedBox(height: 32),

            // ── Save button ────────────────────────────────────────────────
            PrimaryButton(
              text: 'Save Changes',
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Details saved successfully'),
                      duration: Duration(seconds: 2)),
                );
                Navigator.of(context).maybePop();
              },
            ),
          ],
        ),
      ),
    );
  }
}
