import '../../../models/task.dart';

abstract class TaskState {}

class TaskInitial extends TaskState {}

class TaskLoading extends TaskState {}

class TaskLoaded extends TaskState {
  final List<Task> tasks;

  TaskLoaded(this.tasks);
}

class TaskOperationSuccess extends TaskState {}

class TaskError extends TaskState {
  final String message;

  TaskError(this.message);
}