import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../models/data_models.dart';
import '../theme/app_theme.dart';

class LinkFormScreen extends StatefulWidget {
  final ProfileLink? link;

  const LinkFormScreen({super.key, this.link});

  @override
  State<LinkFormScreen> createState() => _LinkFormScreenState();
}

class _LinkFormScreenState extends State<LinkFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _urlController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.link?.platform ?? "");
    _urlController = TextEditingController(text: widget.link?.url ?? "");
  }

  @override
  void dispose() {
    _nameController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  bool _hasChanges() {
    final originalName = widget.link?.platform ?? "";
    final originalUrl = widget.link?.url ?? "";

    return _nameController.text.trim() != originalName ||
        _urlController.text.trim() != originalUrl;
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

    final newLink = ProfileLink(
      platform: _nameController.text.trim(),
      url: _urlController.text.trim(),
    );

    Navigator.of(context).pop(newLink);
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

    final isEditMode = widget.link != null;

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
            isEditMode ? 'Edit Link' : 'Add Link',
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
                _buildInputLabel('Link Name *'),
                TextFormField(
                  controller: _nameController,
                  textCapitalization: TextCapitalization.words,
                  style: const TextStyle(fontSize: 13),
                  decoration: const InputDecoration(
                    hintText: 'e.g. GitHub, LinkedIn, Portfolio',
                    border: InputBorder.none,
                  ),
                  validator: (val) => val == null || val.trim().isEmpty ? 'Link name is required' : null,
                ),
                const SizedBox(height: 20),

                _buildInputLabel('Link URL *'),
                TextFormField(
                  controller: _urlController,
                  style: const TextStyle(fontSize: 13),
                  decoration: const InputDecoration(
                    hintText: 'e.g. https://...',
                    border: InputBorder.none,
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'URL is required';
                    }
                    final trimmed = val.trim();
                    if (!trimmed.startsWith("http://") && !trimmed.startsWith("https://")) {
                      return 'URL must start with http:// or https://';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
