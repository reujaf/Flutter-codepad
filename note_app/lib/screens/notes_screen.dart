import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/note.dart';
import '../services/notes_service.dart';
import '../theme/app_theme.dart';
import 'note_detail_screen.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({Key? key}) : super(key: key);

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen>
    with SingleTickerProviderStateMixin {
  final NotesService _notesService = NotesService();
  List<Note> _notes = [];
  List<Note> _filteredNotes = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadNotes();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadNotes() async {
    setState(() {
      _isLoading = true;
    });

    final notes = await _notesService.getNotes();

    setState(() {
      _notes = notes;
      _filteredNotes = notes;
      _isLoading = false;
    });
  }

  Future<void> _deleteNote(String id) async {
    await _notesService.deleteNote(id);
    await _loadNotes();
  }

  void _filterNotes(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredNotes = _notes;
      } else {
        _filteredNotes = _notes
            .where((note) =>
                note.title.toLowerCase().contains(query.toLowerCase()) ||
                note.content.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.vsCodeBlue.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.code,
                color: AppTheme.vsCodeLightBlue,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text('VS Code Not Defteri'),
          ],
        ),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(110),
          child: Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppTheme.vsCodeDarkGrey,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Notları ara...',
                      prefixIcon: const Icon(Icons.search,
                          color: AppTheme.vsCodeLightBlue),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear,
                                  color: AppTheme.vsCodeLightBlue),
                              onPressed: () {
                                _searchController.clear();
                                _filterNotes('');
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: AppTheme.vsCodeDarkGrey,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                            color: AppTheme.vsCodeBlue, width: 1.5),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 16),
                    ),
                    style: const TextStyle(
                      color: AppTheme.vsCodeForeground,
                      fontSize: 15,
                    ),
                    onChanged: _filterNotes,
                  ),
                ),
              ),
              TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.list_alt),
                        SizedBox(width: 8),
                        Text('Tüm Notlar'),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.access_time),
                        SizedBox(width: 8),
                        Text('Son Eklenenler'),
                      ],
                    ),
                  ),
                ],
                indicatorColor: AppTheme.vsCodeBlue,
                indicatorWeight: 3,
                labelColor: AppTheme.vsCodeLightBlue,
                unselectedLabelColor: AppTheme.vsCodeLightGrey,
                labelStyle: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.vsCodeBlue))
          : TabBarView(
              controller: _tabController,
              children: [
                // Tab 1: Tüm Notlar
                _buildNotesList(_filteredNotes),

                // Tab 2: Son Eklenenler
                _buildNotesList(
                    _filteredNotes.isEmpty ? [] : List.from(_filteredNotes)
                      ..sort((a, b) => b.dateCreated.compareTo(a.dateCreated))
                      ..take(5)),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const NoteDetailScreen(),
            ),
          );
          if (result == true) {
            _loadNotes();
          }
        },
        backgroundColor: AppTheme.vsCodeBlue,
        icon: const Icon(Icons.add),
        label: const Text('Yeni Not'),
        elevation: 4,
      ),
    );
  }

  Widget _buildNotesList(List<Note> notes) {
    if (notes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.vsCodeDarkGrey.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.note_alt_outlined,
                size: 64,
                color: AppTheme.vsCodeLightGrey,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              _notes.isEmpty
                  ? 'Henüz not eklenmemiş.'
                  : 'Arama sonucu bulunamadı.',
              style: const TextStyle(
                color: AppTheme.vsCodeLightGrey,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 32),
            if (_notes.isEmpty)
              ElevatedButton.icon(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NoteDetailScreen(),
                    ),
                  );
                  if (result == true) {
                    _loadNotes();
                  }
                },
                icon: const Icon(Icons.add),
                label: const Text('İlk Notu Ekle'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.vsCodeBlue,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  textStyle: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                  elevation: 4,
                ),
              ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes[index];
        return Dismissible(
          key: Key(note.id),
          background: Container(
            color: AppTheme.vsCodeRed,
            margin: const EdgeInsets.only(bottom: 16),
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            child: const Icon(
              Icons.delete,
              color: Colors.white,
              size: 32,
            ),
          ),
          direction: DismissDirection.endToStart,
          confirmDismiss: (direction) async {
            return await showDialog(
              context: context,
              builder: (context) => AlertDialog(
                backgroundColor: AppTheme.vsCodeDarkGrey,
                title: const Text('Notu Sil'),
                content: Text(
                    '${note.title} notunu silmek istediğinize emin misiniz?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('İptal',
                        style: TextStyle(color: AppTheme.vsCodeLightBlue)),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text('Sil',
                        style: TextStyle(color: AppTheme.vsCodeRed)),
                  ),
                ],
              ),
            );
          },
          onDismissed: (direction) {
            _deleteNote(note.id);
          },
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.only(bottom: 16),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NoteDetailScreen(note: note),
                  ),
                );
                if (result == true) {
                  _loadNotes();
                }
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            note.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.vsCodeLightBlue,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppTheme.vsCodeBlue.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            DateFormat.yMMMd().format(note.dateModified),
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.vsCodeLightBlue,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      note.content,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.vsCodeForeground.withOpacity(0.8),
                      ),
                    ),
                    if (note.contentBlocks.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      const Divider(height: 1, color: AppTheme.vsCodeLightGrey),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          // Görsel sayısı
                          if (note.contentBlocks
                              .where((b) => b.type == NoteContentType.image)
                              .isNotEmpty)
                            Container(
                              margin: const EdgeInsets.only(right: 12),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppTheme.vsCodeBackground,
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                    color: AppTheme.vsCodeLightGrey
                                        .withOpacity(0.5)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.image,
                                    size: 14,
                                    color: AppTheme.vsCodeLightBlue,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${note.contentBlocks.where((b) => b.type == NoteContentType.image).length}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppTheme.vsCodeLightGrey,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          // Kod blokları sayısı
                          if (note.contentBlocks
                              .where((b) => b.type == NoteContentType.code)
                              .isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppTheme.vsCodeBackground,
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                    color: AppTheme.vsCodeLightGrey
                                        .withOpacity(0.5)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.code,
                                    size: 14,
                                    color: AppTheme.vsCodeLightBlue,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${note.contentBlocks.where((b) => b.type == NoteContentType.code).length}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppTheme.vsCodeLightGrey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
