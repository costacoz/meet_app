import 'package:flutter/material.dart';
import 'package:gtk_flutter/src/widgets.dart';

class GuestBookMessageWidget extends StatelessWidget {
  final String name;
  final String message;
  final bool showDelete;
  final void Function() deleteMessageCallback;

  const GuestBookMessageWidget({
    required this.name,
    required this.message,
    required this.showDelete,
    required this.deleteMessageCallback,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Paragraph('$name: $message'),
        if (showDelete)
          TextButton.icon(
            onPressed: deleteMessageCallback,
            icon: const Icon(Icons.delete_forever),
            label: const Text('Delete'),
          ),
      ],
    );
  }
}
