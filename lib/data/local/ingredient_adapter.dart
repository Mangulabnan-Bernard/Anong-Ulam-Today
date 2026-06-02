import 'package:hive_ce/hive_ce.dart';

import '../models/ingredient.dart';

/// Hand-written Hive adapter for [Ingredient] (no code generation).
///
/// Field-numbered, generated-style layout so new fields can be appended
/// without breaking already-persisted fridge data. [category] is stored by
/// its enum index; unknown/out-of-range indexes fall back to
/// [IngredientCategory.iba] so a future enum reorder can't crash on read.
class IngredientAdapter extends TypeAdapter<Ingredient> {
  @override
  final int typeId = 1;

  @override
  Ingredient read(BinaryReader reader) {
    final count = reader.readByte();
    final fields = <int, dynamic>{
      for (var i = 0; i < count; i++) reader.readByte(): reader.read(),
    };
    final categoryIndex = fields[3] as int? ?? IngredientCategory.iba.index;
    return Ingredient(
      id: fields[0] as String,
      name: fields[1] as String,
      nameEn: fields[2] as String,
      category: categoryIndex >= 0 &&
              categoryIndex < IngredientCategory.values.length
          ? IngredientCategory.values[categoryIndex]
          : IngredientCategory.iba,
      emoji: fields[4] as String? ?? '🥘',
    );
  }

  @override
  void write(BinaryWriter writer, Ingredient obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.nameEn)
      ..writeByte(3)
      ..write(obj.category.index)
      ..writeByte(4)
      ..write(obj.emoji);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IngredientAdapter && runtimeType == other.runtimeType;
}
