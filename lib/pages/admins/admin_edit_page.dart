import 'package:flutter/material.dart';
import '../../staff_data.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/staff_widgets.dart';

/// Admin Settings: ubah data admin yang dipilih dari daftar.
class AdminEditPage extends StatefulWidget {
  final AdminUser admin;
  const AdminEditPage({super.key, required this.admin});

  @override
  State<AdminEditPage> createState() => _AdminEditPageState();
}

class _AdminEditPageState extends State<AdminEditPage> {
  final _formKey = GlobalKey<FormState>();
  late final _nameC = TextEditingController(text: widget.admin.username);
  late final _emailC = TextEditingController(text: widget.admin.email);
  late final _detailC = TextEditingController(text: widget.admin.detail);
  late final _locationC = TextEditingController(text: widget.admin.location);

  @override
  void dispose() {
    _nameC.dispose();
    _emailC.dispose();
    _detailC.dispose();
    _locationC.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final updated = widget.admin.copyWith(
      username: _nameC.text.trim(),
      email: _emailC.text.trim(),
      detail: _detailC.text.trim(),
      location: _locationC.text.trim(),
    );
    adminsNotifier.value = [
      for (final a in adminsNotifier.value) a.id == updated.id ? updated : a,
    ];
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Admin updated')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final admin = widget.admin;
    return Scaffold(
      appBar: staffFormAppBar(context, 'Admin Settings'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: AppColors.lightGreen,
                    child: const Icon(Icons.person,
                        size: 44, color: AppColors.primary),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(admin.username,
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primaryDark)),
                        const SizedBox(height: 4),
                        const Text('Details',
                            style: TextStyle(
                                fontSize: 10, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 2),
                        Text(
                          admin.detail.isEmpty ? '-' : admin.detail,
                          style: const TextStyle(
                              fontSize: 9, color: AppColors.textGrey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              AppTextField(
                label: 'User name',
                hint: 'Add username',
                controller: _nameC,
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'User name wajib diisi'
                    : null,
              ),
              const SizedBox(height: 14),
              AppTextField(
                label: 'User Email',
                hint: 'Add user email',
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
                label: 'Admin Detail',
                hint: 'Add Admin Detail',
                controller: _detailC,
              ),
              const SizedBox(height: 14),
              AppTextField(
                label: 'User Location',
                hint: 'Add user Location',
                controller: _locationC,
                trailingIcon: Icons.open_in_new,
              ),
              const SizedBox(height: 28),
              Center(
                child: SizedBox(
                  width: 190,
                  child: PrimaryButton(text: 'Save', onPressed: _save),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
