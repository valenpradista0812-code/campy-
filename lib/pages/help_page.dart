import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/common_widgets.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Help',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, size: 22),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(32, 40, 32, 40),
        child: Column(
          children: [
            CampyLogo(color: AppColors.primary, size: 60),
            SizedBox(height: 20),
            Text('Help Center',
                style:
                    TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            SizedBox(height: 20),
            Text(
              'Need help? Have a question, issue, or complaint about CAMPY? Our customer service team is here to help.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 13, height: 1.7, color: AppColors.textGrey),
            ),
            SizedBox(height: 16),
            Text(
              'If you experience any problems or have feedback, please know and contact us via email:',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 13, height: 1.7, color: AppColors.textGrey),
            ),
            SizedBox(height: 12),
            Text(
              'campyapp@gmail.com',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary),
            ),
            SizedBox(height: 20),
            Text(
              'Please describe your issue as detailed as possible. Our team will reach you quickly and effectively. Your feedback is very important for our Campy.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 13, height: 1.7, color: AppColors.textGrey),
            ),
          ],
        ),
      ),
    );
  }
}
