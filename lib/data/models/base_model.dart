/// Base model untuk semua model di aplikasi
abstract class BaseModel {
  String get id;
  DateTime get createdAt;
  DateTime get updatedAt;

  Map<String, dynamic> toJson();

  BaseModel copyWith();
}
