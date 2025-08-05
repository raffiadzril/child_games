/// Model untuk option
class OptionModel {
  final String id;
  final String questionId;
  final String? optionLabel;
  final String? optionText;
  final String? imageUrl;
  final int scoreOption;

  OptionModel({
    required this.id,
    required this.questionId,
    this.optionLabel,
    this.optionText,
    this.imageUrl,
    this.scoreOption = 0,
  });

  factory OptionModel.fromJson(Map<String, dynamic> json) {
    return OptionModel(
      id: json['id'] as String,
      questionId: json['question_id'] as String,
      optionLabel: json['option_label'] as String?,
      optionText: json['option_text'] as String?,
      imageUrl: json['image_url'] as String?,
      scoreOption: json['score_option'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question_id': questionId,
      'option_label': optionLabel,
      'option_text': optionText,
      'image_url': imageUrl,
      'score_option': scoreOption,
    };
  }

  /// Helper getter untuk kompatibilitas
  bool get isCorrect => scoreOption > 0;
}
