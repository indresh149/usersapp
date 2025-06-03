import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:usersapp/routes/app_router.dart';
import '../bloc/user_list/user_list_bloc.dart';
import '../widgets/user_card.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/error_display.dart';
import '../widgets/search_field.dart';
import '../../core/di/service_locator.dart';
import 'user_detail_screen.dart';
import '../../data/models/user_model.dart'; // Import User model
import '../../core/theme/theme_bloc.dart'; // Import ThemeBloc

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Initial fetch
    context.read<UserListBloc>().add(const FetchUsers());
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_isBottom) {
      context.read<UserListBloc>().add(FetchMoreUsers());
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    // Trigger fetch a bit before reaching the absolute bottom
    return currentScroll >= (maxScroll * 0.9);
  }

  Future<void> _onRefresh() async {
     context.read<UserListBloc>().add(const FetchUsers(isRefresh: true));
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Users'),
        actions: [
          BlocBuilder<ThemeBloc, ThemeState>(
            builder: (context, state) {
              return IconButton(
                icon: Icon(state.themeMode == ThemeMode.dark || (state.themeMode == ThemeMode.system && MediaQuery.of(context).platformBrightness == Brightness.dark)
                    ? Icons.light_mode
                    : Icons.dark_mode),
                onPressed: () {
                  final currentMode = state.themeMode;
                  if (currentMode == ThemeMode.dark) {
                    context.read<ThemeBloc>().add(const ThemeModeChanged(ThemeMode.light));
                  } else if (currentMode == ThemeMode.light) {
                     context.read<ThemeBloc>().add(const ThemeModeChanged(ThemeMode.dark));
                  } else { // System
                     final platformBrightness = MediaQuery.of(context).platformBrightness;
                     context.read<ThemeBloc>().add(ThemeModeChanged(platformBrightness == Brightness.dark ? ThemeMode.light : ThemeMode.dark));
                  }
                },
              );
            },
          )
        ],
      ),
      body: Column(
        children: [
          SearchField(
            onSearchChanged: (query) {
              context.read<UserListBloc>().add(SearchUsers(query: query));
            },
          ),
          Expanded(
            child: BlocConsumer<UserListBloc, UserListState>(
              listener: (context, state) {
                if (state is UserListError && !(state is UserListLoading)) { // Don't show for loading more error if list is already there
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(SnackBar(content: Text(state.message)));
                }
              },
              builder: (context, state) {
                if (state is UserListLoading && state.isFirstFetch) {
                  return const LoadingIndicator(message: 'Fetching users...');
                } else if (state is UserListLoaded || (state is UserListLoading && state.oldUsers.isNotEmpty)) {
                  final users = (state is UserListLoaded) ? state.users : (state as UserListLoading).oldUsers;
                  final bool isLoadingMore = (state is UserListLoading && !state.isFirstFetch);

                  if (users.isEmpty && !(state is UserListLoading)) {
                    return ErrorDisplay(message: 'No users found.', onRetry: () => context.read<UserListBloc>().add(const FetchUsers()));
                  }

                  return RefreshIndicator(
                    onRefresh: _onRefresh,
                    child: ListView.builder(
                      controller: _scrollController,
                      itemCount: users.length + (isLoadingMore || (state is UserListLoaded && !state.hasReachedMax) ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index >= users.length) {
                           if (state is UserListLoaded && !state.hasReachedMax) {
                             // This is a subtle loading indicator for infinite scroll
                             // It means more items can be loaded. FetchMoreUsers is triggered by scroll listener.
                             return const Padding(
                               padding: EdgeInsets.all(8.0),
                               child: Center(child: SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2))),
                             );
                           } else if (isLoadingMore) {
                               return const LoadingIndicator(); // Explicit loading indicator when FetchMoreUsers is active
                           }
                           return const SizedBox.shrink(); // Should not happen if hasReachedMax is true
                        }
                        final user = users[index];
                        return UserCard(
                          user: user,
                          onTap: () {
                            // Navigator.of(context).push(
                            //   MaterialPageRoute(
                            //     builder: (_) => UserDetailScreen(user: user), // Pass the full user object
                            //   ),
                            // );
                            Navigator.of(context).pushNamed(AppRouter.userDetailRoute, arguments: user);
                          },
                        );
                      },
                    ),
                  );
                } else if (state is UserListError) {
                  return ErrorDisplay(message: state.message, onRetry: () => context.read<UserListBloc>().add(const FetchUsers()));
                }
                return const Center(child: Text('Welcome! Pull to refresh or search.')); // Initial or unhandled state
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }
}