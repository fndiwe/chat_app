import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String? bio;
  String? profilePhotoUrl;
  final Timestamp timestamp;

  AppUser(
      {required this.id,
      required this.email,
      required this.firstName,
      required this.lastName,
      this.bio,
      this.profilePhotoUrl,
      required this.timestamp});

  Map<String, dynamic> toMap() => {
        "email": email,
        "first_name": firstName,
        "last_name": lastName,
        "bio": bio,
        "profile_photo_url": profilePhotoUrl,
        "timestamp": timestamp
      };
      
  String get fullName => "$firstName $lastName";

  factory AppUser.fromMap(Map<String?, dynamic> map) {
    return AppUser(
        id: map["id"],
        email: map['email'],
        firstName: map["first_name"],
        lastName: map["last_name"],
        bio: map["bio"],
        profilePhotoUrl: map["profile_photo_url"],
        timestamp: map["timestamp"]);
  }
}