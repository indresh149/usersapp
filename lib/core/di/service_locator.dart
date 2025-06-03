import 'package:get_it/get_it.dart';
import '../api/api_client.dart';
import '../../data/datasources/remote/user_remote_datasource.dart';
import '../../data/datasources/local/user_local_datasource.dart';
import '../../data/repositories/user_repository.dart';
import '../../presentation/bloc/user_list/user_list_bloc.dart';
import '../../presentation/bloc/user_detail/user_detail_bloc.dart';
import '../../presentation/bloc/create_post/create_post_bloc.dart';
import '../theme/theme_bloc.dart';
import '../../data/repositories/post_repository.dart'; // Add this
import 'package:hive_flutter/hive_flutter.dart'; // Add this
import '../../data/models/user_model.dart'; // Add this for Hive adapter
import '../../data/models/post_model.dart'; // Add this for Hive adapter
import '../../data/models/todo_model.dart'; // Add this for Hive adapter
import '../constants/app_constants.dart'; // Add this
import 'package:shared_preferences/shared_preferences.dart'; // Add this for theme

final sl = GetIt.instance; // sl is short for Service Locator

Future<void> initializeDependencies() async {
  // Hive Boxes
  sl.registerSingleton<Box<User>>(Hive.box<User>(AppConstants.hiveUserBox));
  sl.registerSingleton<Box<Post>>(Hive.box<Post>(AppConstants.hivePostBox));
  sl.registerSingleton<Box<Todo>>(Hive.box<Todo>(AppConstants.hiveTodoBox));

  // SharedPreferences
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerSingleton<SharedPreferences>(sharedPreferences);

  // Core
  sl.registerSingleton<ApiClient>(ApiClient());

  // Datasources
  sl.registerLazySingleton<UserRemoteDataSource>(
      () => UserRemoteDataSourceImpl(apiClient: sl()));
  sl.registerLazySingleton<UserLocalDataSource>(
      () => UserLocalDataSourceImpl(userBox: sl(), postBox: sl(), todoBox: sl()));

  // Repositories
  sl.registerLazySingleton<UserRepository>(() => UserRepositoryImpl(
        remoteDataSource: sl(),
        localDataSource: sl(),
      ));
  sl.registerLazySingleton<PostRepository>(() => PostRepositoryImpl( // For creating posts
        apiClient: sl(), // If you were to sync posts with a backend
        // localDataSource: sl(), // If posts were also cached extensively like users
      ));


  // BLoCs
  sl.registerFactory<UserListBloc>(() => UserListBloc(userRepository: sl()));
  sl.registerFactoryParam<UserDetailBloc, int, void>(
      (userId, _) => UserDetailBloc(userRepository: sl(), postRepository: sl(), userId: userId));
  sl.registerFactory<CreatePostBloc>(() => CreatePostBloc(postRepository: sl()));
  sl.registerFactory<ThemeBloc>(() => ThemeBloc(sharedPreferences: sl()));
}