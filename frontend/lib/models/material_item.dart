class MaterialItem {
  final int id;
  final String title;
  final String description;
  final String subject;
  final String? course;
  final String? tags;

  // File info
  final String? fileName;
  final String? filePath;
  final String? fileType;

  // Upload info
  final String? uploadedBy;
  final String? uploaderName;
  final DateTime? uploadedAt;

  // Stats
  final double averageRating;
  final int totalRatings;
  final int downloadCount;

  // Bookmark state
  bool isBookmarked;

  MaterialItem({
    required this.id,
    required this.title,
    required this.description,
    required this.subject,
    this.course,
    this.tags,
    this.fileName,
    this.filePath,
    this.fileType,
    this.uploadedBy,
    this.uploaderName,
    this.uploadedAt,
    this.averageRating = 0.0,
    this.totalRatings = 0,
    this.downloadCount = 0,
    this.isBookmarked = false,
  });

  factory MaterialItem.fromJson(Map<String, dynamic> json) {
    return MaterialItem(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      subject: json['subject'] ?? '',
      course: json['course'],
      tags: json['tags'],

      // File fields
      fileName: json['fileName'],
      filePath: json['filePath'],
      fileType: json['fileType'],

      // Upload info
      uploadedBy: json['uploadedBy'],
      uploaderName: json['uploaderName'] ?? json['uploadedByName'],

      // Date
      uploadedAt: json['uploadedAt'] != null
          ? DateTime.tryParse(json['uploadedAt'])
          : null,

      // Stats
      averageRating: (json['averageRating'] ?? 0).toDouble(),
      totalRatings: json['totalRatings'] ?? 0,
      downloadCount: json['downloadCount'] ?? 0,

      // Bookmark
      isBookmarked: json['isBookmarked'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'subject': subject,
      'course': course,
      'tags': tags,
      'fileName': fileName,
      'filePath': filePath,
      'fileType': fileType,
    };
  }

  List<String> get tagList =>
      tags
          ?.split(',')
          .map((t) => t.trim())
          .where((t) => t.isNotEmpty)
          .toList() ??
      [];

  String get fileExtension {
    // First preference: fileType
    if (fileType != null && fileType!.isNotEmpty) {
      return fileType!.replaceAll('.', '').toUpperCase();
    }

    // Second preference: filePath
    if (filePath != null && filePath!.isNotEmpty) {
      final parts = filePath!.split('.');
      return parts.length > 1 ? parts.last.toUpperCase() : '';
    }

    // Third preference: fileName
    if (fileName != null && fileName!.isNotEmpty) {
      final parts = fileName!.split('.');
      return parts.length > 1 ? parts.last.toUpperCase() : '';
    }

    return '';
  }
}