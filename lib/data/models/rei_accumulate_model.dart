import 'base_model.dart';

/// Model untuk hasil akumulasi REI (Respect, Equity, Inclusion)
class ReiAccumulateModel extends BaseModel {
  @override
  final String id;
  final String userId;
  final int respect;
  final int equity;
  final int inclusion;
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
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ReiAccumulateModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      respect: respect ?? this.respect,
      equity: equity ?? this.equity,
      inclusion: inclusion ?? this.inclusion,
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
    return 'ReiAccumulateModel(id: $id, userId: $userId, respect: $respect, equity: $equity, inclusion: $inclusion, total: $totalScore)';
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
        inclusion.hashCode;
  }
}
