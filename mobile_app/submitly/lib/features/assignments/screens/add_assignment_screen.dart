import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../subjects/services/subject_service.dart';
import '../../subjects/models/subject_model.dart';
import '../services/assignment_service.dart';
import '../../../core/theme/app_theme.dart';

class AddAssignmentScreen extends StatefulWidget {
  const AddAssignmentScreen({super.key});

  @override
  State<AddAssignmentScreen> createState() => _AddAssignmentScreenState();
}

class _AddAssignmentScreenState extends State<AddAssignmentScreen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  final AssignmentService _assignmentService = AssignmentService();
  final SubjectService _subjectService = SubjectService();

  List<Subject> subjects = [];
  String? selectedSubjectId;
  DateTime selectedDate = DateTime.now().add(const Duration(days: 1));
  bool _loadingSubjects = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadSubjects();
  }

  Future<void> _loadSubjects() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');

      if (userId != null) {
        final data = await _subjectService.getSubjects(userId);
        setState(() {
          subjects = data;
          if (subjects.isNotEmpty) {
            selectedSubjectId = subjects.first.id;
          }
          _loadingSubjects = false;
        });
      } else {
        setState(() => _loadingSubjects = false);
      }
    } catch (e) {
      setState(() => _loadingSubjects = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to load subjects: $e')));
      }
    }
  }

  Future<void> _saveAssignment() async {
    if (!_formKey.currentState!.validate()) return;

    final title = _titleController.text.trim();
    if (selectedSubjectId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a subject')));
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');

    if (userId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No user session found. Please log in again.'),
          ),
        );
      }
      return;
    }

    setState(() => _saving = true);

    try {
      await _assignmentService.createAssignment(
        title: title,
        description: _descController.text.trim(),
        dueDate: selectedDate,
        userId: userId,
        subjectId: selectedSubjectId!,
      );

      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      setState(() => _saving = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to save: $e')));
      }
    }
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(
              context,
            ).colorScheme.copyWith(primary: AppColors.primary),
          ),
          child: child!,
        );
      },
    );

    if (date != null) {
      setState(() => selectedDate = date);
    }
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Assignment'),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _loadingSubjects
          ? const Center(child: CircularProgressIndicator())
          : subjects.isEmpty
          ? _buildNoSubjectsState()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    const Text(
                      'Title',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _titleController,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration(
                        hintText: 'e.g. Chapter 5 Homework',
                        prefixIcon: Icon(Icons.title_rounded),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a title';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Description
                    const Text(
                      'Description (optional)',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _descController,
                      maxLines: 3,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration(
                        hintText: 'Add some details...',
                        prefixIcon: Padding(
                          padding: EdgeInsets.only(bottom: 48),
                          child: Icon(Icons.notes_rounded),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Subject
                    const Text(
                      'Subject',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      initialValue: selectedSubjectId,
                      items: subjects.map((s) {
                        return DropdownMenuItem<String>(
                          value: s.id,
                          child: Text(s.name),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => selectedSubjectId = value);
                      },
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.menu_book_rounded),
                      ),
                      dropdownColor: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    const SizedBox(height: 24),

                    // Due Date
                    const Text(
                      'Due Date',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: _pickDate,
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.calendar_today_rounded,
                              color: AppColors.textSecondary,
                              size: 22,
                            ),
                            const SizedBox(width: 14),
                            Text(
                              _formatDate(selectedDate),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const Spacer(),
                            Icon(
                              Icons.edit_calendar_rounded,
                              color: AppColors.primary.withValues(alpha: 0.6),
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: _saving ? null : _saveAssignment,
                        child: _saving
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Save Assignment'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildNoSubjectsState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.info_outline_rounded,
                size: 48,
                color: AppColors.warning.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'No subjects found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Add a subject first before\ncreating an assignment.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back_rounded),
              label: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }
}
