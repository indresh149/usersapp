import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:usersapp/data/models/user_list_response_model.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/user_repository.dart';
import 'package:rxdart/rxdart.dart'; // For debounce

part 'user_list_event.dart';
part 'user_list_state.dart';

class UserListBloc extends Bloc<UserListEvent, UserListState> {
  final UserRepository userRepository;
  int _currentPage = 0; // 0-indexed for skip calculation
  bool _isFetching = false;
  String _currentQuery = '';

  UserListBloc({required this.userRepository}) : super(UserListInitial()) {
    on<FetchUsers>(_onFetchUsers);
    on<FetchMoreUsers>(_onFetchMoreUsers, transformer: _throttleDroppable());
    on<SearchUsers>(_onSearchUsers, transformer: _debounceSearch());
  }

  // Debounce for search
  EventTransformer<Event> _debounceSearch<Event>() {
    return (events, mapper) => events.debounceTime(const Duration(milliseconds: 500)).asyncExpand(mapper);
  }

  // Throttle for infinite scroll to prevent multiple rapid fetches
  EventTransformer<Event> _throttleDroppable<Event>() {
    return (events, mapper) => events.throttleTime(const Duration(milliseconds: 300), leading: true, trailing: false).asyncExpand(mapper);
  }


  Future<void> _onFetchUsers(FetchUsers event, Emitter<UserListState> emit) async {
    _currentPage = 0;
    _currentQuery = ''; // Reset search query
    emit(UserListLoading(isFirstFetch: true));
    try {
      final response = await userRepository.getUsers(
        skip: 0, 
        limit: AppConstants.usersPerPage,
        forceRefresh: event.isRefresh,
      );
      emit(UserListLoaded(users: response.users, totalUsers: response.total, hasReachedMax: response.users.length >= response.total));
    } catch (e) {
      emit(UserListError(message: e.toString()));
    }
  }

  Future<void> _onSearchUsers(SearchUsers event, Emitter<UserListState> emit) async {
    _currentPage = 0;
    _currentQuery = event.query;

    if (_currentQuery.isEmpty) {
      add(const FetchUsers()); // If search is cleared, fetch all users
      return;
    }
    
    emit(UserListLoading(isFirstFetch: true)); // Indicate loading for new search
    try {
      final response = await userRepository.searchUsers(
        query: _currentQuery, 
        skip: 0, 
        limit: AppConstants.usersPerPage
      );
      emit(UserListLoaded(users: response.users, totalUsers: response.total, hasReachedMax: response.users.length >= response.total));
    } catch (e) {
      emit(UserListError(message: e.toString()));
    }
  }


  Future<void> _onFetchMoreUsers(FetchMoreUsers event, Emitter<UserListState> emit) async {
    if (state is UserListLoaded && !(state as UserListLoaded).hasReachedMax && !_isFetching) {
      _isFetching = true;
      final currentState = state as UserListLoaded;
      _currentPage++;
      int skip = _currentPage * AppConstants.usersPerPage;

      // emit(UserListLoading(oldUsers: currentState.users, isFirstFetch: false)); // Optional: show loading at bottom

      try {
        late final UserListResponse response;
        if (_currentQuery.isEmpty) {
          response = await userRepository.getUsers(skip: skip, limit: AppConstants.usersPerPage);
        } else {
          response = await userRepository.searchUsers(query: _currentQuery, skip: skip, limit: AppConstants.usersPerPage);
        }
        
        final newUsers = response.users;
        final allUsers = List<User>.from(currentState.users)..addAll(newUsers);
        emit(UserListLoaded(
          users: allUsers,
          totalUsers: response.total,
          hasReachedMax: allUsers.length >= response.total || newUsers.isEmpty,
        ));
      } catch (e) {
        // Could emit an error specific to pagination or revert to previous loaded state
        emit(UserListError(message: "Failed to load more users: ${e.toString()}")); // Or UserListLoaded with old data and an error flag
        _currentPage--; // Revert page count on error
      } finally {
        _isFetching = false;
      }
    }
  }
}