import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CodeBlockWidget extends StatelessWidget {
  final String language;
  final String code;
  final bool isEditable;
  final Function(String)? onCodeChanged;

  const CodeBlockWidget({
    Key? key,
    required this.language,
    required this.code,
    this.isEditable = false,
    this.onCodeChanged,
  }) : super(key: key);

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
          Container(
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
                const Icon(
                  Icons.code,
                  color: AppTheme.vsCodeLightBlue,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    language,
                    style: const TextStyle(
                      color: AppTheme.vsCodeLightBlue,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (isEditable)
                  PopupMenuButton<String>(
                    icon: const Icon(
                      Icons.more_vert,
                      color: AppTheme.vsCodeLightGrey,
                      size: 16,
                    ),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'javascript',
                        child: Text('JavaScript'),
                      ),
                      const PopupMenuItem(
                        value: 'python',
                        child: Text('Python'),
                      ),
                      const PopupMenuItem(
                        value: 'java',
                        child: Text('Java'),
                      ),
                      const PopupMenuItem(
                        value: 'csharp',
                        child: Text('C#'),
                      ),
                      const PopupMenuItem(
                        value: 'html',
                        child: Text('HTML'),
                      ),
                      const PopupMenuItem(
                        value: 'css',
                        child: Text('CSS'),
                      ),
                      const PopupMenuItem(
                        value: 'dart',
                        child: Text('Dart'),
                      ),
                      const PopupMenuItem(
                        value: 'text',
                        child: Text('Text'),
                      ),
                    ],
                    onSelected: (newLanguage) {
                      if (onCodeChanged != null) {
                        onCodeChanged!(code);
                      }
                    },
                  ),
              ],
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
            child: isEditable
                ? TextField(
                    controller: TextEditingController(text: code),
                    onChanged: onCodeChanged,
                    maxLines: null,
                    style: const TextStyle(
                      color: AppTheme.vsCodeForeground,
                      fontFamily: 'monospace',
                      fontSize: 14,
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                      hintText: 'Kodu buraya yazın...',
                      hintStyle: TextStyle(
                        color: AppTheme.vsCodeLightGrey,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  )
                : SelectableText(
                    code,
                    style: const TextStyle(
                      color: AppTheme.vsCodeForeground,
                      fontFamily: 'monospace',
                      fontSize: 14,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
