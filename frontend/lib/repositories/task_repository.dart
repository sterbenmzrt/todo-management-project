import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/task.dart';

class TaskRepository {
  final String baseUrl = "http://localhost:8080"; // Untuk Flutter Web
  // final String baseUrl = "http://10.0.2.2:8080"; // Untuk Android Emulator

  // Fetch all tasks
  Future<List<Task>> fetchTasks() async {
    final response = await http.get(Uri.parse("$baseUrl/tasks"));

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((task) => Task.fromJson(task)).toList();
    } else {
      throw Exception("Failed to fetch tasks");
    }
  }

  // Create new task
  Future<Task> createTask(Task task) async {
    final response = await http.post(
      Uri.parse("$baseUrl/tasks"),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        "title": task.title,
        "description": task.description,
        "status": task.status,
      }),
    );

    if (response.statusCode == 201) {
      return Task.fromJson(json.decode(response.body));
    } else {
      throw Exception("Failed to create task");
    }
  }

  // Update existing task
  Future<Task> updateTask(Task task) async {
    final response = await http.patch(
      Uri.parse("$baseUrl/tasks/${task.id}"),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        "title": task.title,
        "description": task.description,
        "status": task.status,
      }),
    );

    if (response.statusCode == 200) {
      return Task.fromJson(json.decode(response.body));
    } else {
      throw Exception("Failed to update task");
    }
  }

  // Delete task
  Future<void> deleteTask(int id) async {
    final response = await http.delete(Uri.parse("$baseUrl/tasks/$id"));

    if (response.statusCode != 200) {
      throw Exception("Failed to delete task");
    }
  }
}