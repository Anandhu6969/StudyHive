import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../constants/theme.dart';
import '../models/material_item.dart';
import '../providers/auth_provider.dart';
import '../providers/profile_provider.dart';
import '../widgets/gradient_button.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileProvider>().fetchAll();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final profileProvider = context.watch<ProfileProvider>();
    final user = authProvider.user;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),

            // Avatar
            Container(
              width: 90, height: 90,
              decoration: BoxDecoration(
                gradient: AppColors.avatarGradient,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  (user?.fullName.isNotEmpty == true) ? user!.fullName[0].toUpperCase() : '?',
                  style: GoogleFonts.poppins(fontSize: 36, fontWeight: FontWeight.w700, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 16),

            Text(user?.fullName ?? 'User',
                style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            const SizedBox(height: 4),
            Text(user?.email ?? '',
                style: GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondary)),
            const SizedBox(height: 20),

            // Stats
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _StatItem(label: 'Uploads', value: '${profileProvider.myUploads.length}', icon: Icons.upload_file_rounded),
                Container(width: 1, height: 30, margin: const EdgeInsets.symmetric(horizontal: 24), color: AppColors.surfaceElevated),
                _StatItem(label: 'Downloads', value: '${profileProvider.myDownloads.length}', icon: Icons.download_rounded),
              ],
            ),
            const SizedBox(height: 20),

            // Tab bar
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(color: AppColors.surfaceCard, borderRadius: BorderRadius.circular(12)),
              child: TabBar(
                controller: _tabController,
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                indicator: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                labelColor: Colors.white,
                unselectedLabelColor: AppColors.textHint,
                labelStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
                tabs: const [Tab(text: 'My Uploads'), Tab(text: 'My Downloads')],
              ),
            ),
            const SizedBox(height: 12),

            // Tab views
            Expanded(
              child: profileProvider.isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.gradientStart))
                  : TabBarView(
                      controller: _tabController,
                      children: [
                        _MaterialListTab(
                          materials: profileProvider.myUploads,
                          emptyIcon: Icons.upload_file_rounded,
                          emptyMessage: 'No uploads yet',
                          isUploads: true,
                          onDelete: (materialId) async {
                            final confirmed = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                backgroundColor: AppColors.surfaceCard,
                                title: Text('Delete Material',
                                    style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                                content: Text('Are you sure you want to delete this material? This action cannot be undone.',
                                    style: GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondary)),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(false),
                                    child: Text('Cancel', style: GoogleFonts.inter(color: AppColors.textSecondary)),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(true),
                                    child: Text('Delete', style: GoogleFonts.inter(color: AppColors.error, fontWeight: FontWeight.w600)),
                                  ),
                                ],
                              ),
                            );
                            if (confirmed != true) return;
                            if (!mounted) return;
                            final success = await profileProvider.deleteMaterial(materialId);
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(success ? 'Material deleted successfully' : 'Failed to delete material'),
                              backgroundColor: success ? AppColors.success : AppColors.error,
                            ));
                          },
                        ),
                        _MaterialListTab(
                          materials: profileProvider.myDownloads,
                          emptyIcon: Icons.download_rounded,
                          emptyMessage: 'No downloads yet',
                        ),
                      ],
                    ),
            ),

            // Logout button — red
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: GradientButton(
                text: 'Logout',
                icon: Icons.logout_rounded,
                gradient: const LinearGradient(colors: [Color(0xFFEF5350), Color(0xFFFF5252)]),
                onPressed: () async {
                  await authProvider.logout();
                  if (!context.mounted) return;
                  context.go('/login');
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatItem({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: AppColors.gradientStart, size: 22),
        const SizedBox(height: 4),
        Text(value, style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        Text(label, style: GoogleFonts.inter(fontSize: 12, color: AppColors.textHint)),
      ],
    );
  }
}

class _MaterialListTab extends StatelessWidget {
  final List<MaterialItem> materials;
  final IconData emptyIcon;
  final String emptyMessage;
  final bool isUploads;
  final Future<void> Function(int)? onDelete;

  const _MaterialListTab({
    required this.materials,
    required this.emptyIcon,
    required this.emptyMessage,
    this.isUploads = false,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (materials.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 60, height: 60,
              decoration: BoxDecoration(color: AppColors.surfaceElevated, borderRadius: BorderRadius.circular(16)),
              child: Icon(emptyIcon, color: AppColors.textHint, size: 30),
            ),
            const SizedBox(height: 12),
            Text(emptyMessage, style: GoogleFonts.inter(fontSize: 14, color: AppColors.textHint)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      itemCount: materials.length,
      itemBuilder: (context, index) {
        final m = materials[index];
        return GestureDetector(
          onTap: () => context.push('/material/${m.id}'),
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surfaceCard,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.gradientStart.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.insert_drive_file_rounded, color: AppColors.gradientStart, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        m.title.isNotEmpty ? m.title : 'Untitled Material',
                        style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600,
                            color: m.title.isNotEmpty ? AppColors.textPrimary : AppColors.textHint),
                        maxLines: 1, overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(m.subject.isNotEmpty ? m.subject : 'No subject',
                          style: GoogleFonts.inter(fontSize: 12, color: AppColors.textHint)),
                    ],
                  ),
                ),
                if (isUploads && onDelete != null)
                  GestureDetector(
                    onTap: () => onDelete!(m.id),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Icon(Icons.delete_rounded, color: AppColors.textHint, size: 20),
                    ),
                  )
                else
                  const Icon(Icons.chevron_right_rounded, color: AppColors.textHint, size: 22),
              ],
            ),
          ),
        );
      },
    );
  }
}