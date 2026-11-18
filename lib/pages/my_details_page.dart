import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../theme/app_colors.dart';
import '../widgets/common_widgets.dart';

class MyDetailsPage extends StatefulWidget {
  const MyDetailsPage({super.key});

  @override
  State<MyDetailsPage> createState() => _MyDetailsPageState();
}

class _MyDetailsPageState extends State<MyDetailsPage> {
  final _nameC = TextEditingController();
  final _emailC = TextEditingController();
  final _phoneC = TextEditingController();
  final _addressC = TextEditingController();
  bool _isLoading = true;
  bool _isSaving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final profile = await ApiService.getProfile();
    if (!mounted) return;
    if (profile == null) {
      setState(() {
        _isLoading = false;
        _error = ApiService.lastError;
      });
      return;
    }
    _nameC.text = profile['full_name'] as String? ?? '';
    _emailC.text = profile['email'] as String? ?? '';
    _phoneC.text = profile['phone'] as String? ?? '';
    _addressC.text = profile['address'] as String? ?? '';
    setState(() => _isLoading = false);
  }

  Future<void> _saveProfile() async {
    setState(() => _isSaving = true);
    final saved = await ApiService.updateProfile(
      fullName: _nameC.text.trim(),
      phone: _phoneC.text.trim(),
      address: _addressC.text.trim(),
    );
    if (!mounted) return;
    setState(() => _isSaving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          saved
              ? 'Profil berhasil disimpan.'
              : ApiService.lastError ?? 'Gagal menyimpan profil.',
        ),
        backgroundColor: saved ? null : Colors.red.shade700,
      ),
    );
    if (saved) Navigator.of(context).maybePop();
  }

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
        title: const Text(
          'My Details',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        ),
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, size: 22),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text('Gagal memuat profil: $_error'))
          : SingleChildScrollView(
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
                        child: const Icon(
                          Icons.person,
                          size: 58,
                          color: AppColors.primary,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {},
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            size: 16,
                            color: Colors.white,
                          ),
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
                    readOnly: true,
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
                    isLoading: _isSaving,
                    onPressed: _saveProfile,
                  ),
                ],
              ),
            ),
    );
  }
}
