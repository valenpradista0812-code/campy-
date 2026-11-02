import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  bool _payment = true;
  bool _rentalReminder = true;
  bool _additionalFee = false;
  bool _lateReturnFee = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Notifications',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, size: 22),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Notification Settings',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.muted)),
          const SizedBox(height: 10),
          _Toggle(
            label: 'Payment',
            subtitle: 'Payment confirmation and updates',
            value: _payment,
            onChanged: (v) => setState(() => _payment = v),
          ),
          _Toggle(
            label: 'Rental Reminder',
            subtitle: 'Reminder before rental period ends',
            value: _rentalReminder,
            onChanged: (v) => setState(() => _rentalReminder = v),
          ),
          _Toggle(
            label: 'Additional Fee',
            subtitle: 'Notification about any extra charges',
            value: _additionalFee,
            onChanged: (v) => setState(() => _additionalFee = v),
          ),
          _Toggle(
            label: 'Late Return Fee',
            subtitle: 'Alert when equipment is returned late',
            value: _lateReturnFee,
            onChanged: (v) => setState(() => _lateReturnFee = v),
          ),
        ],
      ),
    );
  }
}

class _Toggle extends StatelessWidget {
  final String label;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _Toggle(
      {required this.label,
      required this.subtitle,
      required this.value,
      required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: const TextStyle(
                        fontSize: 10, color: AppColors.muted)),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}
