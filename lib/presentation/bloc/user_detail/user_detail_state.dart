part of 'user_detail_bloc.dart';

abstract class UserDetailState extends Equatable {
  const UserDetailState();

  @override
  List<Object?> get props => [];
}

class UserDetailInitial extends UserDetailState {}

class UserDetailLoading extends UserDetailState {}

class UserDetailLoaded extends UserDetailState {
  final User? user; // User might be passed or fetched if not already available
  final List<Post> posts;
  final List<Todo> todos;
  final List<Post> localPosts; // Posts created locally for this user

  const UserDetailLoaded({
    this.user, 
    required this.posts, 
    required this.todos,
    this.localPosts = const [],
  });

  @override
  List<Object?> get props => [user, posts, todos, localPosts];
}

class UserDetailError extends UserDetailState {
  final String message;
  const UserDetailError({required this.message});

  @override
  List<Object> get props => [message];
}