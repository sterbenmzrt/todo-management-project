import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/task.dart';
import '../blocs/task/task_bloc.dart';
import '../blocs/task/task_event.dart';

class TaskDetailDialog extends StatefulWidget {
  final Task task;

  const TaskDetailDialog({super.key, required this.task});

  @override
  State<TaskDetailDialog> createState() => _TaskDetailDialogState();
}

class _TaskDetailDialogState extends State<TaskDetailDialog> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late String _status;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task.title);
    _descriptionController = TextEditingController(text: widget.task.description);
    _status = widget.task.status;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _save() {
    final updatedTask = Task(
      id: widget.task.id,
      title: _titleController.text,
      description: _descriptionController.text,
      status: _status,
    );

    context.read<TaskBloc>().add(UpdateTask(updatedTask));
    Navigator.of(context).pop();
  }

  void _delete() {
    context.read<TaskBloc>().add(DeleteTask(widget.task.id));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Image.asset('assets/logo.png', height: 24),
          const SizedBox(width: 8),
          const Text('Task Details'),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _status,
              items: const [
                DropdownMenuItem(value: 'todo', child: Text('To Do')),
                DropdownMenuItem(value: 'doing', child: Text('Doing')),
                DropdownMenuItem(value: 'done', child: Text('Done')),
              ],
              onChanged: (value) {
                if (value != null) setState(() => _status = value);
              },
              decoration: const InputDecoration(labelText: 'Status'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _delete,
          child: const Text('Delete', style: TextStyle(color: Colors.red)),
        ),
        ElevatedButton(
          onPressed: _save,
          child: const Text('Save'),
        ),
      ],
    );
  }
}
