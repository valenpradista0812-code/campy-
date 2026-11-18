import 'package:flutter/material.dart';
import 'data.dart';
import 'pages/admins/admin_shell.dart';
import 'pages/main_shell.dart';
import 'pages/petugas/petugas_shell.dart';
import 'pages/start_page.dart';
import 'services/api_service.dart';
import 'theme/app_colors.dart';

final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ApiService.init();

  ApiService.onSessionExpired = () {
    final navigator = _navigatorKey.currentState;
    if (navigator == null) return;
    navigator.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const StartPage()),
      (route) => false,
    );
  };

  runApp(const CampyApp());

  catalogLoading.value = true;
  ApiService.getProducts()
      .then((prods) {
        productsNotifier.value = prods;
        catalogError.value = ApiService.lastError;
        catalogLoading.value = false;
      })
      .catchError((Object error) {
        catalogError.value = error.toString();
        catalogLoading.value = false;
      });

  // If user is already logged in, fetch wishlist in background
  if (ApiService.isAuthenticated) {
    ApiService.getWishlist().then((wishes) {
      wishlistNotifier.value = wishes;
    });
  }
}

class CampyApp extends StatelessWidget {
  const CampyApp({super.key});

  Widget _getInitialHome() {
    if (ApiService.isAuthenticated) {
      final role = ApiService.currentUserRole;
      if (role == 'admin') return const AdminShell();
      if (role == 'petugas') return const PetugasShell();
      return const MainShell();
    }
    return const StartPage();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navigatorKey,
      title: 'Campy',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Arial',
        colorSchemeSeed: AppColors.primary,
        scaffoldBackgroundColor: Colors.white,
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: AppColors.textDark),
          bodyMedium: TextStyle(color: AppColors.textDark),
          bodySmall: TextStyle(color: AppColors.textDark),
          titleLarge: TextStyle(color: AppColors.textDark),
          titleMedium: TextStyle(color: AppColors.textDark),
          titleSmall: TextStyle(color: AppColors.textDark),
          labelLarge: TextStyle(color: AppColors.textDark),
          labelMedium: TextStyle(color: AppColors.textDark),
          labelSmall: TextStyle(color: AppColors.textDark),
        ),
      ),
      home: _getInitialHome(),
    );
  }
}
