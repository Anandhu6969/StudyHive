import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../constants/theme.dart';
import '../providers/auth_provider.dart';

class ScaffoldWithNavBar extends StatelessWidget {
  final Widget child;

  const ScaffoldWithNavBar({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final isUploader = authProvider.isUploader;

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.background,
          border: Border(
            top: BorderSide(color: Color(0xFF1A1A1A), width: 1),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(
                  icon: Icons.home_rounded,
                  label: 'Home',
                  isSelected: _currentIndex(context) == 0,
                  onTap: () => context.go('/home'),
                ),
                _NavItem(
                  icon: Icons.bookmark_rounded,
                  label: 'Bookmarks',
                  isSelected: _currentIndex(context) == 1,
                  onTap: () => context.go('/bookmarks'),
                ),
                if (isUploader)
                  _NavItem(
                    icon: Icons.cloud_upload_rounded,
                    label: 'Upload',
                    isSelected: _currentIndex(context) == 2,
                    onTap: () => context.go('/upload'),
                  ),
                _NavItem(
                  icon: Icons.person_rounded,
                  label: 'Profile',
                  isSelected: _currentIndex(context) == (isUploader ? 3 : 2),
                  onTap: () => context.go('/profile'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/home')) return 0;
    if (location.startsWith('/bookmarks')) return 1;
    if (location.startsWith('/upload')) return 2;
    if (location.startsWith('/profile')) {
      final isUploader = context.read<AuthProvider>().isUploader;
      return isUploader ? 3 : 2;
    }
    return 0;
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF00CCFF) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : AppColors.textHint,
              size: 24,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.textHint,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}