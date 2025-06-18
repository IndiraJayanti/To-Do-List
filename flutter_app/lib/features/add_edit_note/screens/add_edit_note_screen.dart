import 'package:flutter/material.dart';
import 'package:flutter_app/graphql/query_mutation.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:flutter_app/features/add_edit_note/widgets/add_edit_note_form.dart';

class AddEditNoteScreen extends StatelessWidget {
  final Map<String, dynamic>? noteToEdit;
  const AddEditNoteScreen({super.key, this.noteToEdit});

  @override
  Widget build(BuildContext context) {
    final Color greenText = const Color(0xFF3F6B3F);
    final bool isEditing = noteToEdit != null;

    return Scaffold(
      appBar: _buildAppBar(context, greenText, isEditing),
      body: AddEditNoteForm(noteToEdit: noteToEdit),
    );
  }

  AppBar _buildAppBar(BuildContext context, Color greenText, bool isEditing) {
    return AppBar(
      backgroundColor: greenText,
      foregroundColor: Colors.white,
      centerTitle: true,
      title: Text(
        isEditing ? 'Edit Rencana' : 'Tambahkan Rencana',
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [if (isEditing) _buildDeleteButton(context, noteToEdit!)],
    );
  }

  Widget _buildDeleteButton(BuildContext context, Map<String, dynamic> note) {
    return Mutation(
      options: MutationOptions(
        document: gql(deleteNoteMutation),
        onCompleted: (data) {
          if (data != null && data['deleteNote'] == true) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Note deleted.')));
            Navigator.of(context).pop(true); // Pop and signal success
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Failed to delete note.')),
            );
          }
        },
        onError: (error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${error?.graphqlErrors.first.message}'),
            ),
          );
        },
      ),
      builder: (runMutation, result) {
        return IconButton(
          icon: const Icon(Icons.delete_outline),
          onPressed: () async {
            final confirm = await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Konfirmasi'),
                content: const Text('Yakin ingin menghapus note ini?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    child: const Text('Batal'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    child: const Text(
                      'Hapus',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            );
            if (confirm == true) {
              runMutation({'id': note['id']});
            }
          },
        );
      },
    );
  }
}
