import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../auth/services/auth_service.dart';
import '../../shared/services/session_service.dart';
import '../auth/login_screen.dart';
import '../subjects/services/subject_service.dart';
import '../assignments/services/assignment_service.dart';
import '../assignments/models/assignment_model.dart';
import '../subjects/models/subject_model.dart';
import '../../core/theme/app_theme.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final SubjectService _subjectService = SubjectService();
  final AssignmentService _assignmentService = AssignmentService();

  List<Subject> subjects = [];
  List<Assignment> assignments = [];
  bool isLoading = true;
  String? _error;
  String _userName = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      isLoading = true;
      _error = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');
      final name = prefs.getString('name') ?? '';

      if (userId != null) {
        final subjectData = await _subjectService.getSubjects(userId);
        final assignmentData = await _assignmentService.getAssignments(userId);

        setState(() {
          subjects = subjectData;
          assignments = assignmentData;
          _userName = name.split(' ').first;
          isLoading = false;
        });
      } else {
        setState(() {
          _error = 'No user session found.';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Connection error: $e';
        isLoading = false;
      });
    }
  }

  Future<void> _signOut() async {
    await SessionService.clear();
    await AuthService().signOut();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  Widget build(BuildContext context) {
    final pendingAssignments = assignments
        .where((a) => a.status == "pending")
        .toList();

    final upcoming = pendingAssignments.where((a) {
      return a.dueDate.isAfter(DateTime.now());
    }).toList()..sort((a, b) => a.dueDate.compareTo(b.dueDate));

    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? _buildErrorState()
          : RefreshIndicator(
              onRefresh: _loadData,
              color: AppColors.primary,
              child: CustomScrollView(
                slivers: [
                  // Custom App Bar
                  SliverToBoxAdapter(child: _buildHeader()),

                  // Stats Grid
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                    sliver: SliverToBoxAdapter(
                      child: _buildStatsGrid(pendingAssignments, upcoming),
                    ),
                  ),

                  // Upcoming Deadlines Header
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 28, 20, 12),
                    sliver: SliverToBoxAdapter(
                      child: Row(
                        children: [
                          const Text(
                            'Upcoming Deadlines',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const Spacer(),
                          if (upcoming.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.warning.withValues(
                                  alpha: 0.12,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${upcoming.length} tasks',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.warning,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),

                  // Upcoming Deadlines List
                  upcoming.isEmpty
                      ? SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          sliver: SliverToBoxAdapter(
                            child: _buildEmptyDeadlines(),
                          ),
                        )
                      : SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                if (index >= 5) return null;
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: _buildDeadlineCard(upcoming[index]),
                                );
                              },
                              childCount: upcoming.length > 5
                                  ? 5
                                  : upcoming.length,
                            ),
                          ),
                        ),

                  // Bottom spacing
                  const SliverPadding(padding: EdgeInsets.only(bottom: 20)),
                ],
              ),
            ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        MediaQuery.of(context).padding.top + 16,
        20,
        20,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF6C63FF), Color(0xFF9B59B6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getGreeting(),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _userName.isNotEmpty ? _userName : 'Student',
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ),
              // Profile / Logout button
              Material(
                color: Colors.white.withValues(alpha: 0.15),
                shape: const CircleBorder(),
                child: InkWell(
                  onTap: _signOut,
                  customBorder: const CircleBorder(),
                  child: const Padding(
                    padding: EdgeInsets.all(10),
                    child: Icon(
                      Icons.logout_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(List<Assignment> pending, List<Assignment> upcoming) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Subjects',
                subjects.length.toString(),
                Icons.menu_book_rounded,
                AppColors.blueGradient,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Assignments',
                assignments.length.toString(),
                Icons.assignment_rounded,
                AppColors.primaryGradient,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Pending',
                pending.length.toString(),
                Icons.pending_actions_rounded,
                AppColors.orangeGradient,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Upcoming',
                upcoming.length.toString(),
                Icons.schedule_rounded,
                AppColors.redGradient,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Gradient gradient,
  ) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: (gradient as LinearGradient).colors.first.withValues(
              alpha: 0.3,
            ),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const SizedBox(height: 14),
          Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.white.withValues(alpha: 0.85),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeadlineCard(Assignment assignment) {
    final daysLeft = assignment.dueDate.difference(DateTime.now()).inDays;
    final isUrgent = daysLeft <= 2;

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
          // Date badge
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isUrgent
                  ? AppColors.error.withValues(alpha: 0.1)
                  : AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  assignment.dueDate.day.toString(),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: isUrgent ? AppColors.error : AppColors.primary,
                  ),
                ),
                Text(
                  _monthAbbr(assignment.dueDate.month),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: isUrgent ? AppColors.error : AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  assignment.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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
          // Days left chip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: isUrgent
                  ? AppColors.error.withValues(alpha: 0.1)
                  : AppColors.success.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              daysLeft == 0
                  ? 'Today'
                  : daysLeft == 1
                  ? '1 day'
                  : '$daysLeft days',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isUrgent ? AppColors.error : AppColors.success,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyDeadlines() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(
            Icons.celebration_rounded,
            size: 48,
            color: AppColors.primary.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 12),
          const Text(
            'All caught up!',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'No upcoming deadlines',
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.cloud_off_rounded,
                size: 48,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: _loadData,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  String _monthAbbr(int month) {
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
    return months[month - 1];
  }
}
