import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/note.dart';
import '../models/command.dart';
import '../services/notes_service.dart';
import '../widgets/terminal_widget.dart';
import '../widgets/code_block_widget.dart';
import '../widgets/image_widget.dart';
import '../widgets/list_widget.dart';
import '../theme/app_theme.dart';

class NoteDetailScreen extends StatefulWidget {
  final Note? note;

  const NoteDetailScreen({Key? key, this.note}) : super(key: key);

  @override
  State<NoteDetailScreen> createState() => _NoteDetailScreenState();
}

class _NoteDetailScreenState extends State<NoteDetailScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _notesService = NotesService();
  final _imagePicker = ImagePicker();
  bool _isEditing = false;
  bool _isLoading = false;
  late Note _note;
  final _contentFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    if (widget.note != null) {
      _note = widget.note!;
      _titleController.text = _note.title;
      _contentController.text = _note.content;
      _isEditing = true;
    } else {
      _note = Note.create(title: '', content: '');
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _contentFocusNode.dispose();
    super.dispose();
  }

  Future<void> _saveNote() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final title = _titleController.text;
        final content = _contentController.text;

        _note.title = title;
        _note.content = content;
        _note.dateModified = DateTime.now();

        await _notesService.saveNote(_note);

        if (mounted) {
          Navigator.pop(context, true);
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  void _showTerminal() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: TerminalWidget(
          onCommandExecuted: _handleCommand,
        ),
      ),
    );
  }

  void _handleCommand(String input) {
    final command = Command.parse(input);

    switch (command.type) {
      case CommandType.image:
        _pickImage();
        break;
      case CommandType.code:
        _addCodeBlock();
        break;
      case CommandType.list:
        _addListBlock(command);
        break;
      case CommandType.help:
        // Help komutu terminal widget içinde işleniyor
        break;
      case CommandType.unknown:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bilinmeyen komut. Yardım için "help" yazın.'),
            backgroundColor: AppTheme.vsCodeRed,
          ),
        );
        break;
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          _note.contentBlocks.add(NoteContent.image(image.path));
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Görsel seçilirken hata oluştu: $e'),
          backgroundColor: AppTheme.vsCodeRed,
        ),
      );
    }
  }

  void _addCodeBlock() {
    setState(() {
      _note.contentBlocks.add(NoteContent.code('', 'text'));
    });
  }

  void _addListBlock(Command command) {
    setState(() {
      final listType =
          command.options != null && command.options!['listType'] == 'numbered'
              ? 'numbered'
              : 'bullet';

      _note.contentBlocks.add(
        NoteContent(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          type: NoteContentType.list,
          content: '',
          metadata: listType,
        ),
      );
    });
  }

  void _removeContentBlock(int index) {
    setState(() {
      _note.contentBlocks.removeAt(index);
    });
  }

  void _showDeleteConfirmDialog(int index, String blockType) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.vsCodeDarkGrey,
        title: const Text('Öğeyi Sil'),
        content:
            Text('Bu $blockType öğesini silmek istediğinize emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('İptal',
                style: TextStyle(color: AppTheme.vsCodeLightBlue)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true);
              _removeContentBlock(index);
            },
            child:
                const Text('Sil', style: TextStyle(color: AppTheme.vsCodeRed)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Notu Düzenle' : 'Yeni Not'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.terminal),
            onPressed: _showTerminal,
            tooltip: 'Terminal',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.vsCodeBlue))
          : Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: AppTheme.vsCodeDarkGrey,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextFormField(
                        controller: _titleController,
                        decoration: InputDecoration(
                          labelText: 'Başlık',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          prefixIcon: const Icon(Icons.title,
                              color: AppTheme.vsCodeLightBlue),
                          floatingLabelBehavior: FloatingLabelBehavior.never,
                        ),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Lütfen bir başlık girin';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: GestureDetector(
                        onDoubleTap: _showTerminal,
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppTheme.vsCodeDarkGrey,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 5,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Column(
                              children: [
                                // Araç çubuğu
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8),
                                  decoration: const BoxDecoration(
                                    color: AppTheme.vsCodeDarkGrey,
                                    border: Border(
                                      bottom: BorderSide(
                                          color: AppTheme.vsCodeLightGrey,
                                          width: 1),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.edit_note,
                                          size: 16,
                                          color: AppTheme.vsCodeLightBlue),
                                      const SizedBox(width: 8),
                                      const Text(
                                        'Not İçeriği',
                                        style: TextStyle(
                                          color: AppTheme.vsCodeLightBlue,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const Spacer(),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: AppTheme.vsCodeBackground,
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.touch_app,
                                              size: 12,
                                              color: AppTheme.vsCodeLightBlue
                                                  .withOpacity(0.7),
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              'Çift tıkla = Terminal',
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: AppTheme.vsCodeForeground
                                                    .withOpacity(0.7),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                Expanded(
                                  child: ListView(
                                    padding: const EdgeInsets.all(16),
                                    children: [
                                      // Ana içerik alanı
                                      TextField(
                                        controller: _contentController,
                                        focusNode: _contentFocusNode,
                                        decoration: const InputDecoration(
                                          hintText: 'İçerik...',
                                          border: InputBorder.none,
                                        ),
                                        maxLines: null,
                                        style: const TextStyle(
                                          fontSize: 16,
                                        ),
                                      ),

                                      // Özel içerik blokları
                                      ..._note.contentBlocks
                                          .asMap()
                                          .entries
                                          .map((entry) {
                                        final index = entry.key;
                                        final block = entry.value;

                                        switch (block.type) {
                                          case NoteContentType.image:
                                            if (block.content
                                                .startsWith('http')) {
                                              return GestureDetector(
                                                onLongPress: () =>
                                                    _showDeleteConfirmDialog(
                                                        index, 'görsel'),
                                                child: ImageWidget(
                                                    imageUrl: block.content),
                                              );
                                            } else {
                                              // Yerel dosya sisteminden görsel
                                              return GestureDetector(
                                                onLongPress: () =>
                                                    _showDeleteConfirmDialog(
                                                        index, 'görsel'),
                                                child: Container(
                                                  margin: const EdgeInsets
                                                      .symmetric(vertical: 8),
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                    border: Border.all(
                                                        color: AppTheme
                                                            .vsCodeLightGrey),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.black
                                                            .withOpacity(0.1),
                                                        blurRadius: 3,
                                                        offset:
                                                            const Offset(0, 1),
                                                      ),
                                                    ],
                                                  ),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                horizontal: 12,
                                                                vertical: 8),
                                                        decoration:
                                                            const BoxDecoration(
                                                          color: AppTheme
                                                              .vsCodeDarkGrey,
                                                          borderRadius:
                                                              BorderRadius.only(
                                                            topLeft:
                                                                Radius.circular(
                                                                    7),
                                                            topRight:
                                                                Radius.circular(
                                                                    7),
                                                          ),
                                                        ),
                                                        child: Row(
                                                          children: [
                                                            const Icon(
                                                              Icons.image,
                                                              color: AppTheme
                                                                  .vsCodeLightBlue,
                                                              size: 16,
                                                            ),
                                                            const SizedBox(
                                                                width: 8),
                                                            const Text(
                                                              'Yerel Görsel',
                                                              style: TextStyle(
                                                                color: AppTheme
                                                                    .vsCodeLightBlue,
                                                                fontSize: 12,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                            const Spacer(),
                                                            IconButton(
                                                              icon: const Icon(
                                                                Icons
                                                                    .delete_outline,
                                                                color: AppTheme
                                                                    .vsCodeLightGrey,
                                                                size: 16,
                                                              ),
                                                              onPressed: () =>
                                                                  _showDeleteConfirmDialog(
                                                                      index,
                                                                      'görsel'),
                                                              padding:
                                                                  EdgeInsets
                                                                      .zero,
                                                              constraints:
                                                                  const BoxConstraints(),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      ClipRRect(
                                                        borderRadius:
                                                            const BorderRadius
                                                                .only(
                                                          bottomLeft:
                                                              Radius.circular(
                                                                  7),
                                                          bottomRight:
                                                              Radius.circular(
                                                                  7),
                                                        ),
                                                        child: Image.file(
                                                          File(block.content),
                                                          fit: BoxFit.cover,
                                                          width:
                                                              double.infinity,
                                                          errorBuilder:
                                                              (context, error,
                                                                  stackTrace) {
                                                            return Container(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(16),
                                                              alignment:
                                                                  Alignment
                                                                      .center,
                                                              child:
                                                                  const Column(
                                                                children: [
                                                                  Icon(
                                                                    Icons
                                                                        .error_outline,
                                                                    color: AppTheme
                                                                        .vsCodeRed,
                                                                    size: 48,
                                                                  ),
                                                                  SizedBox(
                                                                      height:
                                                                          8),
                                                                  Text(
                                                                    'Görsel yüklenemedi',
                                                                    style:
                                                                        TextStyle(
                                                                      color: AppTheme
                                                                          .vsCodeRed,
                                                                    ),
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center,
                                                                  ),
                                                                ],
                                                              ),
                                                            );
                                                          },
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            }
                                          case NoteContentType.code:
                                            return GestureDetector(
                                              onLongPress: () =>
                                                  _showDeleteConfirmDialog(
                                                      index, 'kod bloğu'),
                                              child: CodeBlockWidget(
                                                language:
                                                    block.metadata ?? 'text',
                                                code: block.content,
                                                isEditable: true,
                                                onCodeChanged: (newCode) {
                                                  block.content = newCode;
                                                },
                                              ),
                                            );
                                          case NoteContentType.list:
                                            return ListWidget(
                                              type: block.metadata == 'numbered'
                                                  ? ListType.numbered
                                                  : ListType.bullet,
                                              onRemove: () =>
                                                  _showDeleteConfirmDialog(
                                                      index, 'liste'),
                                            );
                                          case NoteContentType.text:
                                            return Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 8),
                                              child: Text(block.content),
                                            );
                                        }
                                      }).toList(),
                                    ],
                                  ),
                                ),

                                // Alt bilgi çubuğu
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 6),
                                  decoration: const BoxDecoration(
                                    color: AppTheme.vsCodeDarkGrey,
                                    border: Border(
                                      top: BorderSide(
                                          color: AppTheme.vsCodeLightGrey,
                                          width: 1),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: AppTheme.vsCodeBlue
                                              .withOpacity(0.2),
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(
                                              Icons.access_time,
                                              size: 12,
                                              color: AppTheme.vsCodeLightBlue,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              'Son düzenleme: ${_note.dateModified.toString().substring(0, 16)}',
                                              style: const TextStyle(
                                                color: AppTheme.vsCodeLightBlue,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const Spacer(),
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.touch_app_outlined,
                                            size: 12,
                                            color: AppTheme.vsCodeLightGrey,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Silmek için uzun basın',
                                            style: TextStyle(
                                              color: AppTheme.vsCodeLightGrey,
                                              fontSize: 11,
                                              fontStyle: FontStyle.italic,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Text(
                                            '${_note.contentBlocks.length} ek',
                                            style: const TextStyle(
                                              color: AppTheme.vsCodeLightGrey,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton.small(
        onPressed: _saveNote,
        tooltip: 'Kaydet',
        elevation: 3,
        backgroundColor: AppTheme.vsCodeBlue,
        child: const Icon(Icons.save, size: 20),
      ),
    );
  }
}
