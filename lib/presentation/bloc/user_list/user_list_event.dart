part of 'user_list_bloc.dart';

abstract class UserListEvent extends Equatable {
  const UserListEvent();

  @override
  List<Object?> get props => [];
}

class FetchUsers extends UserListEvent {
  final bool isRefresh;
  const FetchUsers({this.isRefresh = false});

   @override
  List<Object?> get props => [isRefresh];
}

class FetchMoreUsers extends UserListEvent {}

class SearchUsers extends UserListEvent {
  final String query;
  const SearchUsers({required this.query});

  @override
  List<Object?> get props => [query];
}