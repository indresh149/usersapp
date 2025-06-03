import '../models/user_list_response_model.dart';
import '../models/user_model.dart';
import '../models/post_model.dart';
import '../models/todo_model.dart';
import '../datasources/remote/user_remote_datasource.dart';
import '../datasources/local/user_local_datasource.dart';
import 'package:connectivity_plus/connectivity_plus.dart'; // Add connectivity_plus to pubspec.yaml

abstract class UserRepository {
  Future<UserListResponse> getUsers({required int skip, required int limit, bool forceRefresh = false});
  Future<UserListResponse> searchUsers({required String query, required int skip, required int limit});
  Future<List<Post>> getUserPosts({required int userId, bool forceRefresh = false});
  Future<List<Todo>> getUserTodos({required int userId, bool forceRefresh = false});
  Future<User?> getCachedUserById(int userId); // For detail screen quick load
}

class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource remoteDataSource;
  final UserLocalDataSource localDataSource;

  UserRepositoryImpl({required this.remoteDataSource, required this.localDataSource});

  Future<bool> _isConnected() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult.contains(ConnectivityResult.mobile) ||
        connectivityResult.contains(ConnectivityResult.wifi)) {
      return true;
    }
    return false;
  }

  @override
  Future<UserListResponse> getUsers({required int skip, required int limit, bool forceRefresh = false}) async {
    if (await _isConnected()) {
      try {
        if (forceRefresh && skip == 0) { // Only clear all users cache on initial pull-to-refresh
          await localDataSource.cacheUsers([]); // Clear existing before fetching new
        }
        final remoteResponse = await remoteDataSource.getUsers(skip: skip, limit: limit);
        if (skip == 0) { // Cache only the first page or handle append carefully
             await localDataSource.cacheUsers(remoteResponse.users);
        } else {
            // For pagination, decide if you want to append to cache or if cache is mainly for offline first page
            final currentCachedUsers = await localDataSource.getUsers();
            final combinedUsers = List<User>.from(currentCachedUsers)..addAll(remoteResponse.users);
            // Remove duplicates if any before caching
            final uniqueUsers = {for (var user in combinedUsers) user.id: user}.values.toList();
            await localDataSource.cacheUsers(uniqueUsers);
        }
        return remoteResponse;
      } catch (e) {
        // If API fails and it's the first page, try to load from cache
        if (skip == 0) {
          final cachedUsers = await localDataSource.getUsers();
          if (cachedUsers.isNotEmpty) {
            return UserListResponse(users: cachedUsers, total: cachedUsers.length, skip: 0, limit: limit);
          }
        }
        rethrow; // Propagate error if cache is empty or not first page
      }
    } else {
      // Offline: Load from cache
      final cachedUsers = await localDataSource.getUsers();
      // Simulate pagination for cached data if needed, or just return what's available
      final paginatedCachedUsers = cachedUsers.skip(skip).take(limit).toList();
      if (paginatedCachedUsers.isNotEmpty || skip == 0) {
         return UserListResponse(users: paginatedCachedUsers, total: cachedUsers.length, skip: skip, limit: limit);
      }
      throw Exception('No internet connection and no cached data available.');
    }
  }

  @override
  Future<UserListResponse> searchUsers({required String query, required int skip, required int limit}) async {
     if (await _isConnected()) {
        final remoteResponse = await remoteDataSource.searchUsers(query: query, skip: skip, limit: limit);
        // Optionally cache search results, though they can be volatile
        return remoteResponse;
     } else {
        // Simple local search (can be improved with more sophisticated local indexing)
        final allCachedUsers = await localDataSource.getUsers();
        final filteredUsers = allCachedUsers.where((user) =>
            user.firstName.toLowerCase().contains(query.toLowerCase()) ||
            user.lastName.toLowerCase().contains(query.toLowerCase()) ||
            user.email.toLowerCase().contains(query.toLowerCase())
        ).toList();
        final paginatedResults = filteredUsers.skip(skip).take(limit).toList();
        return UserListResponse(users: paginatedResults, total: filteredUsers.length, skip: skip, limit: limit);
     }
  }

  @override
  Future<List<Post>> getUserPosts({required int userId, bool forceRefresh = false}) async {
    if (await _isConnected()) {
      try {
        if(forceRefresh) {
           // Clear specific user's posts from cache
           final currentPosts = await localDataSource.getUserPosts(userId);
           // Create a way to remove only these specific posts if Hive allows, or refetch all for this user.
           // For simplicity, we'll just overwrite with new data.
        }
        final remotePosts = await remoteDataSource.getUserPosts(userId: userId);
        await localDataSource.cacheUserPosts(userId, remotePosts);
        return remotePosts;
      } catch (e) {
        final cachedPosts = await localDataSource.getUserPosts(userId);
        if (cachedPosts.isNotEmpty) return cachedPosts;
        rethrow;
      }
    } else {
      final cachedPosts = await localDataSource.getUserPosts(userId);
      if (cachedPosts.isNotEmpty) return cachedPosts;
      throw Exception('No internet connection and no cached posts.');
    }
  }

  @override
  Future<List<Todo>> getUserTodos({required int userId, bool forceRefresh = false}) async {
     if (await _isConnected()) {
      try {
        if(forceRefresh){
            // Similar logic for clearing cached todos for the user
        }
        final remoteTodos = await remoteDataSource.getUserTodos(userId: userId);
        await localDataSource.cacheUserTodos(userId, remoteTodos);
        return remoteTodos;
      } catch (e) {
        final cachedTodos = await localDataSource.getUserTodos(userId);
        if (cachedTodos.isNotEmpty) return cachedTodos;
        rethrow;
      }
    } else {
      final cachedTodos = await localDataSource.getUserTodos(userId);
      if (cachedTodos.isNotEmpty) return cachedTodos;
      throw Exception('No internet connection and no cached todos.');
    }
  }
  
  @override
  Future<User?> getCachedUserById(int userId) async {
    return localDataSource.getUserById(userId);
  }
}