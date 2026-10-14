import 'package:flutter/material.dart';
import 'pages/start_page.dart';
import 'theme/app_colors.dart';

void main() {
  runApp(const CampyApp());
}

class CampyApp extends StatelessWidget {
  const CampyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Campy',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: AppColors.primary,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const StartPage(),
    );
  }
}
