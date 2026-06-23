import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../models/data_models.dart';
import '../theme/app_theme.dart';

class ProjectFormScreen extends StatefulWidget {
  final Project? project;

  const ProjectFormScreen({super.key, this.project});

  @override
  State<ProjectFormScreen> createState() => _ProjectFormScreenState();
}

class _ProjectFormScreenState extends State<ProjectFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _urlController;
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.project?.title ?? "");
    _urlController = TextEditingController(text: widget.project?.demoUrl ?? "");
    _descriptionController = TextEditingController(text: widget.project?.description ?? "");
  }

  @override
  void dispose() {
    _titleController.dispose();
    _urlController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  bool _hasChanges() {
    final originalTitle = widget.project?.title ?? "";
    final originalUrl = widget.project?.demoUrl ?? "";
    final originalDescription = widget.project?.description ?? "";

    return _titleController.text.trim() != originalTitle ||
        _urlController.text.trim() != originalUrl ||
        _descriptionController.text.trim() != originalDescription;
  }

  Future<bool> _showDiscardDialog() async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        title: const Text('Unsaved Changes', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Are you sure you want to discard your edits?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Discard', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    ) ?? false;
  }

  void _onSave() {
    if (!_formKey.currentState!.validate()) return;

    final id = widget.project?.id ?? "proj_${DateTime.now().millisecondsSinceEpoch}";
    final newProj = Project(
      id: id,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      techStack: widget.project?.techStack ?? ["Flutter", "Dart"],
      githubUrl: _urlController.text.trim(),
      demoUrl: _urlController.text.trim(),
      imagePlaceholder: widget.project?.imagePlaceholder,
    );

    Navigator.of(context).pop(newProj);
  }

  Widget _buildInputLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        label,
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderCol = isDark ? AppTheme.darkBorder : AppTheme.lightBorder;
    final theme = Theme.of(context);

    final isEditMode = widget.project != null;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        if (_hasChanges()) {
          final discard = await _showDiscardDialog();
          if (discard && context.mounted) {
            Navigator.of(context).pop();
          }
        } else {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            isEditMode ? 'Edit Project' : 'Add Project',
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
          ),
          centerTitle: true,
          elevation: 0.5,
          leading: IconButton(
            icon: const Icon(LucideIcons.arrowLeft, size: 20),
            onPressed: () async {
              if (_hasChanges()) {
                final discard = await _showDiscardDialog();
                if (discard && context.mounted) Navigator.of(context).pop();
              } else {
                Navigator.of(context).pop();
              }
            },
          ),
        ),
        bottomNavigationBar: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            border: Border(top: BorderSide(color: borderCol, width: 0.8)),
          ),
          child: SafeArea(
            child: ElevatedButton(
              onPressed: _onSave,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(vertical: 14),
                elevation: 0,
              ),
              child: Text(
                isEditMode ? 'Update' : 'Save',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildInputLabel('Project Title *'),
                TextFormField(
                  controller: _titleController,
                  style: const TextStyle(fontSize: 13),
                  decoration: const InputDecoration(
                    hintText: 'Enter project title',
                    border: InputBorder.none,
                  ),
                  validator: (val) => val == null || val.trim().isEmpty ? 'Title is required' : null,
                ),
                const SizedBox(height: 20),

                _buildInputLabel('Project URL (Optional)'),
                TextFormField(
                  controller: _urlController,
                  style: const TextStyle(fontSize: 13),
                  decoration: const InputDecoration(
                    hintText: 'e.g. https://github.com/...',
                    border: InputBorder.none,
                  ),
                ),
                const SizedBox(height: 20),

                _buildInputLabel('Description *'),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 4,
                  style: const TextStyle(fontSize: 13),
                  decoration: const InputDecoration(
                    hintText: 'Describe your project, features, stack...',
                    border: InputBorder.none,
                  ),
                  validator: (val) => val == null || val.trim().isEmpty ? 'Description is required' : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
