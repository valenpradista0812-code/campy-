import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/common_widgets.dart';
import 'login_page.dart';
import 'signup_page.dart';

class _OnboardData {
  final String title;
  final String desc;
  final String asset;
  const _OnboardData(this.title, this.desc, this.asset);
}

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  static const Duration _autoSlideInterval = Duration(seconds: 3);

  final PageController _controller = PageController();
  Timer? _timer;
  int _index = 0;

  final List<_OnboardData> _pages = const [
    _OnboardData(
      'Capture Your KTP',
      'We know that catching photos are necessary in your trip, thats why we have built-in camera and gallery feature.',
      'assets/images/onboarding_ktp.png',
    ),
    _OnboardData(
      'Capture Your Memories',
      'We know that catching photos are necessary in your trip, thats why we have built-in camera and gallery feature.',
      'assets/images/onboarding_memories.png',
    ),
    _OnboardData(
      'Track Your Fitness',
      'Fitness is one of the essential thing which is really important to your body and we track it in every second.',
      'assets/images/onboarding_fitness.png',
    ),
    _OnboardData(
      'There Is Much More',
      'We have bunch of other cool features which is super helpful for your next camping trip, so what are you waiting for?',
      'assets/images/onboarding_camping.png',
    ),
  ];

  bool get _isFirst => _index == 0;
  bool get _isLast => _index == _pages.length - 1;

  @override
  void initState() {
    super.initState();
    _startAutoSlide();
  }

  void _startAutoSlide() {
    _timer?.cancel();
    _timer = Timer.periodic(_autoSlideInterval, (_) {
      if (!_controller.hasClients) return;
      final next = (_index + 1) % _pages.length; // loop ke slide pertama
      _controller.animateToPage(
        next,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOut,
      );
    });
  }

  void _stopAutoSlide() => _timer?.cancel();

  // Dipanggil saat user pencet panah: geser manual lalu reset timer
  void _goTo(int page) {
    if (page < 0 || page >= _pages.length) return;
    _controller.animateToPage(
      page,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
    _startAutoSlide();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              // Saat user menyentuh/menggeser, auto-slide berhenti sementara;
              // lanjut lagi setelah jari dilepas.
              child: Listener(
                onPointerDown: (_) => _stopAutoSlide(),
                onPointerUp: (_) => _startAutoSlide(),
                onPointerCancel: (_) => _startAutoSlide(),
                child: PageView.builder(
                  controller: _controller,
                  itemCount: _pages.length,
                  onPageChanged: (i) => setState(() => _index = i),
                  itemBuilder: (_, i) => _OnboardSlide(data: _pages[i]),
                ),
              ),
            ),
            // Tombol panah + indikator
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _ArrowButton(
                    icon: Icons.arrow_back,
                    enabled: !_isFirst,
                    onTap: () => _goTo(_index - 1),
                  ),
                  Row(
                    children: List.generate(_pages.length, (i) {
                      final active = i == _index;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: active ? 18 : 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: active
                              ? AppColors.primary
                              : AppColors.primary.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      );
                    }),
                  ),
                  _ArrowButton(
                    icon: Icons.arrow_forward,
                    enabled: !_isLast,
                    onTap: () => _goTo(_index + 1),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: PrimaryButton(
                text: 'Log In',
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Don't have an Account? ",
                    style: TextStyle(fontSize: 12)),
                GestureDetector(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const SignUpPage()),
                  ),
                  child: const Text('Register',
                      style: TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w700)),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _OnboardSlide extends StatelessWidget {
  final _OnboardData data;
  const _OnboardSlide({required this.data});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 240,
            child: Image.asset(data.asset, fit: BoxFit.contain),
          ),
          const SizedBox(height: 36),
          Text(
            data.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.textDark),
          ),
          const SizedBox(height: 12),
          Text(
            data.desc,
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 12, height: 1.5, color: AppColors.textGrey),
          ),
        ],
      ),
    );
  }
}

class _ArrowButton extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;
  const _ArrowButton(
      {required this.icon, required this.enabled, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.4,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: enabled ? AppColors.primary : AppColors.lightGreen,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon,
              size: 18, color: enabled ? Colors.white : AppColors.primary),
        ),
      ),
    );
  }
}
