class GuestBookMessage {
  GuestBookMessage(
      {required this.id,
        required this.name,
        required this.message,
        required this.author});

  final String id;
  final String name;
  final String message;
  final String author;
}