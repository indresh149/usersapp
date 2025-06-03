import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'user_model.g.dart'; // Hive will generate this

@HiveType(typeId: 0)
class User extends Equatable {
  @HiveField(0)
  final int id;
  @HiveField(1)
  final String firstName;
  @HiveField(2)
  final String lastName;
  @HiveField(3)
  final String email;
  @HiveField(4)
  final String image;
  @HiveField(5)
  final String? phone;
  @HiveField(6)
  final String? username;
  @HiveField(7)
  final Address? address; // Add other fields as needed

  const User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.image,
    this.phone,
    this.username,
    this.address,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      firstName: json['firstName'] ?? 'N/A',
      lastName: json['lastName'] ?? '',
      email: json['email'] ?? 'N/A',
      image: json['image'] ?? '',
      phone: json['phone'],
      username: json['username'],
      address: json['address'] != null ? Address.fromJson(json['address']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'image': image,
      'phone': phone,
      'username': username,
      'address': address?.toJson(),
    };
  }
  
  String get fullName => '$firstName $lastName';

  @override
  List<Object?> get props => [id, firstName, lastName, email, image, phone, username, address];
}

@HiveType(typeId: 1) // Ensure unique typeId
class Address extends Equatable {
  @HiveField(0)
  final String? address;
  @HiveField(1)
  final String? city;
  @HiveField(2)
  final String? postalCode;

  const Address({this.address, this.city, this.postalCode});

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      address: json['address'],
      city: json['city'],
      postalCode: json['postalCode'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'address': address,
      'city': city,
      'postalCode': postalCode,
    };
  }

  @override
  List<Object?> get props => [address, city, postalCode];
}