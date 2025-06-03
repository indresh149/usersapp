part of 'create_post_bloc.dart';

abstract class CreatePostEvent extends Equatable {
  const CreatePostEvent();

  @override
  List<Object> get props => [];
}

class SubmitPost extends CreatePostEvent {
  final String title;
  final String body;
  final int userId; // To associate the post with a user

  const SubmitPost({required this.title, required this.body, required this.userId});

  @override
  List<Object> get props => [title, body, userId];
}