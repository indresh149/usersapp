part of 'create_post_bloc.dart';

abstract class CreatePostState extends Equatable {
  const CreatePostState();

  @override
  List<Object> get props => [];
}

class CreatePostInitial extends CreatePostState {}

class CreatePostSubmitting extends CreatePostState {}

class CreatePostSuccess extends CreatePostState {
  final Post createdPost;
  const CreatePostSuccess({required this.createdPost});

  @override
  List<Object> get props => [createdPost];
}

class CreatePostFailure extends CreatePostState {
  final String error;
  const CreatePostFailure({required this.error});

  @override
  List<Object> get props => [error];
}