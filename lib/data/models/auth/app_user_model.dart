import 'package:appwrite/models.dart' as appwrite;
import '../../../domain/entities/auth/app_user.dart';

class AppUserModel {
  const AppUserModel({
    required this.id,
    required this.email,
    required this.name,
  });

  factory AppUserModel.fromMap(Map<String, dynamic> map) {
    return AppUserModel(
      id: map['id'] as String,
      email: map['email'] as String,
      name: map['name'] as String,
    );
  }

  factory AppUserModel.fromEntity(AppUser user) {
    return AppUserModel(id: user.id, email: user.email, name: user.name);
  }

  factory AppUserModel.fromAppwrite(appwrite.User user) {
    return AppUserModel(id: user.$id, email: user.email, name: user.name);
  }

  final String id;
  final String email;
  final String name;

  Map<String, dynamic> toMap() => {'id': id, 'email': email, 'name': name};

  AppUser toEntity() => AppUser(id: id, email: email, name: name);
}
