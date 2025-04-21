import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'repositories/task_repository.dart';
import 'blocs/task/task_bloc.dart';
import 'screens/kanban_screen.dart'; // <-- Import screen kanban

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = TaskRepository();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Todo Management',
      home: BlocProvider(
        create: (_) => TaskBloc(repository),
        child: const KanbanScreen(), // <-- Ini kita pasang
      ),
    );
  }
}