enum CommandType { image, code, list, help, unknown }

class Command {
  final CommandType type;
  final String content;
  final Map<String, dynamic>? options;

  Command({
    required this.type,
    required this.content,
    this.options,
  });

  factory Command.parse(String input) {
    final trimmedInput = input.trim();

    if (trimmedInput == 'img') {
      return Command(
        type: CommandType.image,
        content: '',
      );
    } else if (trimmedInput == 'code') {
      return Command(
        type: CommandType.code,
        content: '',
      );
    } else if (trimmedInput == 'help') {
      return Command(
        type: CommandType.help,
        content: '',
      );
    } else if (trimmedInput.startsWith('list')) {
      // List komutunu parse et
      final parts = trimmedInput.split(' ');

      // Varsayılan olarak noktalı liste
      String listType = 'bullet';

      // Eğer "list 1" gibi bir komut ise numaralı liste olacak
      if (parts.length > 1 && parts[1] == '1') {
        listType = 'numbered';
      }

      return Command(
        type: CommandType.list,
        content: '',
        options: {
          'listType': listType,
        },
      );
    } else {
      return Command(
        type: CommandType.unknown,
        content: trimmedInput,
      );
    }
  }
}
