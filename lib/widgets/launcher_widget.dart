import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/snippet.dart';
import '../services/database_service.dart';
import '../services/clipboard_service.dart';
import 'search_mode_widget.dart';
import 'snippet_form_widget.dart';

enum LauncherMode { search, add, edit }

class LauncherWidget extends StatefulWidget {
  final VoidCallback onClose;

  const LauncherWidget({Key? key, required this.onClose}) : super(key: key);

  @override
  State<LauncherWidget> createState() => _LauncherWidgetState();
}

class _LauncherWidgetState extends State<LauncherWidget> {
  final DatabaseService _dbService = DatabaseService();
  final GlobalKey<SearchModeWidgetState> _searchKey = GlobalKey();
  final GlobalKey<SnippetFormWidgetState> _formKey = GlobalKey();

  LauncherMode _mode = LauncherMode.search;
  Snippet? _editingSnippet;

  void _switchToAddMode() {
    setState(() {
      _mode = LauncherMode.add;
      _editingSnippet = null;
    });
  }

  void _switchToEditMode(Snippet snippet) {
    setState(() {
      _mode = LauncherMode.edit;
      _editingSnippet = snippet;
    });
  }

  void _switchToSearchMode() {
    setState(() {
      _mode = LauncherMode.search;
      _editingSnippet = null;
    });
  }

  Future<void> _saveSnippet(String title, String content) async {
    if (_mode == LauncherMode.edit && _editingSnippet != null) {
      // Update existing snippet
      _editingSnippet!.title = title;
      _editingSnippet!.content = content;
      await _dbService.updateSnippet(_editingSnippet!);
    } else {
      // Create new snippet
      final snippet = Snippet.create(
        title: title,
        content: content,
      );
      await _dbService.addSnippet(snippet);
    }

    _switchToSearchMode();
  }

  Future<void> _selectSnippet(Snippet snippet) async {
    await ClipboardService.copyToClipboard(snippet.content);
    await _dbService.incrementUsage(snippet.id);
    widget.onClose();
  }

  void _handleKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent) return;

    // Global ESC key handling
    if (event.logicalKey == LogicalKeyboardKey.escape) {
      if (_mode == LauncherMode.add || _mode == LauncherMode.edit) {
        _switchToSearchMode();
      } else {
        widget.onClose();
      }
      return;
    }

    // Delegate to child widgets
    if (_mode == LauncherMode.search) {
      _searchKey.currentState?.handleKeyEvent(event);
    } else {
      _formKey.currentState?.handleKeyEvent(event);
    }
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: FocusNode(),
      onKeyEvent: _handleKeyEvent,
      child: Container(
        width: 600,
        height: 500,
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFF3E3E42),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _mode == LauncherMode.search
                ? SearchModeWidget(
                    key: _searchKey,
                    onAddNew: _switchToAddMode,
                    onEdit: _switchToEditMode,
                    onSelect: _selectSnippet,
                  )
                : SnippetFormWidget(
                    key: _formKey,
                    editingSnippet: _editingSnippet,
                    onCancel: _switchToSearchMode,
                    onSave: _saveSnippet,
                  ),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
    String hintText;
    if (_mode == LauncherMode.search) {
      hintText = 'Ctrl+E or Double-click to edit  |  Ctrl+N to add  |  ESC to close';
    } else if (_mode == LauncherMode.edit) {
      hintText = 'Ctrl+S or Ctrl+Enter to save  |  ESC to cancel';
    } else {
      hintText = 'Ctrl+S or Ctrl+Enter to save  |  ESC to cancel';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: Color(0xFF2D2D30)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            hintText,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
