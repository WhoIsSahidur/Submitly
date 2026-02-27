import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/assignment_model.dart';
import '../services/assignment_service.dart';
import 'add_assignment_screen.dart';
import '../../../core/theme/app_theme.dart';

class AssignmentListScreen extends StatefulWidget {
  const AssignmentListScreen({super.key});

  @override
  State<AssignmentListScreen> createState() => _AssignmentListScreenState();
}

class _AssignmentListScreenState extends State<AssignmentListScreen>
    with SingleTickerProviderStateMixin {
  final AssignmentService _service = AssignmentService();
  List<Assignment> assignments = [];
  bool isLoading = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    loadAssignments();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> loadAssignments() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');

    if (userId != null) {
      try {
        final data = await _service.getAssignments(userId);
        setState(() {
          assignments = data;
          isLoading = false;
        });
      } catch (e) {
        setState(() => isLoading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to load assignments: $e')),
          );
        }
      }
    } else {
      setState(() => isLoading = false);
    }
  }

  void markSubmitted(String id) async {
    await _service.updateStatus(id, "submitted");
    loadAssignments();
  }

  @override
  Widget build(BuildContext context) {
    final pending = assignments.where((a) => a.status == "pending").toList()
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
    final submitted = assignments
        .where((a) => a.status == "submitted")
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Assignments'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          indicatorSize: TabBarIndicatorSize.label,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
          tabs: [
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Pending'),
                  if (pending.isNotEmpty) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${pending.length}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.warning,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Submitted'),
                  if (submitted.isNotEmpty) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${submitted.length}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.success,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddAssignmentScreen()),
          );
          loadAssignments();
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Task'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                // Pending tab
                pending.isEmpty
                    ? _buildEmptyState(
                        Icons.task_alt_rounded,
                        'No pending tasks',
                        'All assignments have been submitted!',
                      )
                    : RefreshIndicator(
                        onRefresh: loadAssignments,
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
                          itemCount: pending.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _buildAssignmentCard(
                                pending[index],
                                showAction: true,
                              ),
                            );
                          },
                        ),
                      ),

                // Submitted tab
                submitted.isEmpty
                    ? _buildEmptyState(
                        Icons.inbox_rounded,
                        'No submitted tasks',
                        'Submit your first assignment!',
                      )
                    : RefreshIndicator(
                        onRefresh: loadAssignments,
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
                          itemCount: submitted.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _buildAssignmentCard(
                                submitted[index],
                                showAction: false,
                              ),
                            );
                          },
                        ),
                      ),
              ],
            ),
    );
  }

  Widget _buildAssignmentCard(
    Assignment assignment, {
    required bool showAction,
  }) {
    final daysLeft = assignment.dueDate.difference(DateTime.now()).inDays;
    final isUrgent = daysLeft <= 2 && assignment.status == "pending";
    final isOverdue = daysLeft < 0 && assignment.status == "pending";

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isOverdue
            ? Border.all(color: AppColors.error.withValues(alpha: 0.3))
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status icon
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: assignment.status == "submitted"
                      ? AppColors.success.withValues(alpha: 0.12)
                      : isOverdue
                      ? AppColors.error.withValues(alpha: 0.12)
                      : isUrgent
                      ? AppColors.warning.withValues(alpha: 0.12)
                      : AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  assignment.status == "submitted"
                      ? Icons.check_circle_rounded
                      : isOverdue
                      ? Icons.error_rounded
                      : Icons.assignment_rounded,
                  size: 22,
                  color: assignment.status == "submitted"
                      ? AppColors.success
                      : isOverdue
                      ? AppColors.error
                      : isUrgent
                      ? AppColors.warning
                      : AppColors.primary,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      assignment.title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                        decoration: assignment.status == "submitted"
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      assignment.subjectName,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Bottom row: date + action
          Row(
            children: [
              // Due date
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: isOverdue
                      ? AppColors.error.withValues(alpha: 0.1)
                      : isUrgent
                      ? AppColors.warning.withValues(alpha: 0.1)
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.schedule_rounded,
                      size: 14,
                      color: isOverdue
                          ? AppColors.error
                          : isUrgent
                          ? AppColors.warning
                          : AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isOverdue
                          ? 'Overdue'
                          : daysLeft == 0
                          ? 'Due today'
                          : daysLeft == 1
                          ? 'Due tomorrow'
                          : 'Due in $daysLeft days',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isOverdue
                            ? AppColors.error
                            : isUrgent
                            ? AppColors.warning
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              // Action
              if (showAction && assignment.status == "pending")
                TextButton.icon(
                  onPressed: () => markSubmitted(assignment.id),
                  icon: const Icon(Icons.check_rounded, size: 18),
                  label: const Text('Mark Done'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.success,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    textStyle: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              if (assignment.status == "submitted")
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle_outline_rounded,
                        size: 14,
                        color: AppColors.success,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Submitted',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(IconData icon, String title, String subtitle) {
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
                icon,
                size: 48,
                color: AppColors.primary.withValues(alpha: 0.4),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
