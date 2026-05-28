import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../constants/theme.dart';
import '../providers/auth_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _textOpacity;
  late Animation<Offset> _textSlide;

  @override
  void initState() {
    super.initState();
    _logoController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _textController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));

    _logoScale = Tween<double>(begin: 0.5, end: 1.0)
        .animate(CurvedAnimation(parent: _logoController, curve: Curves.elasticOut));
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _logoController, curve: const Interval(0.0, 0.5, curve: Curves.easeIn)));
    _textOpacity = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _textController, curve: Curves.easeIn));
    _textSlide = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(CurvedAnimation(parent: _textController, curve: Curves.easeOut));

    _startAnimation();
  }

  void _startAnimation() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _logoController.forward();
    await Future.delayed(const Duration(milliseconds: 600));
    _textController.forward();
    await Future.delayed(const Duration(milliseconds: 1200));
    _navigateNext();
  }

  void _navigateNext() async {
    if (!mounted) return;
    final authProvider = context.read<AuthProvider>();
    final isLoggedIn = await authProvider.tryAutoLogin();
    if (!mounted) return;
    if (isLoggedIn) {
      context.go('/home');
    } else {
      context.go('/login');
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo PNG animated
            AnimatedBuilder(
              animation: _logoController,
              builder: (context, child) {
                return Opacity(
                  opacity: _logoOpacity.value,
                  child: Transform.scale(
                    scale: _logoScale.value,
                    child: Image.asset(
                      'assets/images/logo.png',
                      width: 200,
                      height: 130,
                      fit: BoxFit.contain,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),

            // Tagline
            SlideTransition(
              position: _textSlide,
              child: FadeTransition(
                opacity: _textOpacity,
                child: Text(
                  'Share. Learn. Grow.',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textSecondary,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}