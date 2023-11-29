import 'package:fast_app_base/data/memory/bloc/bloc_status.dart';
import 'package:fast_app_base/data/memory/bloc/todo_bloc_state.dart';
import 'package:fast_app_base/data/memory/bloc/todo_event.dart';
import 'package:fast_app_base/data/memory/todo_status.dart';
import 'package:fast_app_base/data/memory/vo_todo.dart';
import 'package:fast_app_base/screen/dialog/d_confirm.dart';
import 'package:fast_app_base/screen/main/write/d_write_todo.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TodoBloc extends Bloc<TodoEvent, TodoBlocState> {
  TodoBloc() : super(const TodoBlocState(BlocStatus.initial, <Todo>[])) {
    on<TodoAddEvent>(_addTodo);
    on<TodoStatusUpdateEvent>(_changeTodoStatus);
    on<TodoContentUpdateEvent>(_editTodo);
    on<TodoRemovedEvent>(_removeTodo);
  }

  void _addTodo(TodoAddEvent event, Emitter<TodoBlocState> emit) async {
    final result = await WriteTodoDialog().show();
    if (result != null) {
      final copiedTodoList = List.of(state.todoList);
      copiedTodoList.add(
        Todo(
          id: DateTime.now().millisecondsSinceEpoch,
          title: result.text,
          dueDate: result.dateTime,
          createdTime: DateTime.now(),
          status: TodoStatus.incomplete,
        ),
      );
      emitNewList(copiedTodoList, emit);
    }
  }

  void _changeTodoStatus(
      TodoStatusUpdateEvent event, Emitter<TodoBlocState> emit) async {
    final copiedTodoList = List.of(state.todoList);
    final todo = event.updatedTodo;
    final todoIndex =
        copiedTodoList.indexWhere((element) => element.id == todo.id);

    TodoStatus status = todo.status;
    switch (todo.status) {
      case TodoStatus.incomplete:
        status = TodoStatus.ongoing;
      case TodoStatus.ongoing:
        status = TodoStatus.complete;
      case TodoStatus.complete:
        final result = await ConfirmDialog(
          '정말로 처음 상태로 변경하시겠어요?',
          buttonText: '확인',
        ).show();
        result?.runIfSuccess((data) {
          status = TodoStatus.incomplete;
        });
        status = TodoStatus.incomplete;
    }

    copiedTodoList[todoIndex] = todo.copyWith(status: status);
    emitNewList(copiedTodoList, emit);
  }

  void _editTodo(
      TodoContentUpdateEvent event, Emitter<TodoBlocState> emit) async {
    final todo = event.updatedTodo;
    final result = await WriteTodoDialog(todoForEdit: todo).show();

    if (result != null) {
      final copiedTodoList = List<Todo>.from(state.todoList);
      copiedTodoList[copiedTodoList.indexOf(todo)] = todo.copyWith(
        title: result.text,
        dueDate: result.dateTime,
        modifyTime: DateTime.now(),
      );
      emitNewList(copiedTodoList, emit);
    }
  }

  void _removeTodo(TodoRemovedEvent event, Emitter<TodoBlocState> emit) {
    final todo = event.removedTodo;
    final copiedTodoList = List<Todo>.from(state.todoList);
    copiedTodoList.removeWhere((element) => element.id == todo.id);
    emitNewList(copiedTodoList, emit);
  }

  void emitNewList(List<Todo> copiedTodoList, Emitter<TodoBlocState> emit) =>
      emit(state.copyWith(todoList: copiedTodoList));
}
