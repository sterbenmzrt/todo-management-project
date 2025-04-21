import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/task/task_bloc.dart';
import '../blocs/task/task_event.dart';
import '../blocs/task/task_state.dart';
import '../models/task.dart';
import '../repositories/task_repository.dart';
import 'add_task_dialog.dart';

class KanbanScreen extends StatefulWidget {
  const KanbanScreen({super.key});

  @override
  State<KanbanScreen> createState() => _KanbanScreenState();
}

class _KanbanScreenState extends State<KanbanScreen> {
  final ValueNotifier<bool> isDragging = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    context.read<TaskBloc>().add(LoadTasks());
  }

  @override
  void dispose() {
    isDragging.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kanban Tasks')),
      body: BlocBuilder<TaskBloc, TaskState>(
        builder: (context, state) {
          if (state is TaskLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is TaskLoaded) {
            return Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      buildTaskColumn(context, "todo", "To Do", state.tasks),
                      buildTaskColumn(context, "doing", "Doing", state.tasks),
                      buildTaskColumn(context, "done", "Done", state.tasks),
                    ],
                  ),
                ),
                ValueListenableBuilder<bool>(
                  valueListenable: isDragging,
                  builder: (context, dragging, child) {
                    if (!dragging) return const SizedBox.shrink();
                    return Align(
                      alignment: Alignment.bottomCenter,
                      child: DragTarget<Task>(
                        onAccept: (task) {
                          context.read<TaskBloc>().add(DeleteTask(task.id));
                          isDragging.value = false;
                        },
                        builder: (context, candidateData, rejectedData) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 20),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: candidateData.isNotEmpty ? Colors.redAccent : Colors.grey[400],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.delete, size: 32, color: Colors.white),
                                const SizedBox(height: 4),
                                Text(
                                  candidateData.isNotEmpty ? "Release to Delete" : "Drag Here to Delete",
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ],
            );
          } else if (state is TaskError) {
            return Center(child: Text(state.message));
          }
          return Container();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (dialogContext) => BlocProvider.value(
              value: BlocProvider.of<TaskBloc>(context),
              child: AddTaskDialog(),
            ),
            useRootNavigator: true,
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget buildTaskColumn(BuildContext context, String status, String title, List<Task> allTasks) {
    final tasks = allTasks.where((t) => t.status == status).toList();

    return Expanded(
      child: DragTarget<Task>(
        // Add onWillAccept to verify the task can be dropped here
        onWillAccept: (task) => task != null,
        onAccept: (task) {
          final updatedTask = Task(
            id: task.id,
            title: task.title,
            description: task.description,
            status: status,
          );
          context.read<TaskBloc>().add(UpdateTask(updatedTask));
        },
        builder: (context, candidateData, rejectedData) {
          return Card(
            // Add visual feedback when dragging over this column
            color: candidateData.isNotEmpty ? Colors.blue.withOpacity(0.1) : null,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  color: Colors.blueGrey[100],
                  child: Center(
                    child: Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    physics: isDragging.value
                        ? const NeverScrollableScrollPhysics()
                        : const AlwaysScrollableScrollPhysics(),
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      final task = tasks[index];
                      // Change to Draggable instead of LongPressDraggable for easier dragging
                      return Draggable<Task>(
                        data: task,
                        onDragStarted: () {
                          isDragging.value = true;
                        },
                        onDragEnd: (details) {
                          isDragging.value = false;
                        },
                        onDraggableCanceled: (velocity, offset) {
                          isDragging.value = false;
                        },
                        feedback: Material(
                          color: Colors.transparent,
                          child: SizedBox(
                            width: 200,
                            child: Card(
                              elevation: 8,
                              color: Colors.blueGrey[50],
                              child: ListTile(
                                title: Text(task.title),
                                subtitle: Text(task.description),
                              ),
                            ),
                          ),
                        ),
                        childWhenDragging: Opacity(
                          opacity: 0.3,
                          child: buildTaskCard(task),
                        ),
                        child: buildTaskCard(task),
                      );
                    },
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }

  Widget buildTaskCard(Task task) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: ListTile(
        title: Text(task.title),
        subtitle: Text(task.description),
      ),
    );
  }
}