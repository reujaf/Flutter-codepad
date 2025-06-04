class Note {
  final String id;
  String title;
  String content;
  DateTime dateCreated;
  DateTime dateModified;
  List<NoteContent> contentBlocks;

  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.dateCreated,
    required this.dateModified,
    this.contentBlocks = const [],
  });

  factory Note.create({required String title, required String content}) {
    final now = DateTime.now();
    return Note(
      id: now.millisecondsSinceEpoch.toString(),
      title: title,
      content: content,
      dateCreated: now,
      dateModified: now,
      contentBlocks: [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'dateCreated': dateCreated.toIso8601String(),
      'dateModified': dateModified.toIso8601String(),
      'contentBlocks': contentBlocks.map((block) => block.toJson()).toList(),
    };
  }

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      dateCreated: DateTime.parse(json['dateCreated']),
      dateModified: DateTime.parse(json['dateModified']),
      contentBlocks: json.containsKey('contentBlocks')
          ? (json['contentBlocks'] as List)
              .map((blockJson) => NoteContent.fromJson(blockJson))
              .toList()
          : [],
    );
  }
}

enum NoteContentType {
  text,
  image,
  code,
  list,
}

class NoteContent {
  final String id;
  final NoteContentType type;
  String content;
  String? metadata; // Kod bloğu için dil, görsel için açıklama vs.

  NoteContent({
    required this.id,
    required this.type,
    required this.content,
    this.metadata,
  });

  factory NoteContent.text(String content) {
    return NoteContent(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: NoteContentType.text,
      content: content,
    );
  }

  factory NoteContent.image(String imageUrl) {
    return NoteContent(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: NoteContentType.image,
      content: imageUrl,
    );
  }

  factory NoteContent.code(String code, String language) {
    return NoteContent(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: NoteContentType.code,
      content: code,
      metadata: language,
    );
  }

  factory NoteContent.list(String listType) {
    return NoteContent(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: NoteContentType.list,
      content: '',
      metadata: listType,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.index,
      'content': content,
      'metadata': metadata,
    };
  }

  factory NoteContent.fromJson(Map<String, dynamic> json) {
    return NoteContent(
      id: json['id'],
      type: NoteContentType.values[json['type']],
      content: json['content'],
      metadata: json['metadata'],
    );
  }
}
