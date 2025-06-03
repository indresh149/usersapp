import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:usersapp/routes/app_router.dart';
import '../../data/models/user_model.dart';
import '../bloc/user_detail/user_detail_bloc.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/error_display.dart';
import '../../core/di/service_locator.dart';
import 'create_post_screen.dart';
import '../widgets/post_card.dart'; // Create this widget
import '../widgets/todo_tile.dart'; // Create this widget
import '../../data/models/post_model.dart';

class UserDetailScreen extends StatelessWidget {
  final User user; // User object passed from the list screen

  const UserDetailScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    // Use sl<UserDetailBloc>() if you need to pass parameters not available at build time
    // Or provide it higher up if it doesn't depend on dynamic params like userId from route args.
    // Here, we can create it directly using BlocProvider if we pass userId.
    return BlocProvider(
      create: (context) => sl<UserDetailBloc>(param1: user.id) // Pass userId as param1
        ..setInitialUser(user) // Pass the user object
        ..add(const FetchUserAllDetails()),
      child: Scaffold(
        appBar: AppBar(
          title: Text(user.fullName),
          actions: [
             IconButton(
              icon: Icon(Icons.refresh),
              onPressed: () {
                context.read<UserDetailBloc>().add(const FetchUserAllDetails(forceRefresh: true));
              },
            ),
          ],
        ),
        body: BlocBuilder<UserDetailBloc, UserDetailState>(
          builder: (context, state) {
            if (state is UserDetailLoading && !(state is UserDetailLoaded)) { // Show loading only if no data yet
              return const LoadingIndicator(message: 'Loading details...');
            } else if (state is UserDetailLoaded) {
              final displayedUser = state.user ?? user; // Prioritize user from state, fallback to passed user
              final allPosts = [...state.posts, ...state.localPosts]; // Combine remote and local posts
              // Sort posts by ID or a timestamp if you add one to local posts (newest first)
              allPosts.sort((a, b) => b.id.compareTo(a.id));


              return RefreshIndicator(
                onRefresh: () async => context.read<UserDetailBloc>().add(const FetchUserAllDetails(forceRefresh: true)),
                child: ListView(
                  padding: const EdgeInsets.all(16.0),
                  children: [
                    _buildUserInfoSection(context, displayedUser),
                    const SizedBox(height: 20),
                    Text('Posts (${allPosts.length})', style: Theme.of(context).textTheme.headlineSmall),
                    if (allPosts.isEmpty) const Text('No posts yet.'),
                    ...allPosts.map((post) => PostCard(post: post)).toList(),
                    const SizedBox(height: 20),
                     Text('Todos (${state.todos.length})', style: Theme.of(context).textTheme.headlineSmall),
                    if (state.todos.isEmpty) const Text('No todos found.'),
                    ...state.todos.map((todo) => TodoTile(todo: todo)).toList(),
                  ],
                ),
              );
            } else if (state is UserDetailError) {
              return ErrorDisplay(
                message: state.message,
                onRetry: () => context.read<UserDetailBloc>().add(const FetchUserAllDetails()),
              );
            }
            return const Center(child: Text('Select a user to see details.')); // Fallback
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            // final result = await Navigator.of(context).push(
            //   MaterialPageRoute(
            //     builder: (_) => CreatePostScreen(userId: user.id),
            //   ),
            // );
          final result = await  Navigator.of(context).pushNamed(AppRouter.createPostRoute, arguments: user.id);
            // If a post was created and we want to refresh the details screen:
            if (result == true) { // Assuming CreatePostScreen returns true on success
              // ignore: use_build_context_synchronously
              context.read<UserDetailBloc>().add(const FetchUserAllDetails());
            }
          },
          child: const Icon(Icons.add),
          tooltip: 'Create Post',
        ),
      ),
    );
  }

  Widget _buildUserInfoSection(BuildContext context, User u) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: NetworkImage(u.image),
                   onBackgroundImageError: (_, __) => Icon(Icons.person, size: 40),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(u.fullName, style: Theme.of(context).textTheme.titleLarge),
                      Text(u.email, style: Theme.of(context).textTheme.titleMedium),
                      if (u.phone != null) Text('Phone: ${u.phone}', style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (u.username != null) Text('Username: ${u.username}', style: Theme.of(context).textTheme.bodyMedium),
            if (u.address != null) ...[
              const SizedBox(height: 8),
              Text('Address:', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              Text('${u.address!.address}, ${u.address!.city}, ${u.address!.postalCode}', style: Theme.of(context).textTheme.bodyMedium),
            ]
            // Add more user details as needed
          ],
        ),
      ),
    );
  }
}