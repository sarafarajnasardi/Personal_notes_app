import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  final _myBox = Hive.box('mybox');
  List<List<String>> _notesList = [];

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  void _loadNotes() {
    if (_myBox.get("NOTESLIST") != null) {
      setState(() {
        _notesList = List<List<String>>.from(_myBox.get("NOTESLIST"));
      });
      _sortNotesByDate();
    }
  }

  void _sortNotesByDate() {
    _notesList.sort((a, b) {
      DateTime dateA = DateTime.tryParse(a[2]) ?? DateTime(2100, 1, 1);
      DateTime dateB = DateTime.tryParse(b[2]) ?? DateTime(2100, 1, 1);
      return dateB.compareTo(dateA);
    });
  }

  void _showNoteDetails(int index) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade900,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _notesList[index][0],
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.greenAccent,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                _notesList[index][2],
                style: TextStyle(
                  color: Colors.grey[400],
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                _notesList[index][1],
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text("Close", style: TextStyle(color: Colors.white70)),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _editNote(index);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.greenAccent[200],
                      foregroundColor: Colors.black,
                    ),
                    child: const Text("Edit"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _editNote(int index) {
    _titleController.text = _notesList[index][0];
    _contentController.text = _notesList[index][1];

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade900,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Edit Note",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.greenAccent,
                ),
              ),
              const SizedBox(height: 20),
              _buildTextField(_titleController, "Title"),
              const SizedBox(height: 20),
              _buildTextField(_contentController, "Content", maxLines: 4),
              const SizedBox(height: 20),
              _buildDialogButtons(() {
                setState(() {
                  _notesList[index] = [
                    _titleController.text,
                    _contentController.text,
                    _notesList[index][2],
                  ];
                  _myBox.put("NOTESLIST", _notesList);
                });
                _clearControllers();
                Navigator.of(context).pop();
              }),
            ],
          ),
        ),
      ),
    );
  }

  void _createNewNote() {
    _clearControllers();

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade900,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "New Note",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.greenAccent,
                ),
              ),
              const SizedBox(height: 20),
              _buildTextField(_titleController, "Note Title"),
              const SizedBox(height: 20),
              _buildTextField(_contentController, "Note Content", maxLines: 4),
              const SizedBox(height: 20),
              _buildDialogButtons(() {
                if (_titleController.text.isNotEmpty) {
                  setState(() {
                    _notesList.add([
                      _titleController.text,
                      _contentController.text,
                      DateFormat('yyyy-MM-dd').format(DateTime.now()),
                    ]);
                    _myBox.put("NOTESLIST", _notesList);
                  });
                  _clearControllers();
                  Navigator.of(context).pop();
                }
              }),
            ],
          ),
        ),
      ),
    );
  }

  void _deleteNote(int index) {
    setState(() {
      _notesList.removeAt(index);
      _myBox.put("NOTESLIST", _notesList);
    });
  }

  void _clearControllers() {
    _titleController.clear();
    _contentController.clear();
  }

  Widget _buildTextField(TextEditingController controller, String hint, {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[400]),
        filled: true,
        fillColor: Colors.grey.shade800,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      style: const TextStyle(color: Colors.white),
    );
  }

  Widget _buildDialogButtons(VoidCallback onSave) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("Cancel", style: TextStyle(color: Colors.white70)),
        ),
        ElevatedButton(
          onPressed: onSave,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.greenAccent[200],
            foregroundColor: Colors.black,
          ),
          child: const Text("Save"),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[900],
      body: Column(
        children: [
          Container(
            height: 100,
            padding: const EdgeInsets.only(left: 8, right: 8, top: 50, bottom: 0),
            color: Colors.blueGrey[900],
            child: const Center(
              child: Text(
                'Notes',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Expanded(
            child: _notesList.isEmpty
                ? const Center(
              child: Text(
                "No notes yet!",
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            )
                : ListView.builder(
              itemCount: _notesList.length,
              itemBuilder: (context, index) => _buildNoteCard(index),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Align(
              alignment: Alignment.bottomRight,
              child: ElevatedButton(
                onPressed: _createNewNote,
                child: const Icon(Icons.add, size: 28),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.greenAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: EdgeInsets.all(17),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoteCard(int index) {
    return Dismissible(
      key: Key(_notesList[index][0] + index.toString()),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) => _deleteNote(index),
      child: Card(
        elevation: 5,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        color: Colors.grey.shade800,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
    child: IntrinsicHeight(
        child: ListTile(
          title: Text(
            _notesList[index][0],
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(
            _notesList[index][1],
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Colors.grey[400]),
          ),
          trailing: IconButton(
            icon: const Icon(Icons.delete, color: Colors.redAccent),
            onPressed: () => _deleteNote(index),
          ),
          onTap: () => _showNoteDetails(index),
        ),
    )
      ),
    );
  }
}
