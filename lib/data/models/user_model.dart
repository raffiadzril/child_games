import 'base_model.dart';
import 'package:uuid/uuid.dart';

/// Model untuk user/player dengan biodata lengkap
class UserModel extends BaseModel {
  @override
  final String id;
  final String name;
  final String gender; // 'laki-laki' atau 'perempuan'
  final int age;
  final String
  className; // Menggunakan className karena class adalah reserved word
  final String school; // Nama sekolah
  final String role; // Auto set ke 'murid'
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  UserModel({
    String? id,
    required this.name,
    required this.gender,
    required this.age,
    required this.className,
    required this.school,
    this.role = 'murid',
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String,
      gender: json['gender'] as String,
      age: json['age'] as int,
      className: json['class'] as String,
      school: json['school'] as String? ?? '',
      role: json['role'] as String? ?? 'murid',
      createdAt:
          json['created_at'] != null
              ? DateTime.parse(json['created_at'] as String)
              : DateTime.now(),
      updatedAt:
          json['updated_at'] != null
              ? DateTime.parse(json['updated_at'] as String)
              : DateTime.now(),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'gender': gender,
      'age': age,
      'class': className,
      'school': school,
      'role': role,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  @override
  UserModel copyWith({
    String? id,
    String? name,
    String? gender,
    int? age,
    String? className,
    String? school,
    String? role,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      gender: gender ?? this.gender,
      age: age ?? this.age,
      className: className ?? this.className,
      school: school ?? this.school,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'UserModel(id: $id, name: $name, gender: $gender, age: $age, className: $className, school: $school, role: $role)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel &&
        other.id == id &&
        other.name == name &&
        other.gender == gender &&
        other.age == age &&
        other.className == className &&
        other.school == school &&
        other.role == role;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        gender.hashCode ^
        age.hashCode ^
        className.hashCode ^
        school.hashCode ^
        role.hashCode;
  }
}
