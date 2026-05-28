import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:open_file/open_file.dart';
import '../constants/theme.dart';
import '../providers/bookmark_provider.dart';
import '../providers/material_provider.dart';
import '../providers/rating_provider.dart';
import '../services/material_service.dart';
import '../widgets/gradient_button.dart';
import '../providers/profile_provider.dart';

class MaterialDetailScreen extends StatefulWidget {
  final int materialId;
  const MaterialDetailScreen({super.key, required this.materialId});

  @override
  State<MaterialDetailScreen> createState() => _MaterialDetailScreenState();
}

class _MaterialDetailScreenState extends State<MaterialDetailScreen> {
  bool _isDownloading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MaterialProvider>().fetchMaterialById(widget.materialId);
      context.read<RatingProvider>().fetchRatings(widget.materialId);
    });
  }

  Future<void> _downloadFile() async {
    final material = context.read<MaterialProvider>().selectedMaterial;
    setState(() => _isDownloading = true);
    try {
      final materialService = MaterialService();
      final response = await materialService.downloadMaterial(widget.materialId);
      final dir = await getApplicationDocumentsDirectory();
      final ext = material?.fileType?.toLowerCase() ??
          (material?.filePath != null ? material!.filePath!.split('.').last.toLowerCase() : 'pdf');
      final safeName = (material?.title ?? 'download')
          .replaceAll(RegExp(r'[^\w\s]'), '').trim().replaceAll(' ', '_');
      final fileName = '${safeName}_${widget.materialId}.$ext';
      final filePath = '${dir.path}/$fileName';
      final file = File(filePath);
      await file.writeAsBytes(response.data as List<int>);
      await context.read<ProfileProvider>().fetchMyDownloads();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Downloaded: $fileName'),
        backgroundColor: AppColors.success,
        action: SnackBarAction(label: 'Open', textColor: Colors.white, onPressed: () => OpenFile.open(filePath)),
      ));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Download failed: $e'), backgroundColor: AppColors.error),
      );
    } finally {
      if (mounted) setState(() => _isDownloading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final materialProvider = context.watch<MaterialProvider>();
    final ratingProvider = context.watch<RatingProvider>();
    final bookmarkProvider = context.watch<BookmarkProvider>();
    final material = materialProvider.selectedMaterial;

    if (materialProvider.isLoading || material == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(backgroundColor: Colors.transparent),
        body: const Center(child: CircularProgressIndicator(color: AppColors.gradientStart)),
      );
    }

    final isBookmarked = bookmarkProvider.isMaterialBookmarked(material.id);
    final displayRating = ratingProvider.ratings.isNotEmpty ? ratingProvider.averageRating : material.averageRating;
    final ratingCount = ratingProvider.ratings.isNotEmpty ? ratingProvider.ratings.length : material.totalRatings;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: AppColors.background,
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.arrow_back_rounded, color: Colors.white),
              ),
            ),
            actions: [
              GestureDetector(
                onTap: () => bookmarkProvider.toggleBookmark(material.id),
                child: Container(
                  margin: const EdgeInsets.all(8),
                  width: 42, height: 42,
                  decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(12)),
                  child: Icon(
                    isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                    color: isBookmarked ? AppColors.gradientStart : Colors.white,
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.gradientStart, AppColors.gradientEnd],
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      Container(
                        width: 70, height: 70,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Icon(_getFileIcon(material.fileExtension), color: Colors.white, size: 36),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          material.fileExtension.isNotEmpty ? material.fileExtension : 'FILE',
                          style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(material.title,
                      style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                  const SizedBox(height: 12),

                  Wrap(
                    spacing: 8, runSpacing: 8,
                    children: [
                      _InfoBadge(icon: Icons.subject_rounded, label: material.subject, gradient: AppColors.primaryGradient),
                      if (material.course != null && material.course!.isNotEmpty)
                        _InfoBadge(icon: Icons.school_rounded, label: material.course!, gradient: AppColors.primaryGradient),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Rating
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceCard,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.surfaceElevated, width: 1),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.star_rounded, color: AppColors.gradientStart, size: 22),
                            const SizedBox(width: 8),
                            Text('Rating', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                            const Spacer(),
                            Text('${displayRating.toStringAsFixed(1)} / 5.0',
                                style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.gradientStart)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Center(
                          child: Consumer<RatingProvider>(
                            builder: (context, ratingProvider, _) {
                              return RatingBar.builder(
                                initialRating: displayRating,
                                minRating: 1,
                                direction: Axis.horizontal,
                                allowHalfRating: false,
                                itemCount: 5,
                                itemSize: 36,
                                unratedColor: AppColors.surfaceElevated,
                                itemBuilder: (context, _) => const Icon(Icons.star_rounded, color: AppColors.gradientStart),
                                onRatingUpdate: (rating) async {
                                  final messenger = ScaffoldMessenger.of(context);
                                  final success = await ratingProvider.submitRating(material.id, rating.toInt());
                                  if (!mounted) return;
                                  messenger.showSnackBar(SnackBar(
                                    content: Text(success ? 'Rating submitted!' : 'Failed to submit rating'),
                                    backgroundColor: success ? AppColors.success : AppColors.error,
                                  ));
                                },
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 8),
                        Center(child: Text('$ratingCount ratings', style: GoogleFonts.inter(fontSize: 12, color: AppColors.textHint))),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  Text('Description', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                  const SizedBox(height: 8),
                  Text(material.description, style: GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondary, height: 1.6)),
                  const SizedBox(height: 20),

                  if (material.tagList.isNotEmpty) ...[
                    Text('Tags', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8, runSpacing: 8,
                      children: material.tagList.map((tag) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(color: AppColors.surfaceElevated, borderRadius: BorderRadius.circular(8)),
                        child: Text('#$tag', style: GoogleFonts.inter(fontSize: 12, color: AppColors.gradientEnd, fontWeight: FontWeight.w500)),
                      )).toList(),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Upload info
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceCard,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.surfaceElevated, width: 1),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 44, height: 44,
                          decoration: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(12)),
                          child: const Icon(Icons.person_rounded, color: Colors.white, size: 22),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(material.uploaderName ?? 'Unknown',
                                  style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                              if (material.uploadedAt != null)
                                Text('Uploaded ${_formatDate(material.uploadedAt!)}',
                                    style: GoogleFonts.inter(fontSize: 12, color: AppColors.textHint)),
                            ],
                          ),
                        ),
                        Column(
                          children: [
                            const Icon(Icons.download_rounded, color: AppColors.textHint, size: 18),
                            const SizedBox(height: 2),
                            Text('${material.downloadCount}', style: GoogleFonts.inter(fontSize: 12, color: AppColors.textHint)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  GradientButton(
                    text: _isDownloading ? 'Downloading...' : 'Download Material',
                    isLoading: _isDownloading,
                    onPressed: _isDownloading ? null : _downloadFile,
                    icon: Icons.download_rounded,
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getFileIcon(String ext) {
    switch (ext.toLowerCase()) {
      case 'pdf': return Icons.picture_as_pdf_rounded;
      case 'doc': case 'docx': return Icons.description_rounded;
      case 'ppt': case 'pptx': return Icons.slideshow_rounded;
      case 'jpg': case 'jpeg': case 'png': return Icons.image_rounded;
      default: return Icons.insert_drive_file_rounded;
    }
  }

  String _formatDate(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays > 30) return '${date.day}/${date.month}/${date.year}';
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    return 'Just now';
  }
}

class _InfoBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final LinearGradient gradient;

  const _InfoBadge({required this.icon, required this.label, required this.gradient});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(gradient: gradient, borderRadius: BorderRadius.circular(8)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 14),
          const SizedBox(width: 6),
          Text(label, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white)),
        ],
      ),
    );
  }
}