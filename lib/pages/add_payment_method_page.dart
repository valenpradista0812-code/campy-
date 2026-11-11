import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/common_widgets.dart';

class AddPaymentMethodPage extends StatefulWidget {
  const AddPaymentMethodPage({super.key});

  @override
  State<AddPaymentMethodPage> createState() => _AddPaymentMethodPageState();
}

class _AddPaymentMethodPageState extends State<AddPaymentMethodPage> {
  final _formKey = GlobalKey<FormState>();
  String _methodType = 'Card'; // 'Card', 'Bank', 'E-Wallet'
  String _provider = 'BCA';

  final _numberC = TextEditingController();
  final _nameC = TextEditingController(text: 'Valen Pradista');
  final _expiryC = TextEditingController();
  final _cvvC = TextEditingController();

  final List<String> _bankProviders = const ['BCA', 'Mandiri', 'BRI', 'BNI'];
  final List<String> _walletProviders = const ['GoPay', 'DANA', 'OVO', 'ShopeePay'];

  @override
  void dispose() {
    _numberC.dispose();
    _nameC.dispose();
    _expiryC.dispose();
    _cvvC.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$_provider payment method successfully added!'),
        duration: const Duration(seconds: 2),
      ),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Add Payment Method',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, size: 22),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Select Payment Type',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
              const SizedBox(height: 10),
              Row(
                children: [
                  _TypeButton(
                    label: 'Card',
                    icon: Icons.credit_card,
                    isSelected: _methodType == 'Card',
                    onTap: () => setState(() {
                      _methodType = 'Card';
                      _provider = 'BCA';
                    }),
                  ),
                  const SizedBox(width: 8),
                  _TypeButton(
                    label: 'Bank',
                    icon: Icons.account_balance,
                    isSelected: _methodType == 'Bank',
                    onTap: () => setState(() {
                      _methodType = 'Bank';
                      _provider = 'BCA';
                    }),
                  ),
                  const SizedBox(width: 8),
                  _TypeButton(
                    label: 'E-Wallet',
                    icon: Icons.account_balance_wallet,
                    isSelected: _methodType == 'E-Wallet',
                    onTap: () => setState(() {
                      _methodType = 'E-Wallet';
                      _provider = 'GoPay';
                    }),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // ── Provider selection ─────────────────────────────────────────
              Text(
                _methodType == 'E-Wallet'
                    ? 'Select E-Wallet Provider'
                    : 'Select Bank Provider',
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: (_methodType == 'E-Wallet'
                        ? _walletProviders
                        : _bankProviders)
                    .map((p) => ChoiceChip(
                          label: Text(p),
                          selected: _provider == p,
                          selectedColor: AppColors.primary,
                          labelStyle: TextStyle(
                            fontSize: 11,
                            color: _provider == p
                                ? Colors.white
                                : AppColors.textDark,
                            fontWeight: FontWeight.w600,
                          ),
                          onSelected: (val) {
                            if (val) setState(() => _provider = p);
                          },
                        ))
                    .toList(),
              ),
              const SizedBox(height: 20),

              // ── Input Fields ───────────────────────────────────────────────
              AppTextField(
                label: _methodType == 'Card'
                    ? 'Card Number'
                    : (_methodType == 'E-Wallet'
                        ? 'Phone Number'
                        : 'Account Number'),
                hint: _methodType == 'Card'
                    ? '4123 4567 8901 2345'
                    : (_methodType == 'E-Wallet'
                        ? '0812-3456-7890'
                        : '1234567890'),
                controller: _numberC,
                keyboardType: TextInputType.number,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Field cannot be empty' : null,
              ),
              const SizedBox(height: 14),

              AppTextField(
                label: 'Account Holder Name',
                hint: 'e.g. Valen Pradista',
                controller: _nameC,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Name is required' : null,
              ),
              const SizedBox(height: 14),

              if (_methodType == 'Card') ...[
                Row(
                  children: [
                    Expanded(
                      child: AppTextField(
                        label: 'Expiry Date',
                        hint: 'MM/YY',
                        controller: _expiryC,
                        keyboardType: TextInputType.datetime,
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Required'
                            : null,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: AppTextField(
                        label: 'CVV',
                        hint: '123',
                        controller: _cvvC,
                        keyboardType: TextInputType.number,
                        validator: (v) => (v == null || v.length < 3)
                            ? 'Invalid CVV'
                            : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],

              const SizedBox(height: 20),
              PrimaryButton(
                text: 'Save Payment Method',
                onPressed: _save,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TypeButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _TypeButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.lightGreen.withValues(alpha: 0.35)
                : AppColors.fieldBg,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.border,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(icon,
                  size: 20,
                  color: isSelected ? AppColors.primary : AppColors.muted),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight:
                      isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? AppColors.primaryDark : AppColors.textDark,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

