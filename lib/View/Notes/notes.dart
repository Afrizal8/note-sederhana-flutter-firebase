import 'package:note/FirebaseServices/repository.dart';
import 'package:note/View/Notes/notes_model.dart';
import 'package:flutter/material.dart';

class Notes extends StatefulWidget {
  const Notes({super.key});

  @override
  State<Notes> createState() => _NotesState();
}

class _NotesState extends State<Notes> {
  List<NotesModel> _notes = [];
  bool _isLoading = false;

  final TextEditingController title = TextEditingController();
  final TextEditingController content = TextEditingController();

  final repo = Repository();

  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  Future<void> _refreshNotes() async {
    setState(() => _isLoading = true);
    final notesData = await repo.getNotes();
    setState(() {
      _notes = notesData;
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    title.dispose();
    content.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _refreshNotes();
  }

  Future<void> _actionDialog({NotesModel? existingNote}) async {
    if (existingNote != null) {
      title.text = existingNote.title ?? '';
      content.text = existingNote.content ?? '';
    } else {
      title.clear();
      content.clear();
    }

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 15,
            vertical: 15,
          ),
          actionsPadding: const EdgeInsets.symmetric(
            horizontal: 15,
            vertical: 10,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
          title: Text(existingNote == null ? "New Note" : "Update Note"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: title,
                decoration: const InputDecoration(
                  hintText: "Title",
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 10),
              TextField(
                controller: content,
                decoration: const InputDecoration(
                  hintText: "Content",
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
                textCapitalization: TextCapitalization.sentences,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              style: const ButtonStyle(
                backgroundColor: MaterialStatePropertyAll(Colors.blue),
                foregroundColor: MaterialStatePropertyAll(Colors.white),
              ),
              onPressed: () async {
                final enteredTitle = title.text.trim();
                final enteredContent = content.text.trim();

                if (enteredContent.isEmpty || enteredTitle.isEmpty) {
                  _scaffoldMessengerKey.currentState?.showSnackBar(
                    const SnackBar(
                      content: Text("Title and Content are required"),
                    ),
                  );
                  return;
                }

                if (existingNote != null) {
                  final updated = await repo.updateNote(
                    note: existingNote.copyWith(
                      title: enteredTitle,
                      content: enteredContent,
                      createdAt: DateTime.now().toIso8601String(),
                    ),
                  );

                  if (updated && mounted) {
                    _scaffoldMessengerKey.currentState?.showSnackBar(
                      const SnackBar(
                        content: Text("Note updated successfully"),
                      ),
                    );
                    Navigator.of(context).pop();
                    await _refreshNotes();
                  }
                } else {
                  final result = await repo.addNote(
                    note: NotesModel(
                      title: enteredTitle,
                      content: enteredContent,
                      createdAt: DateTime.now().toIso8601String(),
                    ),
                  );

                  if (result.isNotEmpty && mounted) {
                    _scaffoldMessengerKey.currentState?.showSnackBar(
                      const SnackBar(content: Text("Note added successfully")),
                    );
                    Navigator.of(context).pop();
                    await _refreshNotes();
                  }
                }
              },
              child: Text(existingNote == null ? "CREATE" : "UPDATE"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: _scaffoldMessengerKey,
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () => _actionDialog(),
          child: const Icon(Icons.add),
        ),
        appBar: AppBar(
          title: const Text("Notes"),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _refreshNotes,
            ),
          ],
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _notes.isNotEmpty
            ? RefreshIndicator(
                onRefresh: _refreshNotes,
                child: ListView.builder(
                  itemCount: _notes.length,
                  itemBuilder: (context, index) {
                    final note = _notes[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      child: ListTile(
                        title: Text(
                          note.title ?? 'No Title',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              note.content ?? '',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              note.createdAt ?? '',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        onTap: () => _actionDialog(existingNote: note),
                        trailing: IconButton(
                          onPressed: () async {
                            final confirmed = await showDialog<bool>(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: const Text("Delete Note"),
                                  content: const Text(
                                    "Are you sure you want to delete this note?",
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(false),
                                      child: const Text("Cancel"),
                                    ),
                                    ElevatedButton(
                                      style: ButtonStyle(
                                        backgroundColor:
                                            MaterialStatePropertyAll(
                                              Colors.red.shade900,
                                            ),
                                        foregroundColor:
                                            const MaterialStatePropertyAll(
                                              Colors.white,
                                            ),
                                      ),
                                      onPressed: () =>
                                          Navigator.of(context).pop(true),
                                      child: const Text("Delete"),
                                    ),
                                  ],
                                );
                              },
                            );

                            if (confirmed == true && note.id != null) {
                              final deleted = await repo.deleteNote(
                                docId: note.id!,
                              );
                              if (deleted && mounted) {
                                await _refreshNotes();
                                _scaffoldMessengerKey.currentState
                                    ?.showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          "Note deleted successfully",
                                        ),
                                      ),
                                    );
                              }
                            }
                          },
                          icon: const Icon(Icons.delete, color: Colors.red),
                        ),
                      ),
                    );
                  },
                ),
              )
            : const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.note_outlined, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      "No notes yet",
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Tap + to create your first note",
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
