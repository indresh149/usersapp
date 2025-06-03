import 'package:hive/hive.dart';
import '../../models/user_model.dart';
import '../../models/post_model.dart';
import '../../models/todo_model.dart';

abstract class UserLocalDataSource {
  Future<List<User>> getUsers();
  Future<void> cacheUsers(List<User> users);
  Future<User?> getUserById(int userId);

  Future<List<Post>> getUserPosts(int userId);
  Future<void> cacheUserPosts(int userId, List<Post> posts);

  Future<List<Todo>> getUserTodos(int userId);
  Future<void> cacheUserTodos(int userId, List<Todo> todos);

  Future<void> clearAllCache(); // For pull to refresh example
}

class UserLocalDataSourceImpl implements UserLocalDataSource {
  final Box<User> userBox;
  final Box<Post> postBox;
  final Box<Todo> todoBox;

  UserLocalDataSourceImpl({
    required this.userBox,
    required this.postBox,
    required this.todoBox,
  });

  @override
  Future<void> cacheUsers(List<User> users) async {
    // Simple caching: clear old and add new. Could be more sophisticated.
    // await userBox.clear(); // Be careful with this if you want to append
    final Map<int, User> userMap = {for (var user in users) user.id: user};
    await userBox.putAll(userMap);
  }

  @override
  Future<List<User>> getUsers() async {
    return userBox.values.toList();
  }

  @override
  Future<User?> getUserById(int userId) async {
    return userBox.get(userId);
  }


  @override
  Future<void> cacheUserPosts(int userId, List<Post> posts) async {
    // Store posts with a key that includes userId to differentiate
    final Map<dynamic, Post> postsToCache = {};
    for (var post in posts) {
      // Ensure posts are associated with the correct user, even if API returns generic userId for posts
      postsToCache['post_${userId}_${post.id}'] = post.copyWith(userId: userId);
    }
    await postBox.putAll(postsToCache);
  }

  @override
  Future<List<Post>> getUserPosts(int userId) async {
    return postBox.values.where((post) => post.userId == userId).toList();
  }

  @override
  Future<void> cacheUserTodos(int userId, List<Todo> todos) async {
     final Map<dynamic, Todo> todosToCache = {};
    for (var todo in todos) {
      todosToCache['todo_${userId}_${todo.id}'] = todo; // Assuming Todo model has userId
    }
    await todoBox.putAll(todosToCache);
  }

  @override
  Future<List<Todo>> getUserTodos(int userId) async {
    return todoBox.values.where((todo) => todo.userId == userId).toList();
  }

  @override
  Future<void> clearAllCache() async {
    await userBox.clear();
    await postBox.clear();
    await todoBox.clear();
    // Potentially also clear SharedPreferences related to data if any.
  }
}