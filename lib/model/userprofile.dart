class UserProfile {
  final int? id;
  final String name;
  final DateTime dateOfBirth;

  UserProfile({this.id, required this.name, required this.dateOfBirth});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'dateOfBirth': dateOfBirth.toIso8601String(),
    };
  }
}