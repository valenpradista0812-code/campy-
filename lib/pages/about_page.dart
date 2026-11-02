import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/common_widgets.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('About',
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
            CampyLogo(color: AppColors.primary, size: 72),
            SizedBox(height: 28),
            Text(
              'About Campy',
              style:
                  TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            SizedBox(height: 16),
            Text(
              'Campy is a mobile base app to help people who has plan to reach the top of a mountain with a reasonable price. Campy came to replace conventional way to lent items or equipment for hiking or camping.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 13,
                  height: 1.7,
                  color: AppColors.textGrey),
            ),
            SizedBox(height: 24),
            Text(
              'Our mission is to make outdoor adventures accessible to everyone by providing affordable, high-quality camping and hiking equipment rentals.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 13,
                  height: 1.7,
                  color: AppColors.textGrey),
            ),
            SizedBox(height: 32),
            Text(
              'Version 1.0.0',
              style: TextStyle(fontSize: 11, color: AppColors.muted),
            ),
            SizedBox(height: 4),
            Text(
              '© 2024 Campy. All rights reserved.',
              style: TextStyle(fontSize: 10, color: AppColors.muted),
            ),
          ],
        ),
      ),
    );
  }
}
