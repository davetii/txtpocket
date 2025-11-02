import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/snippet.dart';
import '../services/database_service.dart';
import '../services/clipboard_service.dart';

enum LauncherMode { search, add }

class LauncherWidget extends StatefulWidget {
  final VoidCallback onClose;

  const LauncherWidget({Key? key, required this.onClose}) : super(key: key);

  @override
  State<LauncherWidget> createState() => _LauncherWidgetState();
}

class _LauncherWidgetState extends State<LauncherWidget> {
  final DatabaseService _dbService = DatabaseService();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final FocusNode _titleFocusNode = FocusNode();
  final FocusNode _contentFocusNode = FocusNode();

  LauncherMode _mode = LauncherMode.search;
  int _selectedIndex = 0;
  List<Snippet> _snippets = [];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    // Defer focus request until after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _mode == LauncherMode.search) {
        _searchFocusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _titleController.dispose();
    _contentController.dispose();
    _searchFocusNode.dispose();
    _titleFocusNode.dispose();
    _contentFocusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _selectedIndex = 0;
    });
  }

  void _switchToAddMode() {
    setState(() {
      _mode = LauncherMode.add;
      _titleController.clear();
      _contentController.clear();
    });
    Future.delayed(const Duration(milliseconds: 100), () {
      _titleFocusNode.requestFocus();
    });
  }

  void _switchToSearchMode() {
    setState(() {
      _mode = LauncherMode.search;
      _selectedIndex = 0;
    });
    Future.delayed(const Duration(milliseconds: 100), () {
      _searchFocusNode.requestFocus();
    });
  }

  Future<void> _saveSnippet() async {
    if (_titleController.text.trim().isEmpty ||
        _contentController.text.trim().isEmpty) {
      return;
    }

    final snippet = Snippet.create(
      title: _titleController.text.trim(),
      content: _contentController.text.trim(),
    );

    await _dbService.addSnippet(snippet);
    _switchToSearchMode();
  }

  Future<void> _selectSnippet(Snippet snippet) async {
    await ClipboardService.copyToClipboard(snippet.content);
    await _dbService.incrementUsage(snippet.id);
    widget.onClose();
  }

  void _handleKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent) return;

    // Global shortcuts
    if (event.logicalKey == LogicalKeyboardKey.escape) {
      if (_mode == LauncherMode.add) {
        _switchToSearchMode();
      } else {
        widget.onClose();
      }
      return;
    }

    // Mode-specific shortcuts
    if (_mode == LauncherMode.search) {
      _handleSearchModeKeys(event);
    } else {
      _handleAddModeKeys(event);
    }
  }

  void _handleSearchModeKeys(KeyEvent event) {
    final isCtrlN = event.logicalKey == LogicalKeyboardKey.keyN &&
        HardwareKeyboard.instance.isControlPressed;

    if (isCtrlN) {
      _switchToAddMode();
      return;
    }

    if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      setState(() {
        if (_selectedIndex < _snippets.length - 1) {
          _selectedIndex++;
        }
      });
    } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      setState(() {
        if (_selectedIndex > 0) {
          _selectedIndex--;
        }
      });
    } else if (event.logicalKey == LogicalKeyboardKey.enter) {
      if (_snippets.isNotEmpty && _selectedIndex < _snippets.length) {
        _selectSnippet(_snippets[_selectedIndex]);
      }
    }
  }

  void _handleAddModeKeys(KeyEvent event) {
    final isCtrlEnter = event.logicalKey == LogicalKeyboardKey.enter &&
        HardwareKeyboard.instance.isControlPressed;

    if (isCtrlEnter) {
      _saveSnippet();
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
                ? _buildSearchMode()
                : _buildAddMode(),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchMode() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Search header
        Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Color(0xFF2D2D30)),
            ),
          ),
          child: Row(
            children: [
              const Text('🔍', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _searchController,
                  focusNode: _searchFocusNode,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                  decoration: const InputDecoration(
                    hintText: 'Search snippets...',
                    hintStyle: TextStyle(color: Colors.grey),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ],
          ),
        ),
        // Search results
        StreamBuilder<List<Snippet>>(
          stream: _dbService.searchSnippets(_searchController.text),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Padding(
                padding: EdgeInsets.all(32),
                child: Center(
                  child: CircularProgressIndicator(color: Colors.blue),
                ),
              );
            }

            _snippets = snapshot.data!;

            if (_snippets.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(32),
                child: Center(
                  child: Column(
                    children: [
                      Text(
                        _searchController.text.isEmpty
                            ? 'No snippets yet'
                            : 'No snippets found',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Press Ctrl+N to add your first snippet',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 350),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _snippets.length,
                itemBuilder: (context, index) {
                  final snippet = _snippets[index];
                  final isSelected = index == _selectedIndex;

                  return InkWell(
                    onTap: () => _selectSnippet(snippet),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF2D2D30)
                            : Colors.transparent,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  snippet.title,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  snippet.content.split('\n').first,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (snippet.usageCount > 0)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${snippet.usageCount}',
                                style: const TextStyle(
                                  color: Colors.blue,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildAddMode() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          const Row(
            children: [
              Text('➕', style: TextStyle(fontSize: 20)),
              SizedBox(width: 12),
              Text(
                'Add New Snippet',
                style: TextStyle(
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
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: _switchToSearchMode,
                style: TextButton.styleFrom(
                  foregroundColor: Colors.grey,
                ),
                child: const Text('Cancel'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _saveSnippet,
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
    );
  }

  Widget _buildFooter() {
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
            _mode == LauncherMode.search
                ? 'Ctrl+N to add  |  ESC to close'
                : 'Ctrl+Enter to save  |  ESC to cancel',
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
