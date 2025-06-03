import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../data/models/user_model.dart';
import '../../../data/models/post_model.dart';
import '../../../data/models/todo_model.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../data/repositories/post_repository.dart'; // For local posts

part 'user_detail_event.dart';
part 'user_detail_state.dart';

class UserDetailBloc extends Bloc<UserDetailEvent, UserDetailState> {
  final UserRepository userRepository;
  final PostRepository postRepository; // For fetching local posts
  final int userId;
  User? _cachedUser; // To store user details passed from list or fetched once

  UserDetailBloc({required this.userRepository, required this.postRepository, required this.userId}) : super(UserDetailInitial()) {
    on<FetchUserAllDetails>(_onFetchUserAllDetails);
  }

  void setInitialUser(User? user) {
    _cachedUser = user;
  }

  Future<void> _onFetchUserAllDetails(FetchUserAllDetails event, Emitter<UserDetailState> emit) async {
    emit(UserDetailLoading());
    try {
      // Attempt to get user details if not already cached or if forcing refresh for user details
      if (_cachedUser == null || event.forceRefresh) {
         _cachedUser = await userRepository.getCachedUserById(userId);
         // If you had a dedicated getUserById API call, you'd use it here.
         // For now, we rely on the list cache or what was passed.
      }

      // Fetch posts and todos in parallel
      final results = await Future.wait([
        userRepository.getUserPosts(userId: userId, forceRefresh: event.forceRefresh),
        userRepository.getUserTodos(userId: userId, forceRefresh: event.forceRefresh),
      ]);

      final posts = results[0] as List<Post>;
      final todos = results[1] as List<Todo>;
      
      // Get local posts for this user
      final allLocalPosts = postRepository.getLocalPosts();
      final userLocalPosts = allLocalPosts.where((post) => post.userId == userId).toList();


      emit(UserDetailLoaded(
        user: _cachedUser, // May still be null if not found
        posts: posts, 
        todos: todos,
        localPosts: userLocalPosts,
      ));
    } catch (e) {
      emit(UserDetailError(message: e.toString()));
    }
  }
}