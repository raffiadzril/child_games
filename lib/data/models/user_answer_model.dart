import 'base_model.dart';
import 'package:uuid/uuid.dart';

/// Model untuk menyimpan jawaban user
class UserAnswerModel extends BaseModel {
  @override
  final String id;
  final String userId;
  final String questionId;
  final String selectedOptionId;
  final DateTime answeredAt;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  UserAnswerModel({
    String? id,
    required this.userId,
    required this.questionId,
    required this.selectedOptionId,
    DateTime? answeredAt,
  }) : id = id ?? const Uuid().v4(),
       answeredAt = answeredAt ?? DateTime.now(),
       createdAt = DateTime.now(),
       updatedAt = DateTime.now();

  factory UserAnswerModel.fromJson(Map<String, dynamic> json) {
    return UserAnswerModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      questionId: json['question_id'] as String,
      selectedOptionId: json['selected_option_id'] as String,
      answeredAt: DateTime.parse(json['answered_at'] as String),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'question_id': questionId,
      'selected_option_id': selectedOptionId,
      'answered_at': answeredAt.toIso8601String(),
    };
  }

  @override
  UserAnswerModel copyWith({
    String? id,
    String? userId,
    String? questionId,
    String? selectedOptionId,
    DateTime? answeredAt,
  }) {
    return UserAnswerModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      questionId: questionId ?? this.questionId,
      selectedOptionId: selectedOptionId ?? this.selectedOptionId,
      answeredAt: answeredAt ?? this.answeredAt,
    );
  }

  @override
  String toString() {
    return 'UserAnswerModel(id: $id, userId: $userId, questionId: $questionId, selectedOptionId: $selectedOptionId, answeredAt: $answeredAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserAnswerModel &&
        other.id == id &&
        other.userId == userId &&
        other.questionId == questionId &&
        other.selectedOptionId == selectedOptionId &&
        other.answeredAt == answeredAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        userId.hashCode ^
        questionId.hashCode ^
        selectedOptionId.hashCode ^
        answeredAt.hashCode;
  }
}
