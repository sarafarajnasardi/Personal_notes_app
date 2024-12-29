

import 'package:hive/hive.dart';

class ToDoDatabase {
  List toDoList = [];

  void loadData() {
    toDoList = Hive.box('mybox').get("TODOLIST", defaultValue: []);
  }

  void updateDataBase() {
    Hive.box('mybox').put("TODOLIST", toDoList);
  }
}
