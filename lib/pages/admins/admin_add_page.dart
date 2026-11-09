import 'package:flutter/material.dart';
import '../../staff_data.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/staff_widgets.dart';

/// Add New Admin.
class AdminAddPage extends StatefulWidget {
  const AdminAddPage({super.key});

  @override
  State<AdminAddPage> createState() => _AdminAddPageState();
}

class _AdminAddPageState extends State<AdminAddPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameC = TextEditingController();
  final _emailC = TextEditingController();
  final _detailC = TextEditingController();
  final _locationC = TextEditingController();

  @override
  void dispose() {
    _nameC.dispose();
    _emailC.dispose();
    _detailC.dispose();
    _locationC.dispose();
    super.dispose();
  }

  void _add() {
    if (!_formKey.currentState!.validate()) return;
    adminsNotifier.value = [
      ...adminsNotifier.value,
      AdminUser(
        id: nextAdminId(),
        username: _nameC.text.trim(),
        email: _emailC.text.trim(),
        detail: _detailC.text.trim(),
        location: _locationC.text.trim(),
      ),
    ];
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Admin added')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: staffFormAppBar(context, 'Add New Admin'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
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
              const SizedBox(height: 36),
              SizedBox(
                width: 190,
                child: PrimaryButton(text: 'Add', onPressed: _add),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
