import 'package:flutter/material.dart';
import '../../data/models/user_model.dart';

class UserCard extends StatelessWidget {
  final User user;
  final VoidCallback onTap;

  const UserCard({super.key, required this.user, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: NetworkImage(user.image),
          onBackgroundImageError: (_, __) => Icon(Icons.person), // Fallback
        ),
        title: Text(user.fullName, style: Theme.of(context).textTheme.titleMedium),
        subtitle: Text(user.email),
        trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Theme.of(context).hintColor),
        onTap: onTap,
      ),
    );
  }
}