import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_app/graphql/query_mutation.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class AddEditNoteForm extends StatefulWidget {
  final Map<String, dynamic>? noteToEdit;
  const AddEditNoteForm({super.key, this.noteToEdit});

  @override
  State<AddEditNoteForm> createState() => _AddEditNoteFormState();
}

class _AddEditNoteFormState extends State<AddEditNoteForm> {
  final _titleController = TextEditingController();
  bool _isFavorite = false;
  int? _selectedCategoryId;
  String? _currentUserId;
  bool _isLoading = true;
  bool _isEditing = false;
  List<dynamic> _categories = [];
  bool _initialDataLoaded = false;
  List<TextEditingController> _checklistControllers = [];
  List<bool> _isCheckedList = [];
  DateTime? _selectedDateTime;
  List<String> _collaborators = [
    'gekina01@gmail.com',
    'christianprtii@gmail.com',
    'indiratrij@gmail.com',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.noteToEdit != null) {
      _isEditing = true;
      _titleController.text = widget.noteToEdit!['title'];
      _isFavorite = widget.noteToEdit!['isFavorite'] ?? false;
      final String content = widget.noteToEdit!['content'] ?? '';
      final List<String> lines = content
          .split('\n')
          .where((s) => s.trim().isNotEmpty)
          .toList();
      if (lines.isNotEmpty) {
        for (var line in lines) {
          bool isChecked = line.startsWith('[x] ');
          String text = isChecked
              ? line.substring(4)
              : (line.startsWith('[ ] ') ? line.substring(4) : line);
          _checklistControllers.add(TextEditingController(text: text));
          _isCheckedList.add(isChecked);
        }
      } else {
        _addChecklistField();
      }
      if (widget.noteToEdit!['category'] != null) {
        _selectedCategoryId = int.tryParse(
          widget.noteToEdit!['category']['id'].toString(),
        );
      }
      // Load existing reminder time if editing
      if (widget.noteToEdit!['reminderTime'] != null && widget.noteToEdit!['reminderTime'].isNotEmpty) {
        try {
          _selectedDateTime = DateTime.parse(widget.noteToEdit!['reminderTime']).toUtc().toLocal();
        } catch (e) {
          print('Error parsing reminderTime: $e');
          _selectedDateTime = null;
        }
      }
    } else {
      _addChecklistField();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialDataLoaded) {
      _loadInitialData();
      _initialDataLoaded = true;
    }
  }

  Future<void> _loadInitialData() async {
    await _loadCurrentUser();
    await _loadCategories();
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadCurrentUser() async {
    if (!_isEditing) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('jwt_token');
      if (token != null) {
        try {
          final parts = token.split('.');
          if (parts.length != 3) throw const FormatException('Invalid token');
          final payload = jsonDecode(
            utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
          );
          _currentUserId = payload['userID']?.toString();
        } catch (e) {
          print('Error decoding token: $e');
        }
      }
    }
  }

  Future<void> _loadCategories() async {
    final client = GraphQLProvider.of(context).value;
    final QueryResult result = await client.query(
      QueryOptions(
        document: gql(allCategoriesQuery),
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );
    if (mounted && result.data?['categories'] != null) {
      setState(() {
        _categories = result.data!['categories'];
        if (_selectedCategoryId == null && _categories.isNotEmpty) {
          _selectedCategoryId = int.tryParse(
            _categories.first['id'].toString(),
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    for (var controller in _checklistControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addChecklistField() {
    setState(() {
      _checklistControllers.add(TextEditingController());
      _isCheckedList.add(false);
    });
  }

  void _removeChecklistField(int index) {
    if (_checklistControllers.length > 1) {
      setState(() {
        _checklistControllers[index].dispose();
        _checklistControllers.removeAt(index);
        _isCheckedList.removeAt(index);
      });
    }
  }

  Future<void> _pickDateTime(BuildContext context) async {
    final DateTime initialDateTimeForPicker = _selectedDateTime?.toLocal() ?? DateTime.now().toLocal();

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDateTimeForPicker,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null && mounted) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(
          initialDateTimeForPicker,
        ),
      );
      if (pickedTime != null) {
        setState(() {
          _selectedDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  void _showCollaboratorDialog() {
    final Color greenText = const Color(0xFF3F6B3F);
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final collaboratorInputController = TextEditingController();

            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Collaborators',
                      style: TextStyle(
                        color: greenText,
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: _collaborators.map((email) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.person_rounded,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 12),
                              Expanded(child: Text(email)),
                              IconButton(
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                icon: const Icon(
                                  Icons.close,
                                  color: Colors.grey,
                                ),
                                onPressed: () {
                                  setDialogState(() {
                                    _collaborators.remove(email);
                                  });
                                },
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                    const Divider(height: 24),
                    TextField(
                      controller: collaboratorInputController,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.person_add_alt_1),
                        hintText: 'Person or email to share with',
                        border: OutlineInputBorder(),
                      ),
                      onSubmitted: (value) {
                        if (value.isNotEmpty) {
                          setDialogState(() {
                            _collaborators.add(value);
                          });
                          collaboratorInputController.clear();
                        }
                      },
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            'Cancel',
                            style: TextStyle(color: greenText),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: greenText,
                          ),
                          child: const Text(
                            'Save',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color greenText = const Color(0xFF3F6B3F);
    final Color pastelGreen = const Color(0xFFCDEAC0);

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            children: [
              _buildTextFieldWithLabel(
                'Judul Rencana',
                _titleController,
                'Masukkan Judul',
                pastelGreen,
                greenText,
              ),
              const SizedBox(height: 24),
              Text(
                'Checklist Rencana',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: greenText,
                ),
              ),
              const SizedBox(height: 8),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _checklistControllers.length,
                itemBuilder: (context, index) {
                  return _buildChecklistItem(pastelGreen, greenText, index);
                },
              ),
              TextButton.icon(
                onPressed: _addChecklistField,
                icon: Icon(Icons.add, color: greenText),
                label: Text('Tambah Item', style: TextStyle(color: greenText)),
              ),
              const SizedBox(height: 16),
              _buildCategoryDropdown(greenText, pastelGreen),
              const SizedBox(height: 20),
              _buildReminderPicker(
                context,
                'Pengingat',
                pastelGreen,
                greenText,
              ),
              const SizedBox(height: 20),
              _buildFavoriteSwitch(greenText),
              const SizedBox(height: 20),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(20),
          child: _buildActionButtons(context, greenText, pastelGreen),
        ),
      ],
    );
  }

  Widget _buildTextFieldWithLabel(
    String label,
    TextEditingController controller,
    String hint,
    Color bgColor,
    Color textColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: hint,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChecklistItem(Color bgColor, Color textColor, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Checkbox(
              value: _isCheckedList[index],
              onChanged: (bool? newValue) =>
                  setState(() => _isCheckedList[index] = newValue ?? false),
              activeColor: textColor,
            ),
            Expanded(
              child: TextField(
                controller: _checklistControllers[index],
                style: TextStyle(
                  decoration: _isCheckedList[index]
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                  color: _isCheckedList[index] ? Colors.grey[600] : textColor,
                ),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Item #${index + 1}',
                ),
              ),
            ),
            if (_checklistControllers.length > 1)
              IconButton(
                icon: const Icon(
                  Icons.remove_circle_outline,
                  color: Colors.redAccent,
                ),
                onPressed: () => _removeChecklistField(index),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryDropdown(Color greenText, Color pastelGreen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Kategori',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: greenText,
          ),
        ),
        const SizedBox(height: 8),
        if (_categories.isNotEmpty)
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: pastelGreen,
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: _selectedCategoryId,
                isExpanded: true,
                dropdownColor: pastelGreen,
                items: _categories
                    .map<DropdownMenuItem<int>>(
                      (category) => DropdownMenuItem<int>(
                        value: int.tryParse(category['id'].toString()),
                        child: Text(
                          category['name'],
                          style: TextStyle(color: greenText),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (int? newValue) =>
                    setState(() => _selectedCategoryId = newValue),
              ),
            ),
          )
        else
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              color: pastelGreen,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              "Memuat kategori...",
              style: TextStyle(color: greenText.withOpacity(0.7)),
            ),
          ),
      ],
    );
  }

  Widget _buildReminderPicker(
    BuildContext context,
    String label,
    Color bgColor,
    Color textColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => _pickDateTime(context),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _selectedDateTime != null
                      ? DateFormat(
                          'dd MMM, HH:mm',
                        ).format(_selectedDateTime!)
                      : 'Pilih tanggal & waktu',
                  style: TextStyle(color: textColor),
                ),
                Icon(Icons.calendar_today, color: textColor),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFavoriteSwitch(Color greenText) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Tandai sebagai Favorit',
          style: TextStyle(fontSize: 16, color: greenText),
        ),
        Switch(
          value: _isFavorite,
          onChanged: (value) => setState(() => _isFavorite = value),
          activeColor: greenText,
        ),
      ],
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    Color greenText,
    Color pastelGreen,
  ) {
    return Row(
      children: [
        Expanded(child: _buildSaveButton(greenText)),
        const SizedBox(width: 10),
        SizedBox(
          height: 50,
          width: 50,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: pastelGreen,
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
            onPressed: _showCollaboratorDialog,
            child: Icon(Icons.person_add, color: greenText),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton(Color greenText) {
    return Mutation(
      options: MutationOptions(
        document: gql(_isEditing ? updateNoteMutation : createNoteMutation),
        onCompleted: (resultData) {
          if (!mounted) return;
          final key = _isEditing ? 'updateNote' : 'createNote';
          if (resultData != null && resultData[key] != null) {
            final message = _isEditing
                ? 'Note updated successfully!'
                : 'Note created successfully!';
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(message)));
            Navigator.pop(context, true);
          } else {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Operation failed.')));
          }
        },
        onError: (error) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Error: ${error?.graphqlErrors.first.message ?? 'Unknown error'}',
              ),
            ),
          );
        },
      ),
      builder: (runMutation, result) {
        bool isMutationLoading = result?.isLoading ?? false;
        return SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: greenText,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: isMutationLoading
                ? null
                : () {
                    if (_titleController.text.trim().isEmpty ||
                        _selectedCategoryId == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Judul dan Kategori harus diisi!'),
                        ),
                      );
                      return;
                    }
                    final String content = _checklistControllers
                        .asMap()
                        .entries
                        .map((entry) {
                          int idx = entry.key;
                          String text = entry.value.text.trim();
                          if (text.isEmpty) return null;
                          return (_isCheckedList[idx] ? '[x] ' : '[ ] ') + text;
                        })
                        .where((s) => s != null)
                        .join('\n');

                    String? formattedReminderTime;
                    if (_selectedDateTime != null) {
                      formattedReminderTime = _selectedDateTime!.toUtc().toIso8601String();
                    }

                    final Map<String, dynamic> variables = {
                      'title': _titleController.text.trim(),
                      'content': content,
                      'isFavorite': _isFavorite,
                      'idCategory': _selectedCategoryId.toString(),
                      'reminderTime': formattedReminderTime,
                    };
                    if (_isEditing) {
                      variables['id'] = widget.noteToEdit!['id'];
                    } else {
                      variables['createdBy'] = _currentUserId;
                    }
                    runMutation(variables);
                  },
            child: isMutationLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 3,
                    ),
                  )
                : Text(
                    _isEditing ? 'Save Changes' : 'Save Note',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
          ),
        );
      },
    );
  }
}