import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../constants/theme.dart';
import '../providers/material_provider.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/gradient_button.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _courseController = TextEditingController();
  final _tagsController = TextEditingController();
  final _customSubjectController = TextEditingController();
  String? _selectedSubject;
  PlatformFile? _selectedFile;

  final List<String> _subjects = [
    'Mathematics','Physics','Chemistry','Biology','Computer Science',
    'English','History','Geography','Economics','Psychology',
    'Engineering','Medicine','Law','Business','Art','Music','Other',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _courseController.dispose();
    _tagsController.dispose();
    _customSubjectController.dispose();
    super.dispose();
  }

  String get _subjectToUpload {
    if (_selectedSubject == 'Other') return _customSubjectController.text.trim();
    return _selectedSubject?.trim() ?? '';
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf','doc','docx','ppt','pptx','jpg','jpeg','png'],
      withData: true,
    );
    if (result != null && result.files.isNotEmpty) {
      setState(() => _selectedFile = result.files.first);
    }
  }

  Future<void> _upload() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a file to upload'), backgroundColor: AppColors.error),
      );
      return;
    }
    final materialProvider = context.read<MaterialProvider>();
    final success = await materialProvider.uploadMaterial(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      subject: _subjectToUpload,
      course: _courseController.text.trim(),
      tags: _tagsController.text.trim(),
      file: _selectedFile!,
    );
    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Material uploaded successfully!'), backgroundColor: AppColors.success),
      );
      _formKey.currentState!.reset();
      _titleController.clear(); _descriptionController.clear();
      _courseController.clear(); _tagsController.clear(); _customSubjectController.clear();
      setState(() { _selectedFile = null; _selectedSubject = null; });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(materialProvider.error ?? 'Upload failed'), backgroundColor: AppColors.error),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final materialProvider = context.watch<MaterialProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                // Header
                ShaderMask(
                  shaderCallback: (bounds) => AppColors.primaryGradient.createShader(bounds),
                  child: Text('Upload Material',
                      style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.w700, color: Colors.white)),
                ),
                const SizedBox(height: 4),
                Text('Share your study materials with the community',
                    style: GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondary)),
                const SizedBox(height: 28),

                // File picker
                GestureDetector(
                  onTap: _pickFile,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: double.infinity,
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceCard,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _selectedFile != null ? AppColors.success : AppColors.surfaceElevated,
                        width: 2,
                      ),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 60, height: 60,
                          decoration: BoxDecoration(
                            gradient: _selectedFile != null
                                ? const LinearGradient(colors: [AppColors.success, Color(0xFF00C853)])
                                : AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            _selectedFile != null ? Icons.check_circle_rounded : Icons.cloud_upload_rounded,
                            color: Colors.white, size: 30,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _selectedFile != null ? _selectedFile!.name : 'Tap to select a file',
                          style: GoogleFonts.inter(
                            fontSize: 14, fontWeight: FontWeight.w600,
                            color: _selectedFile != null ? AppColors.success : AppColors.textPrimary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _selectedFile != null
                              ? '${(_selectedFile!.size / 1024 / 1024).toStringAsFixed(2)} MB'
                              : 'PDF, DOC, PPT, JPG, PNG',
                          style: GoogleFonts.inter(fontSize: 12, color: AppColors.textHint),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                CustomTextField(controller: _titleController, hintText: 'Material title', prefixIcon: Icons.title_rounded,
                    validator: (v) => v == null || v.trim().isEmpty ? 'Please enter a title' : null),
                const SizedBox(height: 14),
                CustomTextField(controller: _descriptionController, hintText: 'Description',
                    prefixIcon: Icons.description_rounded, maxLines: 3,
                    validator: (v) => v == null || v.trim().isEmpty ? 'Please enter a description' : null),
                const SizedBox(height: 14),

                // Subject dropdown
                DropdownButtonFormField<String>(
                  value: _selectedSubject,
                  isExpanded: true,
                  hint: const Text('Select a subject'),
                  dropdownColor: AppColors.surfaceCard,
                  icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textHint),
                  style: const TextStyle(color: AppColors.textPrimary, fontSize: 15),
                  decoration: const InputDecoration(prefixIcon: Icon(Icons.subject_rounded)),
                  items: _subjects.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                  validator: (v) => v == null || v.isEmpty ? 'Please select a subject' : null,
                  onChanged: (value) {
                    setState(() {
                      _selectedSubject = value;
                      if (value != 'Other') _customSubjectController.clear();
                    });
                  },
                ),
                const SizedBox(height: 14),

                if (_selectedSubject == 'Other') ...[
                  CustomTextField(controller: _customSubjectController, hintText: 'Enter custom subject name',
                      prefixIcon: Icons.label_rounded,
                      validator: (v) => _selectedSubject == 'Other' && (v == null || v.trim().isEmpty)
                          ? 'Please enter a custom subject' : null),
                  const SizedBox(height: 14),
                ],

                CustomTextField(controller: _courseController, hintText: 'Course (optional)', prefixIcon: Icons.school_rounded),
                const SizedBox(height: 14),
                CustomTextField(controller: _tagsController, hintText: 'Tags (comma separated)', prefixIcon: Icons.tag_rounded),
                const SizedBox(height: 28),

                GradientButton(
                  text: 'Upload Material',
                  isLoading: materialProvider.isUploading,
                  onPressed: materialProvider.isUploading ? null : _upload,
                  icon: Icons.cloud_upload_rounded,
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}