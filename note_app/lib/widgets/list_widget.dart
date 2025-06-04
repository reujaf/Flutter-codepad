import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum ListType { bullet, numbered }

class ListWidget extends StatefulWidget {
  final ListType type;
  final VoidCallback onRemove;

  const ListWidget({
    Key? key,
    required this.type,
    required this.onRemove,
  }) : super(key: key);

  @override
  State<ListWidget> createState() => _ListWidgetState();
}

class _ListWidgetState extends State<ListWidget> {
  final List<TextEditingController> _controllers = [];
  final List<FocusNode> _focusNodes = [];

  @override
  void initState() {
    super.initState();
    // İlk liste öğesini ekle
    _addItem();
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _addItem() {
    final controller = TextEditingController();
    final focusNode = FocusNode();

    setState(() {
      _controllers.add(controller);
      _focusNodes.add(focusNode);
    });

    // Yeni eklenen öğeye odaklan
    Future.microtask(() => focusNode.requestFocus());
  }

  void _removeItem(int index) {
    if (_controllers.length > 1) {
      setState(() {
        _controllers[index].dispose();
        _focusNodes[index].dispose();
        _controllers.removeAt(index);
        _focusNodes.removeAt(index);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.vsCodeBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.vsCodeLightGrey),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onLongPress: widget.onRemove,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.vsCodeDarkGrey,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(7),
                  topRight: Radius.circular(7),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(
                    widget.type == ListType.bullet
                        ? Icons.format_list_bulleted
                        : Icons.format_list_numbered,
                    color: AppTheme.vsCodeLightBlue,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    widget.type == ListType.bullet
                        ? 'Noktalı Liste'
                        : 'Numaralı Liste',
                    style: const TextStyle(
                      color: AppTheme.vsCodeLightBlue,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(
                      Icons.delete,
                      color: AppTheme.vsCodeLightGrey,
                      size: 16,
                    ),
                    onPressed: widget.onRemove,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    tooltip: 'Kaldır',
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: AppTheme.vsCodeBackground,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(7),
                bottomRight: Radius.circular(7),
              ),
            ),
            child: Column(
              children: [
                for (int i = 0; i < _controllers.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 24,
                          child: Center(
                            child: Text(
                              widget.type == ListType.bullet
                                  ? '•'
                                  : '${i + 1}.',
                              style: TextStyle(
                                color: AppTheme.vsCodeLightBlue,
                                fontSize:
                                    widget.type == ListType.bullet ? 18 : 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _controllers[i],
                            focusNode: _focusNodes[i],
                            decoration: InputDecoration(
                              hintText: 'Liste öğesi ${i + 1}',
                              hintStyle: TextStyle(
                                color:
                                    AppTheme.vsCodeLightGrey.withOpacity(0.6),
                                fontStyle: FontStyle.italic,
                              ),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                            style: const TextStyle(
                              color: AppTheme.vsCodeForeground,
                              fontSize: 14,
                            ),
                            onSubmitted: (_) {
                              // Enter'a basılınca yeni öğe ekle
                              if (i == _controllers.length - 1) {
                                _addItem();
                              } else {
                                // Sonraki öğeye geç
                                _focusNodes[i + 1].requestFocus();
                              }
                            },
                          ),
                        ),
                        if (_controllers.length > 1)
                          IconButton(
                            icon: const Icon(
                              Icons.remove_circle_outline,
                              color: AppTheme.vsCodeLightGrey,
                              size: 16,
                            ),
                            onPressed: () => _removeItem(i),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                      ],
                    ),
                  ),
                // Yeni öğe ekleme butonu
                TextButton.icon(
                  onPressed: _addItem,
                  icon: const Icon(
                    Icons.add,
                    size: 16,
                    color: AppTheme.vsCodeLightBlue,
                  ),
                  label: const Text(
                    'Öğe Ekle',
                    style: TextStyle(
                      color: AppTheme.vsCodeLightBlue,
                      fontSize: 12,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.all(8),
                    minimumSize: Size.zero,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
