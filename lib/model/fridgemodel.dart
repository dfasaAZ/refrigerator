import 'package:refrigerator/db/database.dart';

const String tableFridges = "fridges"; //название таблицы холодильники

/// \brief полный список полей
class FridgesFields {
  static final List<String> values = [id, fridgeName]; //полный список полей

  static const String id = '_id';
  static const String fridgeName = 'fridgeName';
} //поля таблицы холодильники

class Fridge {
  final int? id;
  String fridgeName;
  Fridge({
    this.id,
    required this.fridgeName,
  });

  ///Преобразование в формат для передачи базе данных
  Map<String, Object?> toJson() => {
        //даты и булевый тип нужно будет конвертировать
        //к булеву дописать   ? 1:0
        // к дате метод .toIso8601String()
        FridgesFields.id: id,
        FridgesFields.fridgeName: fridgeName,
      };

  ///Преобразование из результатов sql запроса в объект класса
  static Fridge fromJson(Map<String, Object?> json) => Fridge(
        //даты и булевый тип нужно будет конвертировать
        //к булеву дописать   ==1 вместо as Bool
        // к дате DateTime.parse(json[FridgesFields.названиеполя] as String)
        id: json[FridgesFields.id] as int?,
        fridgeName: json[FridgesFields.fridgeName] as String,
      );

  ///Получить копию объекта класса
  Fridge copy({
    int? id,
    String? fridgeName,
    Mydb? instance,
  }) =>
      Fridge(
        id: id ?? this.id,
        fridgeName: fridgeName ?? this.fridgeName,
      );
}//работа с таблицкй холодильники


