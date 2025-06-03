import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'todo_model.g.dart'; // Hive will generate this

@HiveType(typeId: 3) // Ensure unique typeId
class Todo extends Equatable {
  @HiveField(0)
  final int id;
  @HiveField(1)
  final String todo;
  @HiveField(2)
  final bool completed;
  @HiveField(3)
  final int userId;

  const Todo({
    required this.id,
    required this.todo,
    required this.completed,
    required this.userId,
  });

  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      id: json['id'],
      todo: json['todo'] ?? 'No Description',
      completed: json['completed'] ?? false,
      userId: json['userId'],
    );
  }

   Map<String, dynamic> toJson() {
    return {
      'id': id,
      'todo': todo,
      'completed': completed,
      'userId': userId,
    };
  }

  @override
  List<Object?> get props => [id, todo, completed, userId];
}