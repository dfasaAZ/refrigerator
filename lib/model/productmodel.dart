// ignore_for_file: non_constant_identifier_names, constant_identifier_names
///название таблицы продукты
const String tableproducts = "Products";

///полный список полей
class ProductsFields {
  static final List<String> values = [
    id,
    fridge_id,
    productName,
    exp_date,
    quantity,
    measure
  ];

//поля таблицы продукты

  static const String id = '_id';
  static const String fridge_id = 'fridge_id';
  static const String productName = 'productName';
  static const String exp_date = 'exp_date';
  static const String quantity = 'quantity';
  static const String measure = 'measure';
}

class Products {
  final int? id;
  int fridge_id;
  String productName;
  DateTime exp_date;
  int quantity;
  String measure;
  // bool selected;
  Products({
    this.id,
    required this.fridge_id,
    required this.productName,
    required this.exp_date,
    required this.quantity,
    required this.measure,
    // this.selected = false,
  });

  ///Преобразование в формат для передачи базе данных
  Map<String, Object?> toJson() => {
        //даты и булевый тип нужно будет конвертировать
        //к булеву дописать   ? 1:0
        // к дате метод .toIso8601String()
        ProductsFields.id: id,
        ProductsFields.fridge_id: fridge_id,
        ProductsFields.productName: productName,
        ProductsFields.exp_date: exp_date.toIso8601String(),
        ProductsFields.quantity: quantity,
        ProductsFields.measure: measure,
      };

  ///Преобразование из результатов sql запроса в объект класса
  static Products fromJson(Map<String, Object?> json) => Products(
        //даты и булевый тип нужно будет конвертировать
        //к булеву дописать   ==1 вместо as Bool
        // к дате DateTime.parse(json[ProductsFields.названиеполя] as String)
        id: json[ProductsFields.id] as int?,
        fridge_id: json[ProductsFields.fridge_id] as int,
        productName: json[ProductsFields.productName] as String,
        exp_date: DateTime.parse(json[ProductsFields.exp_date] as String),
        quantity: json[ProductsFields.quantity] as int,
        measure: json[ProductsFields.measure] as String,
      );

  ///Получить копию объекта класса
  Products copy({
    int? id,
    int? fridge_id,
    String? productName,
    DateTime? exp_date,
    int? quantity,
    String? measure,
  }) =>
      Products(
        id: id ?? this.id,
        fridge_id: fridge_id ?? this.fridge_id,
        productName: productName ?? this.productName,
        exp_date: exp_date ?? this.exp_date,
        quantity: quantity ?? this.quantity,
        measure: measure ?? this.measure,
      );
}//работа с таблицей продукты