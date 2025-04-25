import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/task/task_bloc.dart';
import '../blocs/task/task_event.dart';
import '../blocs/task/task_state.dart';
import '../models/task.dart';
import 'add_task_dialog.dart';
import 'task_detail_dialog.dart';

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
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              'assets/logo.png',
              height: 32,
              errorBuilder: (context, error, stackTrace) =>
              const Icon(Icons.error_outline, color: Colors.red),
            ),
            const SizedBox(width: 8),
            const Text('DO IT', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
        actions: [
          BlocBuilder<TaskBloc, TaskState>(
            builder: (context, state) {
              if (state is TaskLoaded) {
                final total = state.tasks.length;
                final done = state.tasks.where((t) => t.status == 'done').length;
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('$done/$total', style: const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 2),
                        SizedBox(
                          width: 60,
                          height: 6,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(3),
                            child: LinearProgressIndicator(
                              value: total > 0 ? done / total : 0,
                              backgroundColor: Colors.white24,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Theme.of(context).colorScheme.onPrimaryContainer,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
          IconButton(
            icon: const Icon(Icons.dark_mode),
            onPressed: () {
              // Implement dark mode toggle
            },
            tooltip: 'Toggle Theme',
          ),
        ],
      ),
      body: BlocBuilder<TaskBloc, TaskState>(
        builder: (context, state) {
          if (state is TaskLoading) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/logo.png',
                    height: 80,
                    errorBuilder: (context, error, stackTrace) =>
                    const SizedBox.shrink(),
                  ),
                  const SizedBox(height: 24),
                  const CircularProgressIndicator(),
                ],
              ),
            );
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
    final totalTasks = allTasks.length;

    return Expanded(
      child: DragTarget<Task>(
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
            margin: const EdgeInsets.symmetric(horizontal: 4),
            color: candidateData.isNotEmpty
                ? _getStatusColor(status).withOpacity(0.1)
                : Theme.of(context).cardColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: candidateData.isNotEmpty
                  ? BorderSide(color: _getStatusColor(status), width: 2)
                  : BorderSide.none,
            ),
            child: Column(
              children: [
                // Use the buildColumnHeader method
                buildColumnHeader(title, tasks.length, totalTasks),
                const SizedBox(height: 4),
                Expanded(
                  child: tasks.isEmpty
                      ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.inbox_outlined,
                          size: 48,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Drag tasks here',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  )
                      : ListView.builder(
                    physics: isDragging.value
                        ? const NeverScrollableScrollPhysics()
                        : const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(8),
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      final task = tasks[index];
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
                            child: buildTaskCard(task),
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
                ),
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
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: _getStatusColor(task.status).withOpacity(0.5),
            width: 2,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          title: Text(
            task.title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(task.description),
          ),
          trailing: Icon(_getStatusIcon(task.status), color: _getStatusColor(task.status)),
          onTap: () {
            showDialog(
              context: context,
              builder: (dialogContext) => BlocProvider.value(
                value: context.read<TaskBloc>(),
                child: TaskDetailDialog(task: task),
              ),
              useRootNavigator: true,
            );
          },
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'todo':
        return Colors.orange;
      case 'doing':
        return Colors.blue;
      case 'done':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'todo':
        return Icons.assignment_outlined;
      case 'doing':
        return Icons.access_time;
      case 'done':
        return Icons.check_circle_outline;
      default:
        return Icons.help_outline;
    }
  }

  Widget buildColumnHeader(String title, int taskCount, int totalTasks) {
    final progress = totalTasks > 0 ? taskCount / totalTasks : 0.0;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('$taskCount', style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(width: 4),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.grey.withOpacity(0.2),
                    minHeight: 6,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}