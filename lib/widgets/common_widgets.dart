import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../pages/search_page.dart';
import '../theme/app_colors.dart';

/// Logo Campy dari assets/images/logo.png (PNG transparan warna krem).
/// Parameter [color] mewarnai ulang logo: krem di start page,
/// hijau di login/signup. Isi null kalau mau warna asli gambar.
class CampyLogo extends StatelessWidget {
  final Color? color;
  final double size;
  const CampyLogo({super.key, this.color = AppColors.cream, this.size = 64});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/logo.png',
      width: size * 2.6,
      fit: BoxFit.contain,
      color: color,
      colorBlendMode: BlendMode.srcIn,
    );
  }
}

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  const PrimaryButton({super.key, required this.text, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600)),
      ),
    );
  }
}

class OutlineButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  const OutlineButton({super.key, required this.text, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600)),
      ),
    );
  }
}

class AppTextField extends StatefulWidget {
  final String label;
  final String hint;
  final TextEditingController? controller;
  final bool isPassword;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final List<TextInputFormatter>? inputFormatters;
  final IconData? trailingIcon;

  const AppTextField({
    super.key,
    required this.label,
    this.hint = '',
    this.controller,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.inputFormatters,
    this.trailingIcon,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label,
            style: const TextStyle(fontSize: 12, color: AppColors.textGrey)),
        const SizedBox(height: 6),
        TextFormField(
          controller: widget.controller,
          obscureText: widget.isPassword && _obscure,
          keyboardType: widget.keyboardType,
          validator: widget.validator,
          inputFormatters: widget.inputFormatters,
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(
            hintText: widget.hint,
            filled: true,
            fillColor: AppColors.fieldBg,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            suffixIcon: widget.isPassword
                ? IconButton(
                    icon: Icon(
                        _obscure ? Icons.visibility_off : Icons.visibility,
                        size: 18),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  )
                : (widget.trailingIcon != null
                    ? Icon(widget.trailingIcon,
                        size: 18, color: AppColors.textGrey)
                    : null),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.primary),
            ),
          ),
        ),
      ],
    );
  }
}

class SearchField extends StatelessWidget {
  final String hint;
  final ValueChanged<String>? onChanged;
  final bool? readOnly;
  final VoidCallback? onTap;

  const SearchField({
    super.key,
    this.hint = 'Search products...',
    this.onChanged,
    this.readOnly,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isReadOnly = readOnly ?? (onChanged == null);

    if (isReadOnly) {
      return InkWell(
        onTap: onTap ??
            () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SearchPage()),
              );
            },
        borderRadius: BorderRadius.circular(8),
        child: IgnorePointer(
          ignoring: true,
          child: TextField(
            readOnly: true,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle:
                  const TextStyle(fontSize: 12, color: AppColors.muted),
              prefixIcon: const Icon(Icons.search, size: 20),
              filled: true,
              fillColor: AppColors.fieldBg,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
      );
    }

    return TextField(
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 12, color: AppColors.muted),
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: AppColors.fieldBg,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class ProductImage extends StatelessWidget {
  final String? asset;
  final IconData fallback;
  final double size;

  const ProductImage({
    super.key,
    this.asset,
    required this.fallback,
    this.size = 64,
  });

  @override
  Widget build(BuildContext context) {
    if (asset != null && asset!.isNotEmpty) {
      return Image.asset(
        asset!,
        width: size,
        height: size,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) {
          return Icon(fallback, size: size);
        },
      );
    }

    return Icon(
      fallback,
      size: size,
      color: AppColors.primary,
    );
  }
}
