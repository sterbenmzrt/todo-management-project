import '../../models/task.dart';

abstract class TaskEvent {}

class LoadTasks extends TaskEvent {}

class CreateTask extends TaskEvent {
  final Task task;

  CreateTask(this.task);
}

class UpdateTask extends TaskEvent {
  final Task task;

  UpdateTask(this.task);
}

class DeleteTask extends TaskEvent {
  final int id;

  DeleteTask(this.id);
}