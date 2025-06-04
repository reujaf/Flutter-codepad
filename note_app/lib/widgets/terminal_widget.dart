import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/command.dart';
import '../theme/app_theme.dart';

class TerminalWidget extends StatefulWidget {
  final Function(String) onCommandExecuted;
  
  const TerminalWidget({
    Key? key,
    required this.onCommandExecuted,
  }) : super(key: key);

  @override
  State<TerminalWidget> createState() => _TerminalWidgetState();
}

class _TerminalWidgetState extends State<TerminalWidget> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  List<String> _commandHistory = [];
  int _historyIndex = -1;
  
  @override
  void initState() {
    super.initState();
    // Otomatik olarak odağı terminal giriş alanına ayarla
    Future.microtask(() => _focusNode.requestFocus());
  }
  
  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }
  
  void _executeCommand() {
    final input = _controller.text;
    if (input.isNotEmpty) {
      setState(() {
        _commandHistory.add(input);
        _historyIndex = _commandHistory.length;
      });
      
      if (input.trim() == 'help') {
        _showHelpDialog();
      } else {
        widget.onCommandExecuted(input);
        Navigator.of(context).pop();
      }
      
      _controller.clear();
    }
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.vsCodeDarkGrey,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppTheme.vsCodeBlue.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.help_outline,
                color: AppTheme.vsCodeLightBlue,
                size: 18,
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'Kullanılabilir Komutlar',
              style: TextStyle(
                color: AppTheme.vsCodeLightBlue,
                fontSize: 16,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHelpItem(
                icon: Icons.image,
                command: 'img',
                description: 'Galeriden bir görsel ekler.',
              ),
              const SizedBox(height: 16),
              _buildHelpItem(
                icon: Icons.code,
                command: 'code',
                description: 'Kod bloğu eklemek için bir alan oluşturur.',
              ),
              const SizedBox(height: 16),
              _buildHelpItem(
                icon: Icons.format_list_bulleted,
                command: 'list',
                description: 'Noktalı liste oluşturur.',
              ),
              const SizedBox(height: 16),
              _buildHelpItem(
                icon: Icons.format_list_numbered,
                command: 'list 1',
                description: 'Numaralı liste oluşturur.',
              ),
              const SizedBox(height: 16),
              _buildHelpItem(
                icon: Icons.help_outline,
                command: 'help',
                description: 'Bu yardım ekranını gösterir.',
              ),
              const SizedBox(height: 16),
              const Divider(
                color: AppTheme.vsCodeLightGrey,
                height: 1,
              ),
              const SizedBox(height: 16),
              const Text(
                'İpuçları:',
                style: TextStyle(
                  color: AppTheme.vsCodeForeground,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '• Eklenen öğeleri kaldırmak için öğeye uzun basın.',
                style: TextStyle(
                  color: AppTheme.vsCodeForeground,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                '• Geçmiş komutlara erişmek için ↑ ve ↓ tuşlarını kullanın.',
                style: TextStyle(
                  color: AppTheme.vsCodeForeground,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            child: const Text(
              'Kapat',
              style: TextStyle(color: AppTheme.vsCodeLightBlue),
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
  
  Widget _buildHelpItem({
    required IconData icon,
    required String command,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: AppTheme.vsCodeLightBlue,
          size: 16,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.vsCodeBackground,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  command,
                  style: const TextStyle(
                    color: AppTheme.vsCodeGreen,
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                description,
                style: const TextStyle(
                  color: AppTheme.vsCodeForeground,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _navigateHistory(bool up) {
    if (_commandHistory.isEmpty) return;
    
    setState(() {
      if (up) {
        // Yukarı: Geçmiş içinde geriye git
        _historyIndex = _historyIndex > 0 ? _historyIndex - 1 : 0;
      } else {
        // Aşağı: Geçmiş içinde ileriye git
        _historyIndex = _historyIndex < _commandHistory.length - 1 
            ? _historyIndex + 1 
            : _commandHistory.length - 1;
      }
      
      _controller.text = _commandHistory[_historyIndex];
      _controller.selection = TextSelection.fromPosition(
        TextPosition(offset: _controller.text.length),
      );
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.vsCodeBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.vsCodeLightGrey),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: AppTheme.vsCodeDarkGrey,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(11),
                topRight: Radius.circular(11),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 3,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.vsCodeBlue.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.terminal,
                        color: AppTheme.vsCodeLightBlue,
                        size: 16,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'TERMINAL',
                        style: TextStyle(
                          color: AppTheme.vsCodeLightBlue,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.help_outline, size: 18, color: AppTheme.vsCodeLightBlue),
                  onPressed: _showHelpDialog,
                  padding: const EdgeInsets.all(4),
                  constraints: const BoxConstraints(),
                  tooltip: 'Yardım',
                ),
                const SizedBox(width: 12),
                IconButton(
                  icon: const Icon(Icons.close, size: 18, color: AppTheme.vsCodeForeground),
                  onPressed: () => Navigator.of(context).pop(),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  tooltip: 'Kapat',
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.vsCodeGreen.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'VS Code Not >',
                        style: TextStyle(
                          color: AppTheme.vsCodeGreen,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: RawKeyboardListener(
                        focusNode: FocusNode(),
                        onKey: (RawKeyEvent event) {
                          if (event is RawKeyDownEvent) {
                            if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
                              _navigateHistory(true);
                            } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
                              _navigateHistory(false);
                            }
                          }
                        },
                        child: TextField(
                          controller: _controller,
                          focusNode: _focusNode,
                          style: const TextStyle(
                            color: AppTheme.vsCodeForeground,
                            fontFamily: 'monospace',
                            fontSize: 14,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Komut girin (yardım için help yazın)',
                            hintStyle: TextStyle(
                              color: AppTheme.vsCodeLightGrey.withOpacity(0.6),
                              fontStyle: FontStyle.italic,
                              fontSize: 14,
                            ),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          ),
                          onSubmitted: (_) => _executeCommand(),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.send,
                        color: AppTheme.vsCodeLightBlue,
                        size: 18,
                      ),
                      onPressed: _executeCommand,
                      tooltip: 'Çalıştır',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 