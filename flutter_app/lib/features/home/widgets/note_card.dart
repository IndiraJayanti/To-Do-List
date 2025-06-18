import 'package:flutter/material.dart';

class NoteCard extends StatelessWidget {
  final Map<String, dynamic> note;
  final Color pastelGreen;
  final Color greenText;
  final Widget favoriteButton;
  final Widget editButton;
  final Widget deleteButton;

  const NoteCard({
    super.key,
    required this.note,
    required this.pastelGreen,
    required this.greenText,
    required this.favoriteButton,
    required this.editButton,
    required this.deleteButton,
  });

  @override
  Widget build(BuildContext context) {
    final List<String> lines = (note['content'] as String? ?? '')
        .split('\n')
        .where((s) => s.trim().isNotEmpty)
        .toList();

    return Container(
      decoration: BoxDecoration(
        color: pastelGreen,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  note['title'] ?? 'No Title', // Fallback jika judul null
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: greenText,
                    fontSize: 16,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: 24, height: 24, child: favoriteButton),
            ],
          ),
          const SizedBox(height: 8),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: lines.map((line) {
                  final isChecked = line.startsWith('[x] ');
                  final text = isChecked
                      ? line.substring(4)
                      : (line.startsWith('[ ] ') ? line.substring(4) : line);

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2.0),
                    child: Row(
                      children: [
                        Icon(
                          isChecked
                              ? Icons.check_box
                              : Icons.check_box_outline_blank,
                          size: 16,
                          color: greenText,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            text,
                            style: TextStyle(
                              color: greenText,
                              decoration: isChecked
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [editButton, deleteButton],
          ),
        ],
      ),
    );
  }
}
