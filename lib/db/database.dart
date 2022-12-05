// ignore_for_file: depend_on_referenced_packages

import 'dart:async';

import 'package:path/path.dart';
import 'package:refrigerator/model/fridgemodel.dart';
import 'package:sqflite/sqflite.dart';
import 'package:refrigerator/model/productmodel.dart';

Future _onConfigure(Database db) async {
  await db.execute('PRAGMA foreign_keys = ON');
}

class Mydb {
  static final Mydb instance = Mydb._init();
  static Database? _database;
  Mydb._init();
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB("fridge.db");
    return _database!;
  }

  Future<Database> _initDB(String filepath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filepath);
    //Всё ,что выше - вообще не трогать
    return await openDatabase(path,
        version: 2,
        onCreate: _createDB,
        onConfigure: _onConfigure,
        onUpgrade:
            _onUpgrage); //когда буду редачить нужно поменять версию и дописать OnUpdate или что-то такое
  }

  FutureOr<void> _onUpgrage(Database db, int oldVersion, int newVersion) async {
    const idType = 'integer primary key autoincrement';
    const textType = 'TEXT NOT NULL';
    const intType = 'INTEGER NOT NULL';
    await db.execute('PRAGMA foreign_keys = ON');
    await db.execute('''drop table $tableFridges''');
    await db.execute('''Create table $tableFridges (
${FridgesFields.id} $idType,
${FridgesFields.fridgeName} $textType 
    )'''); //sql запрос на создание таблицы холодильники
    await db.execute('''Create table $tableproducts (
${ProductsFields.id} $idType,
${ProductsFields.fridge_id} $intType,
${ProductsFields.productName} $textType,
${ProductsFields.exp_date} $textType,
${ProductsFields.quantity} $intType,
${ProductsFields.measure} $textType,
FOREIGN KEY (${ProductsFields.fridge_id}) REFERENCES $tableFridges (${FridgesFields.id}) 
on delete cascade on update cascade
    )'''); //sql запрос на создание таблицы холодильники
  }

  Future _createDB(Database db, int version) async {
    const idType = 'integer primary key autoincrement';
    const textType = 'TEXT NOT NULL';
    // ignore: unused_local_variable
    const intType = 'INTEGER NOT NULL';
    //выше сокращения для типов данных, чтобы при создании сто раз не писать
    await db.execute('''Create table $tableFridges (
${FridgesFields.id} $idType,
${FridgesFields.fridgeName} $textType 
    )'''); //sql запрос на создание таблицы холодильники
  }

/////////////////////////////ОБРАБОТКА ТАБЛИЦЫ ХОЛОДИЛЬНИКИ////////////////////
  Future<Fridge> createFridges(Fridge model) async {
    final db = await Mydb.instance.database; //получение базы данных
    final id = await db.insert(tableFridges, model.toJson());
    return model.copy(id: id);
  } //создать запись в таблице из переменной типа Fridge

  Future<Fridge> readOneFridges(int id) async {
    final db = await Mydb.instance.database; //получение базы данных
    final result = await db.query(
      tableFridges,
      columns: FridgesFields.values,
      where: '${FridgesFields.id} =?',
      whereArgs: [id],
    );
    if (result.isNotEmpty) {
      return Fridge.fromJson(result.first);
    } else {
      throw Exception('No such id :$id');
    }
  } //Чтение одной записи по айди из таблицы холодильники

  Future<List<Fridge>> readAllFridges() async {
    final db = await Mydb.instance.database; //получение базы данных
    final result =
        await db.query(tableFridges, orderBy: '${FridgesFields.id} asc');
    return result.map((json) => Fridge.fromJson(json)).toList();
  }

  Future<int> updateFridges(Fridge fridge) async {
    final db = await Mydb.instance.database; //получение базы данных
    return db.update(
      tableFridges,
      fridge.toJson(),
      where: '${FridgesFields.id}=?',
      whereArgs: [fridge.id],
    );
  }

  addFridges(Map<String, dynamic> fridge) async {
    final db = await Mydb.instance.database; //получение базы данных
    return db.insert(
      tableFridges,
      fridge,
    );
  }

  Future<int> lastFridge() async {
    final db = await Mydb.instance.database; //получение базы данных
    final result =
        await db.query(tableFridges, orderBy: '${FridgesFields.id} desc');
    return result.map((json) => Fridge.fromJson(json)).toList().first.id!;
  }

  Future<int> countFridges() async {
    final db = await Mydb.instance.database; //получение базы данных
    List<Map> list = await db.rawQuery('select * from fridges');
    return list.length;
  }

  deleteFridges(int id) async {
    final db = await Mydb.instance.database; //получение базы данных
    return await db.delete(
      tableFridges,
      where: '${FridgesFields.id}=?',
      whereArgs: [id],
    );
  }

///////////////////ОБРАБОТКА ТАБЛИЦЫ ПРОДУКТЫ///////////////////////////////////

  Future<Products> createProducts(Products model) async {
    final db = await Mydb.instance.database; //получение базы данных
    final id = await db.insert(tableproducts, model.toJson());
    return model.copy(id: id);
  }

//создать запись в таблице из переменной типа Products
  Future<Products> readOneProducts(int id) async {
    final db = await Mydb.instance.database; //получение базы данных
    final result = await db.query(
      tableproducts,
      columns: ProductsFields.values,
      where: '${ProductsFields.id} =?',
      whereArgs: [id],
    );
    if (result.isNotEmpty) {
      return Products.fromJson(result.first);
    } else {
      throw Exception('No such id :$id');
    }
  } //Чтение одной записи по айди из таблицы холодильники

  Future<List<Products>> readAllProducts() async {
    final db = await Mydb.instance.database; //получение базы данных
    final result =
        await db.query(tableproducts, orderBy: '${ProductsFields.id} asc');
    return result.map((json) => Products.fromJson(json)).toList();
  }

  Future<List<Products>> readAllProductsFridge(int id) async {
    final db = await Mydb.instance.database; //получение базы данных
    final result = await db.query(tableproducts,
        where: '${ProductsFields.fridge_id} = ?',
        whereArgs: [id],
        orderBy: '${ProductsFields.id} asc');
    return result.map((json) => Products.fromJson(json)).toList();
  }

  Future<int> updateProducts(Products product) async {
    final db = await Mydb.instance.database; //получение базы данных
    return db.update(
      tableproducts,
      product.toJson(),
      where: '${ProductsFields.id}=?',
      whereArgs: [product.id],
    );
  }

  addProducts(Map<String, dynamic> product) async {
    final db = await Mydb.instance.database; //получение базы данных
    return db.insert(
      tableproducts,
      product,
    );
  }

  Future<int> countProducts() async {
    final db = await Mydb.instance.database; //получение базы данных
    List<Map> list = await db.rawQuery('select * from Products');
    return list.length;
  }

  Future<int> lastProduct(int fridgeId) async {
    final db = await Mydb.instance.database; //получение базы данных
    final result = await db.query(tableproducts,
        where: '${ProductsFields.fridge_id} = ?',
        whereArgs: [fridgeId],
        orderBy: '${ProductsFields.id} desc');
    return result.map((json) => Products.fromJson(json)).toList().first.id!;
  }

  deleteProducts(int id) async {
    final db = await Mydb.instance.database; //получение базы данных
    return await db.delete(
      tableproducts,
      where: '${ProductsFields.id}=?',
      whereArgs: [id],
    );
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
