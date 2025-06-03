import '../../../core/api/api_client.dart';
import '../../../core/api/api_constants.dart';
import '../../models/user_list_response_model.dart';
import '../../models/post_model.dart';
import '../../models/todo_model.dart';
import '../../models/user_model.dart'; // For search that returns a list of users directly

abstract class UserRemoteDataSource {
  Future<UserListResponse> getUsers({required int skip, required int limit});
  Future<UserListResponse> searchUsers({required String query, required int skip, required int limit});
  Future<List<Post>> getUserPosts({required int userId});
  Future<List<Todo>> getUserTodos({required int userId});
  Future<Post> addPost(String title, String body, int userId);
}

class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  final ApiClient apiClient;

  UserRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<UserListResponse> getUsers({required int skip, required int limit}) async {
    final response = await apiClient.get(
      ApiConstants.usersEndpoint,
      queryParameters: {'skip': skip, 'limit': limit},
    );
    return UserListResponse.fromJson(response.data);
  }

  @override
  Future<UserListResponse> searchUsers({required String query, required int skip, required int limit}) async {
    final response = await apiClient.get(
      ApiConstants.userSearchEndpoint,
      queryParameters: {'q': query, 'skip': skip, 'limit': limit},
    );
     return UserListResponse.fromJson(response.data); // Assuming search also returns the same structure
  }

  @override
  Future<List<Post>> getUserPosts({required int userId}) async {
    final response = await apiClient.get('${ApiConstants.userPostsEndpoint}$userId');
    final postsData = response.data['posts'] as List;
    return postsData.map((postJson) => Post.fromJson(postJson)).toList();
  }

  @override
  Future<List<Todo>> getUserTodos({required int userId}) async {
    final response = await apiClient.get('${ApiConstants.userTodosEndpoint}$userId');
    final todosData = response.data['todos'] as List;
    return todosData.map((todoJson) => Todo.fromJson(todoJson)).toList();
  }
   @override
  Future<Post> addPost(String title, String body, int userId) async {
    final response = await apiClient.post(
      ApiConstants.addPostEndpoint,
      data: {'title': title, 'body': body, 'userId': userId}, // DummyJSON uses userId 1 for new posts
    );
    // The API returns the new post with an ID.
    // For local display, we might use this or a temporary one.
    return Post.fromJson(response.data);
  }
}