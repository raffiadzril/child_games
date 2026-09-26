import 'base_model.dart';
import 'package:uuid/uuid.dart';

/// Model untuk user/player dengan biodata lengkap
class UserModel extends BaseModel {
  @override
  final String id;
  final String name;
  final String gender; // 'laki-laki' atau 'perempuan'
  final int age;
  final String? educationLevel; // 'SMP', 'SMA', 'Perguruan Tinggi', 'Umum'
  final String className; // Optional
  final String school; // Optional
  final String role; // Auto set ke 'murid'
  
  // Halaman Baru: Jenis Survei & Tentang Anda (Sports & Physical Activity Profile)
  final String? surveyType; // 'PRE' atau 'POST'
  final String? isActiveSportsMember; // 'Ya' / 'Tidak'
  final String? sportsDuration; // 'Tidak pernah aktif', 'Kurang dari 1 tahun', '1-2 tahun', '3-4 tahun', 'Lebih dari 4 tahun'
  final String? sportsFrequency; // 'Tidak pernah', '1 kali', '2 kali', '3-4 kali', '5 kali atau lebih'
  final String? sportsLiking; // 'Sangat tidak menyukai', 'Tidak menyukai', 'Biasa saja', 'Menyukai', 'Sangat menyukai'
  final String? hasSportsCompetition; // 'Ya' / 'Tidak'
  final String? likesSportsCompetition; // 'Ya' / 'Tidak'
  final String? competitionType; // 'Beregu' / 'Individu' / 'Keduanya'
  final String? competitionLevel; // 'Internasional', 'Nasional', 'Provinsi', 'Kabupaten', 'Kecamatan', 'Belum Pernah Juara'

  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  UserModel({
    String? id,
    required this.name,
    required this.gender,
    required this.age,
    this.educationLevel,
    this.className = '',
    this.school = '',
    this.role = 'murid',
    this.surveyType,
    this.isActiveSportsMember,
    this.sportsDuration,
    this.sportsFrequency,
    this.sportsLiking,
    this.hasSportsCompetition,
    this.likesSportsCompetition,
    this.competitionType,
    this.competitionLevel,
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
      educationLevel: json['education_level'] as String?,
      className: json['class'] as String? ?? '',
      school: json['school'] as String? ?? '',
      role: json['role'] as String? ?? 'murid',
      surveyType: json['survey_type'] as String?,
      isActiveSportsMember: json['is_active_sports_member'] as String?,
      sportsDuration: json['sports_duration'] as String?,
      sportsFrequency: json['sports_frequency'] as String?,
      sportsLiking: json['sports_liking'] as String?,
      hasSportsCompetition: json['has_sports_competition'] as String?,
      likesSportsCompetition: json['likes_sports_competition'] as String?,
      competitionType: json['competition_type'] as String?,
      competitionLevel: json['competition_level'] as String?,
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
      'education_level': educationLevel,
      'class': className,
      'school': school,
      'role': role,
      'survey_type': surveyType,
      'is_active_sports_member': isActiveSportsMember,
      'sports_duration': sportsDuration,
      'sports_frequency': sportsFrequency,
      'sports_liking': sportsLiking,
      'has_sports_competition': hasSportsCompetition,
      'likes_sports_competition': likesSportsCompetition,
      'competition_type': competitionType,
      'competition_level': competitionLevel,
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
    String? educationLevel,
    String? className,
    String? school,
    String? role,
    String? surveyType,
    String? isActiveSportsMember,
    String? sportsDuration,
    String? sportsFrequency,
    String? sportsLiking,
    String? hasSportsCompetition,
    String? likesSportsCompetition,
    String? competitionType,
    String? competitionLevel,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      gender: gender ?? this.gender,
      age: age ?? this.age,
      educationLevel: educationLevel ?? this.educationLevel,
      className: className ?? this.className,
      school: school ?? this.school,
      role: role ?? this.role,
      surveyType: surveyType ?? this.surveyType,
      isActiveSportsMember: isActiveSportsMember ?? this.isActiveSportsMember,
      sportsDuration: sportsDuration ?? this.sportsDuration,
      sportsFrequency: sportsFrequency ?? this.sportsFrequency,
      sportsLiking: sportsLiking ?? this.sportsLiking,
      hasSportsCompetition: hasSportsCompetition ?? this.hasSportsCompetition,
      likesSportsCompetition: likesSportsCompetition ?? this.likesSportsCompetition,
      competitionType: competitionType ?? this.competitionType,
      competitionLevel: competitionLevel ?? this.competitionLevel,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'UserModel(id: $id, name: $name, gender: $gender, age: $age, educationLevel: $educationLevel, role: $role, surveyType: $surveyType, competitionType: $competitionType, competitionLevel: $competitionLevel)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel &&
        other.id == id &&
        other.name == name &&
        other.gender == gender &&
        other.age == age &&
        other.educationLevel == educationLevel &&
        other.className == className &&
        other.school == school &&
        other.role == role &&
        other.surveyType == surveyType &&
        other.isActiveSportsMember == isActiveSportsMember &&
        other.sportsDuration == sportsDuration &&
        other.sportsFrequency == sportsFrequency &&
        other.sportsLiking == sportsLiking &&
        other.hasSportsCompetition == hasSportsCompetition &&
        other.likesSportsCompetition == likesSportsCompetition &&
        other.competitionType == competitionType &&
        other.competitionLevel == competitionLevel;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        gender.hashCode ^
        age.hashCode ^
        educationLevel.hashCode ^
        className.hashCode ^
        school.hashCode ^
        role.hashCode ^
        surveyType.hashCode ^
        isActiveSportsMember.hashCode ^
        sportsDuration.hashCode ^
        sportsFrequency.hashCode ^
        sportsLiking.hashCode ^
        hasSportsCompetition.hashCode ^
        likesSportsCompetition.hashCode ^
        competitionType.hashCode ^
        competitionLevel.hashCode;
  }
}

