import 'package:flutter/material.dart';
import '../presentation/screens/user_list_screen.dart';
import '../presentation/screens/user_detail_screen.dart';
import '../presentation/screens/create_post_screen.dart';
import '../data/models/user_model.dart'; // Required for UserDetailScreen argument if not using dynamic

class AppRouter {
  static const String userListRoute = '/';
  static const String userDetailRoute = '/userDetail';
  static const String createPostRoute = '/createPost';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case userListRoute:
        return MaterialPageRoute(builder: (_) => const UserListScreen());
      case userDetailRoute:
        final user = settings.arguments as User; // Ensure you pass User object
        return MaterialPageRoute(builder: (_) => UserDetailScreen(user: user));
      case createPostRoute:
         final userId = settings.arguments as int; // Pass userId
        return MaterialPageRoute(builder: (_) => CreatePostScreen(userId: userId));
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}