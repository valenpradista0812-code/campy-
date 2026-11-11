import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/common_widgets.dart';
import 'onboarding_page.dart';

// ─── Acceptance page (ditampilkan di awal sebelum onboarding) ─────────────────

class TermsAcceptancePage extends StatefulWidget {
  const TermsAcceptancePage({super.key});

  @override
  State<TermsAcceptancePage> createState() => _TermsAcceptancePageState();
}

class _TermsAcceptancePageState extends State<TermsAcceptancePage> {
  bool _accepted = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Text(
                'Terms & Policy',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ),
            const Divider(height: 1),
            const Expanded(child: _TermsContent()),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  Checkbox(
                    value: _accepted,
                    activeColor: AppColors.primary,
                    onChanged: (v) => setState(() => _accepted = v ?? false),
                  ),
                  const Expanded(
                    child: Text(
                      'I have read and agree to the Terms & Policy',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
              child: PrimaryButton(
                text: 'Continue',
                onPressed: _accepted
                    ? () => Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                              builder: (_) => const OnboardingPage()),
                        )
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── View-only page (dari Profile > Terms & Policy) ───────────────────────────

class TermsPolicyViewPage extends StatelessWidget {
  const TermsPolicyViewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Terms & Policy',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, size: 22),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: _TermsContent(),
      ),
    );
  }
}

// ─── Konten Terms (dipakai di kedua page di atas) ─────────────────────────────

class _TermsContent extends StatelessWidget {
  const _TermsContent();

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('KYT Support & Payment Policy',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
          SizedBox(height: 8),
          Text(
            'Before using the CAMPY app, please read & agree to the following terms and policy.',
            style: TextStyle(fontSize: 12, height: 1.6, color: AppColors.textGrey),
          ),
          SizedBox(height: 20),
          _Section(
            title: 'KTP for Companies',
            body:
                'To conduct KYT verification, CAMPY will not accept uploads of KTP during rental sessions that are already expired. Any KTP that is expired will still be accepted during the rental period and will only be validated for verification upon returning the item.',
          ),
          _Section(
            title: 'Customer Responsibilities',
            body: 'You agree to:\n'
                '• Provide and use a valid KTP for every rental.\n'
                '• Return the equipment on the agreed return date in good condition.\n'
                '• Pay for any damage or loss that occurs during the rental period.',
          ),
          _Section(
            title: 'Damage & Rental Policy',
            body:
                'Customers are responsible for any damage to or loss of equipment that occurs during the rental period. A replacement fee may be requested depending on the extent of the damage. Equipment returned in poor condition will be assessed and compensation charged accordingly.',
          ),
          _Section(
            title: 'Return of KTP',
            body:
                'Your KTP will be returned after the rental agreement is complete, including the satisfaction of any applicable fees and policies.',
          ),
          _Section(
            title: 'Privacy Policy',
            body:
                'Your personal information will be handled responsibly and will not be used for commercial purposes by third parties. By checking this agreement you acknowledge that you have read and agreed to these policies.',
          ),
          SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final String body;
  const _Section({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Text(body,
              style: const TextStyle(
                  fontSize: 12, height: 1.6, color: AppColors.textGrey)),
        ],
      ),
    );
  }
}
