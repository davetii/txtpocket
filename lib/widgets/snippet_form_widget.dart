import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/snippet.dart';

class SnippetFormWidget extends StatefulWidget {
  final Snippet? editingSnippet;
  final VoidCallback onCancel;
  final Function(String title, String content) onSave;
  final Function(Snippet)? onDelete;

  const SnippetFormWidget({
    Key? key,
    this.editingSnippet,
    required this.onCancel,
    required this.onSave,
    this.onDelete,
  }) : super(key: key);

  @override
  State<SnippetFormWidget> createState() => SnippetFormWidgetState();
}

class SnippetFormWidgetState extends State<SnippetFormWidget> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final FocusNode _titleFocusNode = FocusNode();
  final FocusNode _contentFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Pre-populate fields if editing
    if (widget.editingSnippet != null) {
      _titleController.text = widget.editingSnippet!.title;
      _contentController.text = widget.editingSnippet!.content;
    }
    // Defer focus request until after first frame
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        _titleFocusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _titleFocusNode.dispose();
    _contentFocusNode.dispose();
    super.dispose();
  }

  void _handleSave() {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (title.isEmpty || content.isEmpty) {
      return;
    }

    widget.onSave(title, content);
  }

  void handleKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent) return;

    final isCtrlEnter = event.logicalKey == LogicalKeyboardKey.enter &&
        HardwareKeyboard.instance.isControlPressed;
    final isCtrlS = event.logicalKey == LogicalKeyboardKey.keyS &&
        HardwareKeyboard.instance.isControlPressed;
    final isCtrlD = event.logicalKey == LogicalKeyboardKey.keyD &&
        HardwareKeyboard.instance.isControlPressed;

    if (isCtrlEnter || isCtrlS) {
      _handleSave();
    } else if (isCtrlD && widget.editingSnippet != null && widget.onDelete != null) {
      widget.onDelete!(widget.editingSnippet!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditMode = widget.editingSnippet != null;

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Text(isEditMode ? '✏️' : '➕', style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 12),
              Text(
                isEditMode ? 'Edit Snippet' : 'Add New Snippet',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Title input
          const Text(
            'Title:',
            style: TextStyle(color: Colors.white, fontSize: 14),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _titleController,
            focusNode: _titleFocusNode,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Enter snippet title...',
              hintStyle: const TextStyle(color: Colors.grey),
              filled: true,
              fillColor: const Color(0xFF2D2D30),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Content input
          const Text(
            'Content:',
            style: TextStyle(color: Colors.white, fontSize: 14),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _contentController,
            focusNode: _contentFocusNode,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            maxLines: 8,
            decoration: InputDecoration(
              hintText: 'Enter snippet content...',
              hintStyle: const TextStyle(color: Colors.grey),
              filled: true,
              fillColor: const Color(0xFF2D2D30),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(12),
            ),
          ),
          const SizedBox(height: 16),
          // Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Delete button (only in edit mode)
              if (isEditMode && widget.onDelete != null)
                TextButton.icon(
                  onPressed: () => widget.onDelete!(widget.editingSnippet!),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Delete'),
                )
              else
                const SizedBox.shrink(),
              // Save/Cancel buttons
              Row(
                children: [
                  TextButton(
                    onPressed: widget.onCancel,
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.grey,
                    ),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _handleSave,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Save'),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
