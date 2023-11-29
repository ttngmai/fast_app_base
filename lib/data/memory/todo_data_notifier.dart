import 'package:fast_app_base/data/memory/v_todo.dart';
import 'package:flutter/cupertino.dart';

class TodoDataNotifier extends ValueNotifier<List<Todo>> {
  TodoDataNotifier() : super([]);

  void addTodo(Todo todo) {
    value.add(todo);
    notifyListeners();
  }

  void notify() {
    notifyListeners();
  }
}