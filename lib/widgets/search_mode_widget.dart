import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/snippet.dart';
import '../services/database_service.dart';

class SearchModeWidget extends StatefulWidget {
  final VoidCallback onAddNew;
  final Function(Snippet) onEdit;
  final Function(Snippet) onSelect;

  const SearchModeWidget({
    Key? key,
    required this.onAddNew,
    required this.onEdit,
    required this.onSelect,
  }) : super(key: key);

  @override
  State<SearchModeWidget> createState() => SearchModeWidgetState();
}

class SearchModeWidgetState extends State<SearchModeWidget> {
  final DatabaseService _dbService = DatabaseService();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  int _selectedIndex = 0;
  List<Snippet> _snippets = [];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    // Defer focus request until after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _searchFocusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _selectedIndex = 0;
    });
  }

  void handleKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent) return;

    final isCtrlN = event.logicalKey == LogicalKeyboardKey.keyN &&
        HardwareKeyboard.instance.isControlPressed;
    final isCtrlE = event.logicalKey == LogicalKeyboardKey.keyE &&
        HardwareKeyboard.instance.isControlPressed;

    if (isCtrlN) {
      widget.onAddNew();
      return;
    }

    if (isCtrlE) {
      if (_snippets.isNotEmpty && _selectedIndex < _snippets.length) {
        widget.onEdit(_snippets[_selectedIndex]);
      }
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
        widget.onSelect(_snippets[_selectedIndex]);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
                    onTap: () => widget.onSelect(snippet),
                    onDoubleTap: () => widget.onEdit(snippet),
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
                                color: Colors.blue.withValues(alpha: 0.2),
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
}
