import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/di/service_locator.dart' as di;
import 'core/theme/app_theme.dart';
import 'core/theme/theme_bloc.dart';
import 'data/datasources/local/app_database.dart';
import 'presentation/bloc/user_list/user_list_bloc.dart';
// Import other BLoCs if they need to be globally available,
// otherwise provide them closer to where they are used.
import 'presentation/screens/user_list_screen.dart';
import 'routes/app_router.dart'; // If using named routes

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppDatabase.initHive(); // Initialize Hive
  await di.initializeDependencies(); // Initialize GetIt dependencies
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ThemeBloc>(create: (context) => di.sl<ThemeBloc>()),
        BlocProvider<UserListBloc>(create: (context) => di.sl<UserListBloc>()),
        // UserDetailBloc and CreatePostBloc are typically provided closer to their screens
        // as UserDetailBloc depends on userId.
      ],
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, themeState) {
          return MaterialApp(
            title: 'User Management App',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeState.themeMode,
            debugShowCheckedModeBanner: false,
            // home: const UserListScreen(), // If not using named routes as initial
            onGenerateRoute: AppRouter.generateRoute, // Use this for named routes
            initialRoute: AppRouter.userListRoute, // Set initial route
          );
        },
      ),
    );
  }
}