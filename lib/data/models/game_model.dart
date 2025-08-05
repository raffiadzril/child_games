import 'base_model.dart';

/// Model untuk game
class GameModel extends BaseModel {
  final String id;
  final String title;
  final String description;
  final String? imageUrl;
  final String category;
  final int minAge;
  final int maxAge;
  final String difficulty; // easy, medium, hard
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  GameModel({
    required this.id,
    required this.title,
    required this.description,
    this.imageUrl,
    required this.category,
    required this.minAge,
    required this.maxAge,
    required this.difficulty,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory GameModel.fromJson(Map<String, dynamic> json) {
    return GameModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      imageUrl: json['image_url'] as String?,
      category: json['category'] as String,
      minAge: json['min_age'] as int,
      maxAge: json['max_age'] as int,
      difficulty: json['difficulty'] as String,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
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
      'min_age': minAge,
      'max_age': maxAge,
      'difficulty': difficulty,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  @override
  GameModel copyWith({
    String? id,
    String? title,
    String? description,
    String? imageUrl,
    String? category,
    int? minAge,
    int? maxAge,
    String? difficulty,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return GameModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      minAge: minAge ?? this.minAge,
      maxAge: maxAge ?? this.maxAge,
      difficulty: difficulty ?? this.difficulty,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
