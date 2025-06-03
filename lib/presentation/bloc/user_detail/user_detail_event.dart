part of 'user_detail_bloc.dart';

abstract class UserDetailEvent extends Equatable {
  const UserDetailEvent();

  @override
  List<Object> get props => [];
}

class FetchUserAllDetails extends UserDetailEvent {
  final bool forceRefresh;
  const FetchUserAllDetails({this.forceRefresh = false});

  @override
  List<Object> get props => [forceRefresh];
}