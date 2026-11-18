import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../staff_data.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/staff_widgets.dart';

/// Staff Settings: ubah data admin atau petugas yang dipilih dari daftar.
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
  bool _isLoading = false;

  @override
  void dispose() {
    _nameC.dispose();
    _emailC.dispose();
    _detailC.dispose();
    _locationC.dispose();
    super.dispose();
  }

  void _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final isPetugas = widget.admin.role == 'petugas';

    try {
      final success = isPetugas
          ? await ApiService.updatePetugas(
              id: widget.admin.id,
              username: _nameC.text.trim(),
              email: _emailC.text.trim(),
              detail: _detailC.text.trim(),
              location: _locationC.text.trim(),
            )
          : await ApiService.updateAdmin(
              id: widget.admin.id,
              username: _nameC.text.trim(),
              email: _emailC.text.trim(),
              detail: _detailC.text.trim(),
              location: _locationC.text.trim(),
            );

      if (!mounted) return;

      if (success) {
        if (isPetugas) {
          ApiService.getPetugasList().then((list) {
            petugasNotifier.value = list;
          });
        } else {
          ApiService.getAdmins().then((list) {
            adminsNotifier.value = list;
          });
        }

        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Data ${isPetugas ? "petugas" : "admin"} berhasil diperbarui',
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              ApiService.lastError ??
                  'Gagal memperbarui data ${isPetugas ? "petugas" : "admin"}',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final roleName = widget.admin.role == 'petugas' ? 'Petugas' : 'Admin';

    return Scaffold(
      appBar: staffFormAppBar(context, '$roleName Settings'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 12),
              CircleAvatar(
                radius: 40,
                backgroundColor: AppColors.lightGreen,
                child: const Icon(
                  Icons.person,
                  size: 48,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.admin.username,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '$roleName • ${widget.admin.email}',
                style: const TextStyle(fontSize: 10, color: AppColors.muted),
              ),
              const SizedBox(height: 24),
              AppTextField(
                label: 'Nama / Username',
                controller: _nameC,
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Nama wajib diisi'
                    : null,
              ),
              const SizedBox(height: 12),
              AppTextField(
                label: 'Email',
                controller: _emailC,
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Email wajib diisi';
                  if (!v.contains('@')) return 'Email tidak valid';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              AppTextField(label: 'Detail Tugas', controller: _detailC),
              const SizedBox(height: 12),
              AppTextField(label: 'Location Toko', controller: _locationC),
              const SizedBox(height: 24),
              PrimaryButton(
                text: 'Simpan Perubahan',
                isLoading: _isLoading,
                onPressed: _save,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
