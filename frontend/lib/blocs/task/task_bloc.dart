import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../repositories/task_repository.dart';
import '../../../models/task.dart';
import 'task_event.dart';
import 'task_state.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final TaskRepository repository;

  TaskBloc(this.repository) : super(TaskInitial()) {
    on<LoadTasks>((event, emit) async {
      emit(TaskLoading());
      try {
        final tasks = await repository.fetchTasks();
        emit(TaskLoaded(tasks));
      } catch (e) {
        emit(TaskError('Failed to load tasks'));
      }
    });

    on<CreateTask>((event, emit) async {
      try {
        await repository.createTask(event.task);
        add(LoadTasks()); // After create, reload list
      } catch (e) {
        emit(TaskError('Failed to create task'));
      }
    });

    on<UpdateTask>((event, emit) async {
      try {
        await repository.updateTask(event.task);
        add(LoadTasks()); // After update, reload list
      } catch (e) {
        emit(TaskError('Failed to update task'));
      }
    });

    on<DeleteTask>((event, emit) async {
      try {
        await repository.deleteTask(event.id);
        add(LoadTasks()); // After delete, reload list
      } catch (e) {
        emit(TaskError('Failed to delete task'));
      }
    });
  }
}