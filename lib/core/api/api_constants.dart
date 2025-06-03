class ApiConstants {
  static const String baseUrl = 'https://dummyjson.com';
  static const String usersEndpoint = '/users';
  static const String userSearchEndpoint = '/users/search';
  static const String userPostsEndpoint = '/posts/user/'; // Needs {userId}
  static const String userTodosEndpoint = '/todos/user/'; // Needs {userId}
  static const String addPostEndpoint = '/posts/add'; // For dummy post creation
}