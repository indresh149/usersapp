import '../../core/api/api_client.dart';
import '../models/post_model.dart';
import '../datasources/remote/user_remote_datasource.dart'; // Or a dedicated PostRemoteDataSource

// This repository is simplified for local post creation.
// A full app might have its own remote and local datasources for posts.
abstract class PostRepository {
  Future<Post> createPost({required String title, required String body, required int userId});
  List<Post> getLocalPosts(); // To manage posts created locally
  void addLocalPost(Post post); // To add a locally created post
}

class PostRepositoryImpl implements PostRepository {
  final ApiClient apiClient; // Used if you want to try and sync with DummyJSON's /posts/add
  // For purely local posts, you might not need ApiClient here but rather a local post datasource.
  
  // This list will hold posts created locally during the app session.
  // For persistence beyond session, integrate with Hive or another local DB.
  final List<Post> _localPosts = [];


  PostRepositoryImpl({required this.apiClient}); // UserRemoteDataSource can be used if posts are tied to users


  @override
  Future<Post> createPost({required String title, required String body, required int userId}) async {
    // For DummyJSON, the add post endpoint is a simulation.
    // It returns the post as if it were added, but it's not persisted on their server.
    // We'll "pretend" to send it and then add it to our local list.
    try {
      // DummyJSON's '/posts/add' requires a userId, but it always assigns its own new ID to the post.
      // It often uses userId: 1 for successful dummy additions.
      // For this example, we'll pass a real userId if available, or a placeholder.
      final response = await apiClient.post(
        '/posts/add', // Assuming ApiConstants.addPostEndpoint is '/posts/add'
        data: {'title': title, 'body': body, 'userId': userId}, // DummyJSON might ignore this userId for the actual add.
      );
      final createdPost = Post.fromJson(response.data);
      // Even though DummyJSON assigns an ID, ensure the userId we care about is preserved if needed for local logic.
      final postWithCorrectUserId = createdPost.copyWith(userId: userId); 
      addLocalPost(postWithCorrectUserId); // Add to our in-memory local list
      return postWithCorrectUserId;
    } catch (e) {
      // If API call fails, we can still create it locally with a temporary ID.
      // For simplicity, this example rethrows. A more robust app might handle this.
      print("API post creation failed: $e. Post not added to remote, but consider local save.");
      // Fallback: create a local-only post if API fails
      // final localPost = Post(id: DateTime.now().millisecondsSinceEpoch, title: title, body: body, userId: userId, tags: [], reactions: 0);
      // addLocalPost(localPost);
      // return localPost;
      rethrow;
    }
  }

  @override
  void addLocalPost(Post post) {
    _localPosts.add(post);
    // If using Hive for local posts persistence:
    // final postBox = Hive.box<Post>(AppConstants.hivePostBox);
    // postBox.put(post.id, post); // Or a unique key
  }

  @override
  List<Post> getLocalPosts() {
    // If using Hive:
    // final postBox = Hive.box<Post>(AppConstants.hivePostBox);
    // return postBox.values.toList();
    return List<Post>.from(_localPosts); // Return a copy
  }
}