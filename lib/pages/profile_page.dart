import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'orders_page.dart';
import 'my_details_page.dart';
import 'history_transaction_page.dart';
import 'payment_methods_page.dart';
import 'notifications_page.dart';
import 'help_page.dart';
import 'about_page.dart';
import 'terms_policy_page.dart';
import 'wishlist_page.dart';
import 'login_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        // ── Header ──────────────────────────────────────────────────────────
        Container(
          color: AppColors.lightGreen,
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
          child: Row(
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                child: const Icon(Icons.person, size: 36, color: AppColors.primary),
              ),
              const SizedBox(width: 14),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Valen Pradista',
                      style: TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w700,
                          color: AppColors.textDark)),
                  SizedBox(height: 3),
                  Text('valenpradista@gmail.com',
                      style: TextStyle(fontSize: 11, color: AppColors.muted)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        // ── Menu Items ───────────────────────────────────────────────────────
        _MenuItem(
          icon: Icons.shopping_bag_outlined,
          label: 'Orders',
          onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const OrdersPage())),
        ),
        _MenuItem(
          icon: Icons.person_outline,
          label: 'My Details',
          onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const MyDetailsPage())),
        ),
        _MenuItem(
          icon: Icons.favorite_border,
          label: 'Wishlist & Saved Items',
          onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const WishlistPage())),
        ),
        _MenuItem(
          icon: Icons.history,
          label: 'History Transaction',
          onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const HistoryTransactionPage())),
        ),
        _MenuItem(
          icon: Icons.payment_outlined,
          label: 'Payment Methods',
          onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const PaymentMethodsPage())),
        ),
        _MenuItem(
          icon: Icons.notifications_outlined,
          label: 'Notifications',
          onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const NotificationsPage())),
        ),
        _MenuItem(
          icon: Icons.help_outline,
          label: 'Help',
          onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const HelpPage())),
        ),
        _MenuItem(
          icon: Icons.info_outline,
          label: 'About',
          onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const AboutPage())),
        ),
        _MenuItem(
          icon: Icons.description_outlined,
          label: 'Terms & Policy',
          onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const TermsPolicyViewPage())),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ListTile(
            leading: const Icon(Icons.logout, color: Colors.red, size: 20),
            title: const Text('Log Out',
                style: TextStyle(
                    fontSize: 13,
                    color: Colors.red,
                    fontWeight: FontWeight.w600)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(color: Colors.red.shade100),
            ),
            tileColor: Colors.red.shade50.withValues(alpha: 0.5),
            onTap: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Log Out',
                      style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w700)),
                  content: const Text(
                      'Are you sure you want to log out from Campy?',
                      style: TextStyle(fontSize: 12)),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: const Text('Cancel',
                          style: TextStyle(color: AppColors.muted)),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                              builder: (_) => const LoginPage()),
                          (route) => false,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Log Out'),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _MenuItem(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: AppColors.primary, size: 20),
          title: Text(label, style: const TextStyle(fontSize: 13)),
          trailing: const Icon(Icons.chevron_right,
              size: 18, color: AppColors.muted),
          onTap: onTap,
        ),
        const Divider(height: 1, indent: 56),
      ],
    );
  }
}
