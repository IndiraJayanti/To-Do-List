// home_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_app/graphql/query_mutation.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:flutter_app/features/add_edit_note/screens/add_edit_note_screen.dart';
import 'package:flutter_app/features/profile/screens/profile_screen.dart';
import 'package:flutter_app/features/diskusi/screens/diskusi_screen.dart';
import '../widgets/home_header.dart';
import '../widgets/category_button.dart';
import '../widgets/search_bar.dart' as custom;
import '../widgets/note_card.dart';
import '../widgets/home_bottom_nav.dart';
import 'package:flutter_app/features/home/widgets/floating_reminder_banner.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  int _bottomNavIndex = 0;
  String _selectedCategory = 'Semua';
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  VoidCallback? _refetchNotes;
  List _allNotesCache = [];

  Set<int> _remindersShownCurrentMinute = {};
  DateTime? _currentMinuteBoundary;

  Timer? _periodicReminderChecker;
  OverlayEntry? _notificationOverlayEntry;
  AnimationController? _notificationAnimationController;
  Timer? _notificationDismissTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _searchController.addListener(() {
      if (mounted) {
        setState(() => _searchQuery = _searchController.text);
      }
    });

    _periodicReminderChecker = Timer.periodic(const Duration(seconds: 5), (
      timer,
    ) {
      if (mounted && _bottomNavIndex == 0) {
        _checkReminders();
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _checkReminders();
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _clearReminderTracking();
      _checkReminders();
    } else if (state == AppLifecycleState.paused) {
      _removeFloatingNotification();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _searchController.dispose();
    _periodicReminderChecker?.cancel();
    _removeFloatingNotification();
    super.dispose();
  }

  void _clearReminderTracking() {
    final now = DateTime.now().toLocal();
    final newMinuteBoundary = DateTime(
      now.year,
      now.month,
      now.day,
      now.hour,
      now.minute,
    );

    if (_currentMinuteBoundary == null ||
        !_currentMinuteBoundary!.isAtSameMomentAs(newMinuteBoundary)) {
      if (mounted) {
        setState(() {
          _remindersShownCurrentMinute.clear();
          _currentMinuteBoundary = newMinuteBoundary;
        });
        print(
          'Reminder tracking cleared for new minute: $_currentMinuteBoundary',
        );
      }
    }
  }

  void _checkReminders({bool forceShow = false}) {
    _clearReminderTracking();

    final now = DateTime.now().toLocal();
    List<Map<String, dynamic>> remindersToTrigger = [];

    for (var note in _allNotesCache) {
      if (note['reminderTime'] != null && note['reminderTime'].isNotEmpty) {
        try {
          final reminderDateTime = DateTime.parse(
            note['reminderTime'],
          ).toLocal();

          bool isDueThisMinute =
              reminderDateTime.year == now.year &&
              reminderDateTime.month == now.month &&
              reminderDateTime.day == now.day &&
              reminderDateTime.hour == now.hour &&
              reminderDateTime.minute == now.minute;

          bool wasDueLastMinuteAndEarlyInThisMinute =
              reminderDateTime.year == now.year &&
              reminderDateTime.month == now.month &&
              reminderDateTime.day == now.day &&
              reminderDateTime.hour == now.hour &&
              reminderDateTime.minute == now.minute - 1 &&
              now.second < 10;

          bool alreadyShownThisMinute = _remindersShownCurrentMinute.contains(
            note['id'],
          );

          if ((isDueThisMinute || wasDueLastMinuteAndEarlyInThisMinute) &&
              (!alreadyShownThisMinute || forceShow)) {
            if (reminderDateTime.isAfter(
              now.subtract(const Duration(seconds: 5)),
            )) {
              remindersToTrigger.add(note);
              if (mounted) {
                _remindersShownCurrentMinute.add(note['id']);
              }
            }
          }
        } catch (e) {
          print('Error parsing reminderTime for check: $e');
        }
      }
    }

    if (remindersToTrigger.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _showFloatingNotification(remindersToTrigger);
        }
      });
    }
  }

  void _showFloatingNotification(List<Map<String, dynamic>> notes) {
    if (_notificationOverlayEntry != null) {
      _removeFloatingNotification();
    }

    if (!mounted) return;

    final note = notes.first;

    _notificationAnimationController ??= AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _notificationOverlayEntry = OverlayEntry(
      builder: (context) {
        return FloatingReminderBanner(
          note: note,
          animationController: _notificationAnimationController!,
          onDismiss: () {
            _removeFloatingNotification();
          },
        );
      },
    );

    Overlay.of(context).insert(_notificationOverlayEntry!);
    _notificationAnimationController!.forward();

    _notificationDismissTimer?.cancel();
    _notificationDismissTimer = Timer(const Duration(seconds: 5), () {
      if (mounted) {
        _removeFloatingNotification();
      }
    });
  }

  void _removeFloatingNotification() {
    _notificationDismissTimer?.cancel();
    if (_notificationOverlayEntry != null && mounted) {
      _notificationAnimationController?.reverse().then((_) {
        _notificationOverlayEntry?.remove();
        _notificationOverlayEntry = null;
        _notificationAnimationController?.dispose();
        _notificationAnimationController = null;
      });
    }
  }

  IconData _getCategoryIcon(String categoryName) {
    switch (categoryName) {
      case 'Pakaian':
        return Icons.checkroom;
      case 'Buku':
        return Icons.book;
      case 'Olahraga':
        return Icons.sports_baseball;
      case 'Kesehatan':
        return Icons.local_hospital;
      case 'Pekerjaan':
        return Icons.work;
      case 'Pribadi':
        return Icons.person;
      case 'Studi':
        return Icons.school;
      case 'Makanan':
        return Icons.local_dining;
      default:
        return Icons.label_outline;
    }
  }

  Widget _buildHomeNotesContent() {
    final Color pastelGreen = const Color(0xFFCDEAC0);
    final Color greenText = const Color(0xFF3F6B3F);

    return Query(
      options: QueryOptions(document: gql(allCategoriesQuery)),
      builder: (categoryResult, {refetch, fetchMore}) {
        List<Map<String, dynamic>> dynamicCategories = [];
        if (categoryResult.data?['categories'] != null) {
          dynamicCategories = List<Map<String, dynamic>>.from(
            categoryResult.data!['categories'].map(
              (cat) => {
                'label': cat['name'],
                'icon': _getCategoryIcon(cat['name']),
              },
            ),
          );
        }

        final allDisplayCategories = [
          {'label': 'Semua', 'icon': Icons.grid_view},
          {'label': 'Favorite', 'icon': Icons.favorite},
          ...dynamicCategories,
        ];

        return Query(
          options: QueryOptions(
            document: gql(allNotesQuery),
            fetchPolicy: FetchPolicy.cacheAndNetwork,
          ),
          builder: (noteResult, {refetch, fetchMore}) {
            _refetchNotes = refetch;
            if (noteResult.hasException) {
              return Center(
                child: Text('Error: ${noteResult.exception.toString()}'),
              );
            }

            if (noteResult.isLoading && _allNotesCache.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            if (noteResult.data?['notes'] != null) {
              _allNotesCache = noteResult.data!['notes'];
            }

            final filteredNotes = _allNotesCache.where((note) {
              final title = (note['title'] as String? ?? '').toLowerCase();
              final content = (note['content'] as String? ?? '').toLowerCase();
              final isFavorite = note['isFavorite'] as bool? ?? false;
              final categoryName = note['category']?['name'] as String? ?? '';
              final searchMatch =
                  title.contains(_searchQuery.toLowerCase()) ||
                  content.contains(_searchQuery.toLowerCase());
              if (!searchMatch) return false;
              if (_selectedCategory == 'Semua') return true;
              if (_selectedCategory == 'Favorite') return isFavorite;
              return categoryName == _selectedCategory;
            }).toList();

            filteredNotes.sort((a, b) {
              final dateA =
                  DateTime.tryParse(a['updatedAt'] ?? '') ?? DateTime(1970);
              final dateB =
                  DateTime.tryParse(b['updatedAt'] ?? '') ?? DateTime(1970);
              return dateB.compareTo(dateA);
            });

            return RefreshIndicator(
              color: greenText,
              backgroundColor: pastelGreen,
              onRefresh: () async {
                setState(() {
                  _allNotesCache = [];
                });
                await refetch?.call();
                _checkReminders();
              },
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Query(
                      options: QueryOptions(document: gql(meQuery)),
                      builder:
                          (
                            QueryResult result, {
                            VoidCallback? refetch,
                            FetchMore? fetchMore,
                          }) {
                            String? userName;
                            if (result.hasException) {
                              print(result.exception.toString());
                            }

                            if (!result.isLoading && result.data != null) {
                              userName = result.data?['me']?['name'];
                            }

                            return HomeHeader(
                              greenText: greenText,
                              onProfileTap: () =>
                                  setState(() => _bottomNavIndex = 2),
                              userName: userName,
                            );
                          },
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: _buildCategoryList(
                      allDisplayCategories,
                      greenText,
                      pastelGreen,
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                      child: custom.SearchBar(
                        controller: _searchController,
                        pastelGreen: pastelGreen,
                      ),
                    ),
                  ),
                  _buildNotesSliverGrid(filteredNotes, pastelGreen, greenText),
                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FFF7),
      body: SafeArea(
        child: IndexedStack(
          index: _bottomNavIndex,
          children: <Widget>[
            _buildHomeNotesContent(),
            const DiskusiScreen(),
            const ProfileScreen(),
          ],
        ),
      ),
      floatingActionButton: _bottomNavIndex == 0
          ? _buildFloatingActionButton(
              context,
              const Color(0xFFCDEAC0),
              const Color(0xFF3F6B3F),
            )
          : null,
      bottomNavigationBar: HomeBottomNav(
        currentIndex: _bottomNavIndex,
        onTap: (index) {
          setState(() => _bottomNavIndex = index);
          if (index == 0) {
            _checkReminders();
          } else {
            _removeFloatingNotification();
          }
        },
        greenText: const Color(0xFF3F6B3F),
      ),
    );
  }

  FloatingActionButton? _buildFloatingActionButton(
    BuildContext context,
    Color pastelGreen,
    Color greenText,
  ) {
    return FloatingActionButton(
      backgroundColor: pastelGreen,
      onPressed: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AddEditNoteScreen()),
        );
        if (result == true && mounted) {
          _refetchNotes?.call();
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              _checkReminders(forceShow: true);
            }
          });
        }
      },
      child: Icon(Icons.add, color: greenText, size: 28),
    );
  }

  Widget _buildCategoryList(
    List categories,
    Color greenText,
    Color pastelGreen,
  ) {
    return Container(
      height: 100,
      margin: const EdgeInsets.symmetric(vertical: 20),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final cat = categories[index];
          return CategoryButton(
            icon: cat['icon'],
            label: cat['label'],
            isSelected: _selectedCategory == cat['label'],
            onTap: () => setState(() => _selectedCategory = cat['label']),
            greenText: greenText,
            pastelGreen: pastelGreen,
          );
        },
      ),
    );
  }

  Widget _buildNotesSliverGrid(List notes, Color pastelGreen, Color greenText) {
    if (notes.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).size.height * 0.15,
          ),
          child: Center(
            child: Text(
              _searchQuery.isEmpty
                  ? 'Belum ada catatan. Ayo buat satu!'
                  : 'Catatan untuk "$_searchQuery" tidak ditemukan',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.8,
        ),
        delegate: SliverChildBuilderDelegate((context, index) {
          final note = notes[index];
          return NoteCard(
            note: note,
            pastelGreen: pastelGreen,
            greenText: greenText,
            favoriteButton: _buildFavoriteButton(note, greenText),
            editButton: _buildEditButton(note, greenText),
            deleteButton: _buildDeleteButton(note, greenText),
          );
        }, childCount: notes.length),
      ),
    );
  }

  Widget _buildFavoriteButton(Map<String, dynamic> note, Color greenText) {
    return Mutation(
      options: MutationOptions(
        document: gql(updateNoteMutation),
        onCompleted: (data) => _refetchNotes?.call(),
      ),
      builder: (runMutation, result) {
        return IconButton(
          icon: Icon(
            note['isFavorite'] == true ? Icons.favorite : Icons.favorite_border,
            color: greenText,
          ),
          onPressed: result?.isLoading ?? false
              ? null
              : () => runMutation({
                  'id': note['id'],
                  'isFavorite': !note['isFavorite'],
                }),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          iconSize: 20,
        );
      },
    );
  }

  Widget _buildEditButton(Map<String, dynamic> note, Color greenText) {
    return IconButton(
      icon: Icon(Icons.edit, size: 20, color: greenText.withOpacity(0.8)),
      onPressed: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AddEditNoteScreen(noteToEdit: note),
          ),
        );
        if (result == true && mounted) {
          _refetchNotes?.call();
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              _checkReminders(forceShow: true);
            }
          });
        }
      },
      padding: const EdgeInsets.all(4),
      constraints: const BoxConstraints(),
    );
  }

  Widget _buildDeleteButton(Map<String, dynamic> note, Color greenText) {
    return Mutation(
      options: MutationOptions(
        document: gql(deleteNoteMutation),
        onCompleted: (data) {
          if (data != null && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Note deleted.'),
                backgroundColor: Colors.red,
              ),
            );
            _refetchNotes?.call();
          }
        },
      ),
      builder: (runMutation, result) {
        return IconButton(
          icon: Icon(Icons.delete, size: 20, color: greenText.withOpacity(0.8)),
          onPressed: result?.isLoading ?? false
              ? null
              : () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Konfirmasi Hapus'),
                      content: const Text(
                        'Anda yakin ingin menghapus catatan ini?',
                      ),
                      actions: [
                        TextButton(
                          child: const Text('Batal'),
                          onPressed: () => Navigator.of(ctx).pop(),
                        ),
                        TextButton(
                          child: const Text(
                            'Hapus',
                            style: TextStyle(color: Colors.red),
                          ),
                          onPressed: () {
                            Navigator.of(ctx).pop();
                            runMutation({'id': note['id']});
                          },
                        ),
                      ],
                    ),
                  );
                },
          padding: const EdgeInsets.all(4),
          constraints: const BoxConstraints(),
        );
      },
    );
  }
}
