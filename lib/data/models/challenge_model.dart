import 'base_model.dart';

/// Model untuk challenges
class ChallengeModel extends BaseModel {
  final String id;
  final String title;
  final String description;
  final String? imageUrl;
  final String? category;
  final DateTime createdAt;
  final DateTime updatedAt;

  ChallengeModel({
    required this.id,
    required this.title,
    required this.description,
    this.imageUrl,
    this.category,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ChallengeModel.fromJson(Map<String, dynamic> json) {
    return ChallengeModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      imageUrl: json['image_url'] as String?,
      category: json['category'] as String?,
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
      'title': title,
      'description': description,
      'image_url': imageUrl,
      'category': category,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  @override
  ChallengeModel copyWith({
    String? id,
    String? title,
    String? description,
    String? imageUrl,
    String? category,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ChallengeModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
