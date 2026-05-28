import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../constants/theme.dart';
import '../providers/auth_provider.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/gradient_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  late AnimationController _animController;
  late Animation<double> _fadeIn;
  late Animation<Offset> _slideUp;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _fadeIn = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _slideUp = Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero)
        .animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.register(
      fullName: _fullNameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      role: 'Student',
    );
    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registration successful! Please login.'), backgroundColor: AppColors.success),
      );
      context.go('/login');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(authProvider.error ?? 'Registration failed'), backgroundColor: AppColors.error),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: FadeTransition(
            opacity: _fadeIn,
            child: SlideTransition(
              position: _slideUp,
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 40),

                    // Back button
                    GestureDetector(
                      onTap: () => context.go('/login'),
                      child: Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceCard,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary, size: 22),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Logo centered
                    Center(
                      child: Image.asset(
                        'assets/images/logo.png',
                        width: 140,
                        height: 88,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Create Account - gradient text
                    ShaderMask(
                      shaderCallback: (bounds) => AppColors.primaryGradient.createShader(bounds),
                      child: Text(
                        'Create Account',
                        style: GoogleFonts.poppins(fontSize: 30, fontWeight: FontWeight.w700, color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Join the learning community',
                      style: GoogleFonts.inter(fontSize: 15, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 32),

                    // Full Name
                    CustomTextField(
                      controller: _fullNameController,
                      hintText: 'Full Name',
                      prefixIcon: Icons.person_outline_rounded,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) return 'Please enter your full name';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Email
                    CustomTextField(
                      controller: _emailController,
                      hintText: 'Email address',
                      prefixIcon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) return 'Please enter your email';
                        if (!value.contains('@')) return 'Please enter a valid email';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Password
                    CustomTextField(
                      controller: _passwordController,
                      hintText: 'Password',
                      prefixIcon: Icons.lock_outline_rounded,
                      obscureText: _obscurePassword,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                          color: AppColors.textHint, size: 22,
                        ),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Please enter a password';
                        if (value.length < 6) return 'Password must be at least 6 characters';
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),

                    // Create Account button
                    GradientButton(
                      text: 'Create Account',
                      isLoading: authProvider.isLoading,
                      onPressed: authProvider.isLoading ? null : _register,
                      icon: Icons.person_add_rounded,
                    ),
                    const SizedBox(height: 24),

                    // Sign In link
                    Center(
                      child: GestureDetector(
                        onTap: () => context.go('/login'),
                        child: RichText(
                          text: TextSpan(
                            text: 'Already have an account? ',
                            style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 14),
                            children: [
                              TextSpan(
                                text: 'Sign In',
                                style: GoogleFonts.inter(
                                  color: AppColors.gradientStart,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}