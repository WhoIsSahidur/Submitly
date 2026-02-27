import 'package:flutter/material.dart';
import '../../shared/services/user_service.dart';
import '../../shared/services/subject_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _userService = UserService();
  final _subjectService = SubjectService();

  Map<String, dynamic>? _currentUser;
  List<Map<String, dynamic>> _subjects = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      // Get or create a default user
      final user = await _userService.getOrCreateUser(
        'Sahidur',
        'sahidur@submitly.app',
      );

      if (user == null) {
        setState(() {
          _error = 'Could not connect to backend. Is the server running?';
          _loading = false;
        });
        return;
      }

      _currentUser = user;

      // Load subjects for this user
      final subjects = await _subjectService.getSubjects(user['id']);

      setState(() {
        _subjects = subjects;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Connection error: $e';
        _loading = false;
      });
    }
  }

  Future<void> _addSubject() async {
    final nameController = TextEditingController();
    final semesterController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Subject'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Subject Name'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: semesterController,
              decoration:
                  const InputDecoration(labelText: 'Semester (optional)'),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Add')),
        ],
      ),
    );

    if (result == true && nameController.text.isNotEmpty) {
      final subject = await _subjectService.createSubject(
        name: nameController.text,
        userId: _currentUser!['id'],
        semester: semesterController.text.isNotEmpty
            ? semesterController.text
            : null,
      );

      if (subject != null) {
        setState(() => _subjects.insert(0, subject));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Submitly'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _init,
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: _currentUser != null
          ? FloatingActionButton(
              onPressed: _addSubject,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              Text(_error!,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _init,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // User info card
        Card(
          child: ListTile(
            leading: const CircleAvatar(child: Icon(Icons.person)),
            title: Text(_currentUser!['name'] ?? 'User'),
            subtitle: Text(_currentUser!['email'] ?? ''),
            trailing: const Icon(Icons.check_circle, color: Colors.green),
          ),
        ),
        const SizedBox(height: 16),
        Text('Subjects',
            style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),

        // Subjects list
        if (_subjects.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 32),
            child: Center(
                child: Text('No subjects yet. Tap + to add one!')),
          )
        else
          ..._subjects.map((s) => Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: s['color'] != null
                        ? _parseColor(s['color'])
                        : Colors.deepPurple,
                    child: Text(
                      s['name']?.toString().substring(0, 1) ?? '?',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(s['name'] ?? 'Untitled'),
                  subtitle:
                      s['semester'] != null ? Text(s['semester']) : null,
                ),
              )),
      ],
    );
  }

  Color _parseColor(String hex) {
    try {
      return Color(int.parse(hex.replaceFirst('#', '0xFF')));
    } catch (_) {
      return Colors.deepPurple;
    }
  }
}
