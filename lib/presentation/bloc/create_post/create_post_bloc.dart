import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../data/models/post_model.dart';
import '../../../data/repositories/post_repository.dart';

part 'create_post_event.dart';
part 'create_post_state.dart';

class CreatePostBloc extends Bloc<CreatePostEvent, CreatePostState> {
  final PostRepository postRepository;

  CreatePostBloc({required this.postRepository}) : super(CreatePostInitial()) {
    on<SubmitPost>(_onSubmitPost);
  }

  Future<void> _onSubmitPost(SubmitPost event, Emitter<CreatePostState> emit) async {
    emit(CreatePostSubmitting());
    try {
      // The repository handles the "dummy" API call and local storage/update
      final newPost = await postRepository.createPost(
        title: event.title,
        body: event.body,
        userId: event.userId,
      );
      emit(CreatePostSuccess(createdPost: newPost));
    } catch (e) {
      emit(CreatePostFailure(error: e.toString()));
    }
  }
}