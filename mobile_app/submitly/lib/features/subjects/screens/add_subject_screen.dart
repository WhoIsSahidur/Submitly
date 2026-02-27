import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/subject_service.dart';
import '../../../core/theme/app_theme.dart';

class AddSubjectScreen extends StatefulWidget {
  const AddSubjectScreen({super.key});

  @override
  State<AddSubjectScreen> createState() => _AddSubjectScreenState();
}

class _AddSubjectScreenState extends State<AddSubjectScreen> {
  final _nameController = TextEditingController();
  final _semesterController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final SubjectService _service = SubjectService();
  bool _saving = false;
  int _selectedColorIndex = 0;

  Future<void> _saveSubject() async {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();

    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');

    if (userId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No user session. Please log in again.'),
          ),
        );
      }
      return;
    }

    setState(() => _saving = true);

    try {
      final color = AppColors.subjectColors[_selectedColorIndex];
      final hexColor =
          '#${color.r.toInt().toRadixString(16).padLeft(2, '0')}${color.g.toInt().toRadixString(16).padLeft(2, '0')}${color.b.toInt().toRadixString(16).padLeft(2, '0')}';

      await _service.addSubject(
        name: name,
        semester: _semesterController.text.trim(),
        color: hexColor,
        userId: userId,
      );

      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      setState(() => _saving = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to save subject: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Subject'),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Subject icon preview
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.subjectColors[_selectedColorIndex]
                        .withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Icon(
                    Icons.menu_book_rounded,
                    size: 40,
                    color: AppColors.subjectColors[_selectedColorIndex],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Subject Name
              const Text(
                'Subject Name',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  hintText: 'e.g. Mathematics, Physics',
                  prefixIcon: Icon(Icons.subject_rounded),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a subject name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Semester
              const Text(
                'Semester',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _semesterController,
                decoration: const InputDecoration(
                  hintText: 'e.g. Fall 2025, 1st',
                  prefixIcon: Icon(Icons.calendar_today_rounded),
                ),
              ),
              const SizedBox(height: 24),

              // Color Picker
              const Text(
                'Color',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: List.generate(AppColors.subjectColors.length, (
                  index,
                ) {
                  final color = AppColors.subjectColors[index];
                  final isSelected = index == _selectedColorIndex;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedColorIndex = index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: isSelected
                            ? Border.all(color: Colors.white, width: 3)
                            : null,
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: color.withValues(alpha: 0.5),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                ),
                              ]
                            : null,
                      ),
                      child: isSelected
                          ? const Icon(
                              Icons.check_rounded,
                              color: Colors.white,
                              size: 22,
                            )
                          : null,
                    ),
                  );
                }),
              ),
              const SizedBox(height: 40),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _saving ? null : _saveSubject,
                  child: _saving
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Save Subject'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
