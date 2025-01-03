import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:hive/hive.dart';
import 'package:notes_task/data/data_base.dart';
import 'package:notes_task/pages/notes.dart';
import '../components/to_do_list.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _myBox = Hive.box('mybox');
  final ToDoDatabase db = ToDoDatabase();
  final TextEditingController _taskController = TextEditingController();
  final TextEditingController _datepickController = TextEditingController();

  int _selectedindex = 0; 
  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    if (_myBox.get("TODOLIST") == null) {
    } else {
      db.loadData();
      db.toDoList = db.toDoList.map((task) {
        if (task.length < 3) task.add("Long Battle!");
        return task;
      }).toList();
    }
    _sortTasksByDate();
  }

  void _sortTasksByDate() {
    db.toDoList.sort((a, b) {
      DateTime dateA = DateTime.tryParse(a[2]) ?? DateTime(2100, 1, 1);
      DateTime dateB = DateTime.tryParse(b[2]) ?? DateTime(2100, 1, 1);
      return dateA.compareTo(dateB);
    });
  }

  @override
  void dispose() {
    _taskController.dispose();
    _datepickController.dispose();
    super.dispose();
  }

  void _toggleTaskCompletion(bool? value, int index) {
    setState(() {
      db.toDoList[index][1] = value ?? false; 
    });
    db.updateDataBase();
  }

  Future<void> _selectDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      setState(() {
        _datepickController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
      });
    }
  }

  Future<void> _deleteTask(int index) async {
    bool? confirmDelete = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Task"),
        content: const Text("Are you sure you want to delete this task?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmDelete == true) {
      setState(() {
        db.toDoList.removeAt(index);
      });
      _sortTasksByDate();
      db.updateDataBase();
    }
  }

  void _createNewTask() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
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
                _buildDialogTitle("New task for glory!"),
                _buildTextField("Enter your next task...", _taskController, false),
                const SizedBox(height: 20),
                _buildDateField(),
                const SizedBox(height: 20),
                _buildDialogActions(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDialogTitle(String title) {
    return Text(
      title,
      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.greenAccent),
    );
  }

  Widget _buildTextField(String hint, TextEditingController controller, bool readOnly) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.grey.shade800,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[400]),
      ),
      minLines: 1,
      style: const TextStyle(color: Colors.white),
      readOnly: readOnly,
    );
  }

  Widget _buildDateField() {
    return TextField(
      controller: _datepickController,
      decoration: InputDecoration(
        hintText: "When to conquer?",
        filled: true,
        fillColor: Colors.grey.shade800,
        prefixIcon: const Icon(Icons.calendar_today, color: Colors.white70),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        hintStyle: TextStyle(color: Colors.grey[400]),
      ),
      style: const TextStyle(color: Colors.white),
      readOnly: true,
      onTap: _selectDate,
    );
  }

  Row _buildDialogActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("Cancel", style: TextStyle(color: Colors.white70)),
        ),
        ElevatedButton.icon(
          onPressed: _saveTask,
          label: const Text("Save"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.greenAccent[200],
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }

  void _saveTask() {
    if (_taskController.text.isNotEmpty) {
      setState(() {
        db.toDoList.add([
          _taskController.text,
          false,
          _datepickController.text.isEmpty ? 'No Date' : _datepickController.text,
        ]);
        _sortTasksByDate();
        db.updateDataBase();
      });
      _taskController.clear();
      _datepickController.clear();
      Navigator.of(context).pop();
    }
  }

  // Navigate between pages
  void _navigate(int index) {
    setState(() {
      _selectedindex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: GNav(
        onTabChange: _navigate,
        padding: EdgeInsets.symmetric(horizontal: 65, vertical: 15),
        gap: 8,
        iconSize: 24,
        tabBackgroundColor: Colors.blueGrey,
        tabs: const [
          GButton(
            icon: Icons.task_outlined,
            text: "Tasks",
          ),
          GButton(
            icon: Icons.sticky_note_2_sharp,
            text: "Notes",
          ),
        ],
      ),
      backgroundColor: Colors.blueGrey[900],

      body: _selectedindex == 0 ? taskPage() : const NotesPage(),

    );
  }

  // Task page layout
  Widget taskPage() {
    return Column(
      
      children: [

        Container(
          height: 100,
          padding: const EdgeInsets.only(left: 8, right: 8, top: 50, bottom: 0),
          color: Colors.blueGrey[900],
          child: const Center(
            child: Text(
              'Tasks',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
        Expanded(
          child: db.toDoList.isEmpty
              ? Center(
            child: Text(
              "No tasks found!",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          )
              : ListView.builder(
            itemCount: db.toDoList.length,
            itemBuilder: (context, index) {
              return ToDoList(
                name: db.toDoList[index][0],
                isComplete: db.toDoList[index][1],
                onChanged: (value) => _toggleTaskCompletion(value, index),
                onDelete: () => _deleteTask(index),
                onDue: db.toDoList[index][2],
              );
            },
          ),

        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Align(
            alignment: Alignment.bottomRight,
            child: ElevatedButton(
              onPressed: _createNewTask,
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
    );
  }
}
