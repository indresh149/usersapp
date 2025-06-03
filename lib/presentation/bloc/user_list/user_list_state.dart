part of 'user_list_bloc.dart';

abstract class UserListState extends Equatable {
  const UserListState();

  @override
  List<Object?> get props => [];
}

class UserListInitial extends UserListState {}

class UserListLoading extends UserListState {
   final List<User> oldUsers;
   final bool isFirstFetch;

   const UserListLoading({this.oldUsers = const [], this.isFirstFetch = false});
   
   @override
  List<Object?> get props => [oldUsers, isFirstFetch];
}

class UserListLoaded extends UserListState {
  final List<User> users;
  final bool hasReachedMax;
  final int totalUsers;

  const UserListLoaded({required this.users, this.hasReachedMax = false, required this.totalUsers});

  @override
  List<Object?> get props => [users, hasReachedMax, totalUsers];
}

class UserListError extends UserListState {
  final String message;
  const UserListError({required this.message});

  @override
  List<Object?> get props => [message];
}