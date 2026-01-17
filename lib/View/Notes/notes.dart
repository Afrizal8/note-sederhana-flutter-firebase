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

  final TextEditingController title = TextEditingController();
  final TextEditingController content = TextEditingController();

  final repo = Repository();

  Future<void> _refreshNotes() async {
    final notesData = await repo.getNotes();
    setState(() {
      _notes = notesData;
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
    _refreshNotes();
    super.initState();
  }

  Future<void> _actionDialog({NotesModel? exitingNote}) async {
    if (exitingNote != null) {
      title.text = exitingNote.title ?? '';
      content.text = exitingNote.content ?? '';
    } else {
      title.clear();
      content.clear();
    }

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          actionsPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
          title: Text(exitingNote == null ? "New Note" : "Update Note"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 10,
            children: [
              TextField(
                controller: title,
                decoration: InputDecoration(hintText: "Title"),
              ),

              TextField(
                controller: content,
                decoration: InputDecoration(hintText: "Content"),
              ),
            ],
          ),

          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("Cancel"),
            ),

            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: WidgetStatePropertyAll(Colors.blue),
                foregroundColor: WidgetStatePropertyAll(Colors.white),
              ),
              onPressed: () async {
                final enteredTitle = title.text.trim();
                final enteredContent = content.text.trim();

                if (enteredContent.isEmpty || enteredTitle.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Fields are required")),
                  );
                }

                if (exitingNote != null) {
                  final updated = await repo.updateNote(
                    note: exitingNote.copyWith(
                      title: enteredTitle,
                      content: enteredContent,
                      createdAt: DateTime.now().toIso8601String(),
                    ),
                  );

                  if (updated) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Note updated successfully")),
                    );
                  }
                } else {
                  final result = await repo.addNote(
                    note: NotesModel(
                      title: enteredTitle,
                      content: enteredContent,
                      createdAt: DateTime.now().toIso8601String(),
                    ),
                  );
                  if (result.isNotEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Note added successfully")),
                    );
                  }
                }
                Navigator.of(context).pop();
                await _refreshNotes();
              },
              child: Text(exitingNote == null ? "CREATE" : "UPDATE"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => _actionDialog(),
        child: Icon(Icons.add),
      ),
      appBar: AppBar(title: Text("Notes")),

      body: _notes.isNotEmpty
          ? RefreshIndicator(
              onRefresh: _refreshNotes,
              child: ListView.builder(
                itemCount: _notes.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_notes[index].title ?? ''),
                    subtitle: Text(_notes[index].content ?? ''),
                    onTap: () => _actionDialog(exitingNote: _notes[index]),
                    trailing: IconButton(
                      onPressed: () async {
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: Text("Delete"),
                              content: Text("Do you want to delete this note?"),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(false),
                                  child: Text("Cancel"),
                                ),

                                ElevatedButton(
                                  style: ButtonStyle(
                                    backgroundColor: WidgetStatePropertyAll(
                                      Colors.red.shade900,
                                    ),
                                    foregroundColor: WidgetStatePropertyAll(
                                      Colors.white,
                                    ),
                                  ),
                                  onPressed: () =>
                                      Navigator.of(context).pop(true),
                                  child: Text("Delete"),
                                ),
                              ],
                            );
                          },
                        );

                        if (confirmed == true) {
                          final deleted = await repo.deleteNote(
                            docId: _notes[index].id!,
                          );
                          if (deleted) {
                            await _refreshNotes();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Deleted successfully")),
                            );
                          }
                        }
                      },
                      icon: Icon(Icons.delete),
                    ),
                  );
                },
              ),
            )
          : Center(child: Text("No data found")),
    );
  }
}
