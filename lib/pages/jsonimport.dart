import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:refrigerator/db/database.dart';
import 'package:refrigerator/model/fridgemodel.dart';
import 'package:refrigerator/pages/fridge.dart';
import 'package:refrigerator/pages/productedit.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:refrigerator/model/productmodel.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

class JsonImportPage extends StatefulWidget {
  final int args;
  const JsonImportPage(this.args, {super.key});
  @override
  State<StatefulWidget> createState() => _JsonImportPageState();
}

///Страница импорта
class _JsonImportPageState extends State<JsonImportPage> {
  late List products = [];
  Map<String, dynamic>? JsonText;
  List<SharedMediaFile>? outsideFile;
  Map<String, bool> _selected = {}; //коды выбранных элементов в списке
  @override
  void initState() {
    //refreshJsonImportPage(widget.args);

    _openFile();

    super.initState();
  }

  ///Открытие файла
  Future _openFile() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: false);
    if (result == null) {
      Navigator.pop(context);
      return;
    }
    final path = result.files.first.path;
    File file = File(path!);
    try {
      JsonText = jsonDecode(await file.readAsString());
    } catch (e) {
      Navigator.pop(context);
      throw Exception("Ошибка чтения файла");
      return;
    }
    if (JsonText != null) {
      setState(() {
        try {
          products = JsonText?["items"];
        } catch (e) {
          Navigator.pop(context);
          return;
          throw Exception("Отстутствует список продуктов");
        }
        _selected = {for (var item in products) item["name"]: false};
      });
    }

    // print(JsonText);
  }

  void _onSelect(bool value, String name) {
    setState(() {
      _selected[name] = value;
    });
  }

  List<DataRow> fillForTable(List raw) {
    late List<DataRow> fProducts = [];
    for (int i = 0; i < raw.length; i++) {
      var elem = raw[i];
      fProducts.add(DataRow(
          selected: _selected[elem["name"]]!,
          onSelectChanged: (value) => _onSelect(value!, elem["name"]!),
          cells: [DataCell(Text(elem["name"]))]));
    }
    return fProducts;
  }

  ///Перенос продуктов в базу данных
  Future addProducts(BuildContext cont) async {
    final temp = Products(
        fridge_id: widget.args,
        productName: 'Название',
        exp_date: DateTime.now(),
        quantity: 1,
        measure: "шт");
    for (var unit in _selected.entries) {
      if (unit.value == true) {
        temp.productName = unit.key;

        double q = products
            .where((element) => element["name"] == unit.key)
            .first["quantity"] as double;
        temp.quantity = q.ceil();
        await Mydb.instance.createProducts(temp);
      }
    }
    Navigator.pop(cont);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Импорт продуктов"),
        actions: [
          GestureDetector(
            child: Icon(Icons.add_box),
            onTap: () {
              setState(() {
                addProducts(context);
                //Navigator.pop(context);
              });

              print("object");
            },
          )
        ],
      ),
      body: Column(
        children: [
          if (JsonText == null)
            Text("Загрузка")
          else
            SingleChildScrollView(
              child: DataTable(
                columns: [DataColumn(label: Text("Наименование"))],
                rows: fillForTable(products),
              ),
            )
        ],
      ),
    );
  }
}
