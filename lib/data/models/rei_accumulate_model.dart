import 'base_model.dart';

/// Model untuk hasil akumulasi REI (Respect, Equity, Inclusion)
class ReiAccumulateModel extends BaseModel {
  @override
  final String id;
  final String userId;
  final int respect;
  final int equity;
  final int inclusion;
  // New optional fields from backend (labels, categories, notes)
  final String? labelAnakRamahCategory;
  final String? labelAnakRamahCategoryRespect;
  final String? labelAnakRamahCategoryEquity;
  final String? labelAnakRamahCategoryInclusion;
  final String? allCategory;
  final String? allNote;
  final String? respectCategory;
  final String? respectNote;
  final String? equityCategory;
  final String? equityNote;
  final String?
  inclusionCategory; // supports both inclusion_category/inclussion_category
  final String? inclusionNote;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  ReiAccumulateModel({
    required this.id,
    required this.userId,
    required this.respect,
    required this.equity,
    required this.inclusion,
    this.labelAnakRamahCategory,
    this.labelAnakRamahCategoryRespect,
    this.labelAnakRamahCategoryEquity,
    this.labelAnakRamahCategoryInclusion,
    this.allCategory,
    this.allNote,
    this.respectCategory,
    this.respectNote,
    this.equityCategory,
    this.equityNote,
    this.inclusionCategory,
    this.inclusionNote,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ReiAccumulateModel.fromJson(Map<String, dynamic> json) {
    return ReiAccumulateModel(
      id: json['id'].toString(), // bigint akan jadi string
      userId: json['user_id'] as String,
      respect: json['respect'] as int? ?? 0,
      equity: json['equity'] as int? ?? 0,
      inclusion: json['inclusion'] as int? ?? 0,
      // New optional fields
      labelAnakRamahCategory: json['label_anak_ramah_category'] as String?,
      labelAnakRamahCategoryRespect:
          json['label_anak_ramah_category_respect'] as String?,
      labelAnakRamahCategoryEquity:
          json['label_anak_ramah_category_equity'] as String?,
      labelAnakRamahCategoryInclusion:
          json['label_anak_ramah_category_inclusion'] as String?,
      allCategory: json['all_category'] as String?,
      allNote: json['all_note'] as String?,
      respectCategory: json['respect_category'] as String?,
      respectNote: json['respect_note'] as String?,
      equityCategory: json['equity_category'] as String?,
      equityNote: json['equity_note'] as String?,
      inclusionCategory:
          (json['inclusion_category'] as String?) ??
          (json['inclussion_category'] as String?),
      inclusionNote:
          (json['inclusion_note'] as String?) ??
          (json['inclussion_note'] as String?),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.now(), // Tidak ada updated_at di tabel
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'respect': respect,
      'equity': equity,
      'inclusion': inclusion,
      // Optional fields
      'label_anak_ramah_category': labelAnakRamahCategory,
      'label_anak_ramah_category_respect': labelAnakRamahCategoryRespect,
      'label_anak_ramah_category_equity': labelAnakRamahCategoryEquity,
      'label_anak_ramah_category_inclusion': labelAnakRamahCategoryInclusion,
      'all_category': allCategory,
      'all_note': allNote,
      'respect_category': respectCategory,
      'respect_note': respectNote,
      'equity_category': equityCategory,
      'equity_note': equityNote,
      'inclusion_category': inclusionCategory,
      'inclusion_note': inclusionNote,
      'created_at': createdAt.toIso8601String(),
    };
  }

  @override
  ReiAccumulateModel copyWith({
    String? id,
    String? userId,
    int? respect,
    int? equity,
    int? inclusion,
    String? labelAnakRamahCategory,
    String? labelAnakRamahCategoryRespect,
    String? labelAnakRamahCategoryEquity,
    String? labelAnakRamahCategoryInclusion,
    String? allCategory,
    String? allNote,
    String? respectCategory,
    String? respectNote,
    String? equityCategory,
    String? equityNote,
    String? inclusionCategory,
    String? inclusionNote,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ReiAccumulateModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      respect: respect ?? this.respect,
      equity: equity ?? this.equity,
      inclusion: inclusion ?? this.inclusion,
      labelAnakRamahCategory:
          labelAnakRamahCategory ?? this.labelAnakRamahCategory,
      labelAnakRamahCategoryRespect:
          labelAnakRamahCategoryRespect ?? this.labelAnakRamahCategoryRespect,
      labelAnakRamahCategoryEquity:
          labelAnakRamahCategoryEquity ?? this.labelAnakRamahCategoryEquity,
      labelAnakRamahCategoryInclusion:
          labelAnakRamahCategoryInclusion ??
          this.labelAnakRamahCategoryInclusion,
      allCategory: allCategory ?? this.allCategory,
      allNote: allNote ?? this.allNote,
      respectCategory: respectCategory ?? this.respectCategory,
      respectNote: respectNote ?? this.respectNote,
      equityCategory: equityCategory ?? this.equityCategory,
      equityNote: equityNote ?? this.equityNote,
      inclusionCategory: inclusionCategory ?? this.inclusionCategory,
      inclusionNote: inclusionNote ?? this.inclusionNote,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Get total REI score
  int get totalScore => respect + equity + inclusion;

  /// Get highest scoring category
  String get highestCategory {
    if (respect >= equity && respect >= inclusion) {
      return 'Respect';
    } else if (equity >= inclusion) {
      return 'Equity';
    } else {
      return 'Inclusion';
    }
  }

  /// Get category percentages
  Map<String, double> get categoryPercentages {
    final total = totalScore;
    if (total == 0) {
      return {'respect': 0.0, 'equity': 0.0, 'inclusion': 0.0};
    }

    return {
      'respect': (respect / total) * 100,
      'equity': (equity / total) * 100,
      'inclusion': (inclusion / total) * 100,
    };
  }

  @override
  String toString() {
    return 'ReiAccumulateModel(id: $id, userId: $userId, respect: $respect, equity: $equity, inclusion: $inclusion, total: $totalScore, allCategory: $allCategory, respectCategory: $respectCategory, equityCategory: $equityCategory, inclusionCategory: $inclusionCategory)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ReiAccumulateModel &&
        other.id == id &&
        other.userId == userId &&
        other.respect == respect &&
        other.equity == equity &&
        other.inclusion == inclusion;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        userId.hashCode ^
        respect.hashCode ^
        equity.hashCode ^
        inclusion.hashCode ^
        (allCategory?.hashCode ?? 0) ^
        (respectCategory?.hashCode ?? 0) ^
        (equityCategory?.hashCode ?? 0) ^
        (inclusionCategory?.hashCode ?? 0);
  }
}
