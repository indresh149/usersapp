import 'package:flutter/material.dart';
import '../../data/models/todo_model.dart';

class TodoTile extends StatelessWidget {
  final Todo todo;

  const TodoTile({super.key, required this.todo});

  @override
  Widget build(BuildContext context) {
    return Card(
       margin: const EdgeInsets.symmetric(vertical: 4.0),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        title: Text(
          todo.todo,
          style: TextStyle(
            decoration: todo.completed ? TextDecoration.lineThrough : null,
            color: todo.completed ? Colors.grey : Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        trailing: Checkbox(
          value: todo.completed,
          onChanged: null, // Display only, not interactive in this context
          activeColor: Theme.of(context).primaryColor,
        ),
      ),
    );
  }
}