import 'user_model.dart';

class UserListResponse {
  final List<User> users;
  final int total;
  final int skip;
  final int limit;

  UserListResponse({
    required this.users,
    required this.total,
    required this.skip,
    required this.limit,
  });

  factory UserListResponse.fromJson(Map<String, dynamic> json) {
    var userList = json['users'] as List;
    List<User> users = userList.map((i) => User.fromJson(i)).toList();
    return UserListResponse(
      users: users,
      total: json['total'],
      skip: json['skip'],
      limit: json['limit'],
    );
  }
}