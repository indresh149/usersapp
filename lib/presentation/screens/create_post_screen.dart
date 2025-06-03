import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/create_post/create_post_bloc.dart';
import '../widgets/loading_indicator.dart';
import '../../core/di/service_locator.dart'; // For BLoC

class CreatePostScreen extends StatefulWidget {
  final int userId; // Pass the userId to associate the post

  const CreatePostScreen({super.key, required this.userId});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  void _submitPost(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      context.read<CreatePostBloc>().add(
            SubmitPost(
              title: _titleController.text,
              body: _bodyController.text,
              userId: widget.userId,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<CreatePostBloc>(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Create New Post'),
        ),
        body: BlocConsumer<CreatePostBloc, CreatePostState>(
          listener: (context, state) {
            if (state is CreatePostSuccess) {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(const SnackBar(content: Text('Post created locally!'), backgroundColor: Colors.green,));
              // Optionally, you can pass the created post back or just a success flag
              Navigator.of(context).pop(true); // Pop with a success flag
            } else if (state is CreatePostFailure) {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(SnackBar(content: Text('Failed to create post: ${state.error}'), backgroundColor: Colors.red,));
            }
          },
          builder: (context, state) {
            if (state is CreatePostSubmitting) {
              return const LoadingIndicator(message: 'Submitting post...');
            }
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView( // Use ListView for scrollability on small screens
                  children: [
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(labelText: 'Title'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a title';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _bodyController,
                      decoration: const InputDecoration(labelText: 'Body'),
                      maxLines: 5,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the post body';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: state is CreatePostSubmitting ? null : () => _submitPost(context),
                      child: const Text('Create Post'),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}