import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/note.dart';

class NotesService {
  static const String _notesKey = 'notes';

  Future<List<Note>> getNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final notesJson = prefs.getStringList(_notesKey) ?? [];
    
    return notesJson
        .map((noteJson) => Note.fromJson(jsonDecode(noteJson)))
        .toList();
  }

  Future<void> saveNote(Note note) async {
    final prefs = await SharedPreferences.getInstance();
    final notes = await getNotes();
    
    // Update if exists, otherwise add
    final index = notes.indexWhere((n) => n.id == note.id);
    if (index >= 0) {
      notes[index] = note;
    } else {
      notes.add(note);
    }
    
    await _saveNotes(prefs, notes);
  }

  Future<void> deleteNote(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final notes = await getNotes();
    
    notes.removeWhere((note) => note.id == id);
    await _saveNotes(prefs, notes);
  }

  Future<void> _saveNotes(SharedPreferences prefs, List<Note> notes) async {
    final notesJson = notes
        .map((note) => jsonEncode(note.toJson()))
        .toList();
    
    await prefs.setStringList(_notesKey, notesJson);
  }
} 