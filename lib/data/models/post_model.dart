import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'post_model.g.dart'; // Hive will generate this

@HiveType(typeId: 2) // Ensure unique typeId
class Post extends Equatable {
  @HiveField(0)
  final int id;
  @HiveField(1)
  final String title;
  @HiveField(2)
  final String body;
  @HiveField(3)
  final int userId;
  @HiveField(4)
  final List<String> tags;
  @HiveField(5)
  final int reactions;

  const Post({
    required this.id,
    required this.title,
    required this.body,
    required this.userId,
    required this.tags,
    required this.reactions,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      title: json['title'] ?? 'No Title',
      body: json['body'] ?? 'No Body',
      userId: json['userId'],
      tags: List<String>.from(json['tags'] ?? []),
      reactions: json['reactions'] is int ? json['reactions'] : (json['reactions']?['likes'] ?? 0), // API inconsistency
    );
  }

   Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'userId': userId,
      'tags': tags,
      'reactions': reactions,
    };
  }

  // For local post creation, ID might be different or temporary
  Post copyWith({int? id, String? title, String? body, int? userId}) {
    return Post(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      userId: userId ?? this.userId,
      tags: tags, // Keep original tags and reactions for simplicity
      reactions: reactions,
    );
  }


  @override
  List<Object?> get props => [id, title, body, userId, tags, reactions];
}