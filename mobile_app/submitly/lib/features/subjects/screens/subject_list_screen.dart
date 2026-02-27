import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/subject_model.dart';
import '../services/subject_service.dart';
import 'add_subject_screen.dart';
import '../../../core/theme/app_theme.dart';

class SubjectListScreen extends StatefulWidget {
  const SubjectListScreen({super.key});

  @override
  State<SubjectListScreen> createState() => _SubjectListScreenState();
}

class _SubjectListScreenState extends State<SubjectListScreen> {
  final SubjectService _service = SubjectService();
  List<Subject> subjects = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadSubjects();
  }

  Future<void> loadSubjects() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');

    if (userId != null) {
      try {
        final data = await _service.getSubjects(userId);
        setState(() {
          subjects = data;
          isLoading = false;
        });
      } catch (e) {
        setState(() => isLoading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to load subjects: $e')),
          );
        }
      }
    } else {
      setState(() => isLoading = false);
    }
  }

  void goToAddScreen() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddSubjectScreen()),
    );
    loadSubjects();
  }

  Color _getSubjectColor(int index) {
    return AppColors.subjectColors[index % AppColors.subjectColors.length];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Subjects'),
        actions: [
          if (subjects.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${subjects.length} total',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: goToAddScreen,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Subject'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : subjects.isEmpty
          ? _buildEmptyState()
          : RefreshIndicator(
              onRefresh: loadSubjects,
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
                itemCount: subjects.length,
                itemBuilder: (context, index) {
                  final subject = subjects[index];
                  final color = _getSubjectColor(index);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildSubjectCard(subject, color),
                  );
                },
              ),
            ),
    );
  }

  Widget _buildSubjectCard(Subject subject, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Color indicator
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(Icons.menu_book_rounded, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          // Subject info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subject.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (subject.semester != null && subject.semester!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Semester ${subject.semester}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: color,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // Arrow
          Icon(Icons.chevron_right_rounded, color: Colors.grey.shade300),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.menu_book_rounded,
                size: 56,
                color: AppColors.primary.withValues(alpha: 0.4),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'No subjects yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Add your first subject to start\ntracking assignments',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: goToAddScreen,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add Subject'),
            ),
          ],
        ),
      ),
    );
  }
}
