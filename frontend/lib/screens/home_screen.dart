import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../constants/theme.dart';
import '../providers/auth_provider.dart';
import '../providers/material_provider.dart';
import '../widgets/material_card.dart';
import '../widgets/subject_chip.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MaterialProvider>().fetchMaterials(refresh: true);
    });
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        context.read<MaterialProvider>().loadMore();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final materialProvider = context.watch<MaterialProvider>();
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hello, ${authProvider.user?.fullName.split(' ').first ?? 'Student'} 👋',
                        style: GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 4),
                      ShaderMask(
                        shaderCallback: (bounds) => AppColors.primaryGradient.createShader(bounds),
                        child: Text(
                          'StudyHive',
                          style: GoogleFonts.poppins(
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Logo PNG in top right
                  Image.asset(
                    'assets/images/logo.png',
                    width: 70,
                    height: 44,
                    fit: BoxFit.contain,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceCard,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(color: AppColors.textPrimary, fontSize: 15),
                  decoration: InputDecoration(
                    hintText: 'Search study materials...',
                    hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 15),
                    prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textHint, size: 22),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.close_rounded, color: AppColors.textHint, size: 20),
                            onPressed: () {
                              _searchController.clear();
                              materialProvider.setSearchQuery('');
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                  onChanged: (value) {
                    setState(() {});
                    materialProvider.setSearchQuery(value);
                  },
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Subject chips
            SizedBox(
              height: 44,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: materialProvider.subjects.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final subject = materialProvider.subjects[index];
                  final isSelected = (materialProvider.selectedSubject ?? 'All') == subject;
                  return SubjectChip(
                    label: subject,
                    isSelected: isSelected,
                    onTap: () => materialProvider.setSubjectFilter(subject == 'All' ? null : subject),
                  );
                },
              ),
            ),

            const SizedBox(height: 12),

            // Materials list
            Expanded(
              child: materialProvider.isLoading && materialProvider.materials.isEmpty
                  ? const Center(child: CircularProgressIndicator(color: AppColors.gradientStart))
                  : materialProvider.materials.isEmpty
                      ? _buildEmptyState()
                      : RefreshIndicator(
                          color: AppColors.gradientStart,
                          backgroundColor: AppColors.surfaceCard,
                          onRefresh: () => materialProvider.fetchMaterials(refresh: true),
                          child: ListView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.only(top: 4, bottom: 100),
                            itemCount: materialProvider.materials.length + (materialProvider.hasMore ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (index >= materialProvider.materials.length) {
                                return const Padding(
                                  padding: EdgeInsets.all(20),
                                  child: Center(child: CircularProgressIndicator(color: AppColors.gradientStart, strokeWidth: 2)),
                                );
                              }
                              final material = materialProvider.materials[index];
                              return MaterialCard(
                                material: material,
                                onTap: () => context.push('/material/${material.id}'),
                              );
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(color: AppColors.surfaceElevated, borderRadius: BorderRadius.circular(20)),
            child: const Icon(Icons.search_off_rounded, color: AppColors.textHint, size: 40),
          ),
          const SizedBox(height: 16),
          Text('No materials found', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          const SizedBox(height: 8),
          Text('Try a different search or filter', style: GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}