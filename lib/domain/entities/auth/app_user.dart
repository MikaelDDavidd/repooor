class AppUser {
  const AppUser({required this.id, required this.email, required this.name});

  final String id;
  final String email;
  final String name;

  AppUser copyWith({String? id, String? email, String? name}) {
    return AppUser(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is AppUser &&
        other.id == id &&
        other.email == email &&
        other.name == name;
  }

  @override
  int get hashCode => Object.hash(id, email, name);
}
