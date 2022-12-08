// ignore_for_file: unused_import

import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:refrigerator/db/database.dart';
import 'package:refrigerator/main.dart';
import 'package:refrigerator/model/fridgemodel.dart';
import 'package:refrigerator/model/productmodel.dart';

class FridgePage extends StatefulWidget {
  final Map args;
  const FridgePage(this.args, {super.key});
  @override
  State<StatefulWidget> createState() => _FridgePageState();
}

class _FridgePageState extends State<FridgePage> {
  bool isLoading = false; //загружается ли сейчас что-либо

  late List<Products> products = []; //список продуктов
  late Fridge fridge = Fridge(fridgeName: "fridgeName");

  Map<int, bool> _selected = {}; //коды выбранных элементов в списке

  bool _showCheckBoxes = false; //показывать ли галочки
  void _onSelect(bool value, int i) {
    //обработка нажатий по строкам списка
    //saveFridge();
    {
      if (_showCheckBoxes) {
        setState(() {
          _selected[i] = value;
          if (_selected.values.every((element) => element == false)) {
            //скрывать галочки, если не выбран ни один элемент
            _showCheckBoxes = false;
          }
        });
      } else {
        //переход к продукту, если выключен режим выделения
        int productid = i;
        Navigator.pushNamed(context, '/fridge/productedit',
                arguments: productid)
            .then((_) => refreshFridgePage(widget.args["id"]));
      }
    }
  }

  //late Map selected = {};
  @override
  void initState() {
    refreshFridgePage(widget.args["id"]);
    super.initState();
    // Future.delayed(Duration.zero, () {
    //   setState(() {
    //     final args = ModalRoute.of(context)!.settings.arguments;
    //   });
    //   refreshFridgePage(args);
    // });
  }

  List<DataRow> fillForTable(List<Products> raw) {
    //заполнение списка продуктов
    late List<DataRow> fProducts = [];
    for (int i = 0; i < raw.length; i++) {
      var elem = raw[i];
      fProducts.add(DataRow(
          selected: _selected[elem.id]!,
          onSelectChanged: (value) => _onSelect(value!, elem.id!),
          // (value) {
          //   if (_showCheckBoxes) {
          //     setState(() {
          //       _selected[i] = value!;
          //       if (_selected.every((element) => element == false)) {
          //         _showCheckBoxes = false;
          //       }
          //     });
          //   }
          // },
          onLongPress: (() {
            setState(() {
              _selected[elem.id!] = true;
              _showCheckBoxes = true;
            });
          }),
          cells: [
            DataCell(
              Text("${elem.productName}"),
            ),
            DataCell(
              DateTime.now().isAfter(elem.exp_date)
                  ? const Text("Просрок")
                  : Text(
                      "${(elem.exp_date.difference(DateTime.now()).inHours / 24).ceil()}"),
            ),
            DataCell(
              Text("${elem.quantity} ${elem.measure}"),
            ),
          ]));
    }
    return fProducts;
  } //создание списка для подстановки в таблицу

  Future refreshFridgePage(int id) async {
    setState(() => isLoading = true);
    fridge = await Mydb.instance.readOneFridges(widget.args["id"]);
    products = await Mydb.instance.readAllProductsFridge(id);
    _selected = {for (var item in products) item.id!: false};

    //_selected = (products.length, ((index) => false));

    setState(() {
      isLoading = false;
    });
  }

  Future deleteProduct(int id) async {
    //удаление продукта по коду
    await Mydb.instance.deleteProducts(id);
    refreshFridgePage(widget.args["id"]);
  }

  void deleteSelected() {
    //удаление выбранных элементов
    _showCheckBoxes = false;
    for (var element in _selected.entries) {
      if (element.value == true) {
        deleteProduct(element.key);
      }
    }
  }

  void _showDeleteError() {
    //показать ошибку удаления
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          scrollable: true,
          title: const Text("Ошибка удаления"),
          content: const SingleChildScrollView(
            child: Text(
                style: TextStyle(color: Colors.black),
                overflow: TextOverflow.visible,
                "Не помечены элементы для удаления"),
          ),
          actions: <Widget>[
            OutlinedButton(
              child: const Text("Ок"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future addNewProduct() async {
    //добавление нового пустого продукта в бд
    final temp = Products(
        fridge_id: widget.args["id"],
        productName: 'Название',
        exp_date: DateTime.now(),
        quantity: 1,
        measure: "шт");
    Mydb.instance.createProducts(temp);
    refreshFridgePage(widget.args["id"]);
  }

  Future newProductCreation() async {
    //процесс создания продукта и перехода на страницу его редактирования
    addNewProduct();
    late int temp1;
    temp1 = await Mydb.instance.lastProduct(widget.args["id"]);
    //nt temp = products.last.id!;
    Navigator.pushNamed(context, '/fridge/productedit', arguments: temp1)
        .then((_) => refreshFridgePage(widget.args["id"]));
  }

  Future saveFridge() async {
    Mydb.instance.updateFridges(fridge);
    refreshFridgePage(widget.args["id"]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          child: const Icon(Icons.arrow_back),
          onTap: () {
            // exit(context);
            setState(() {
              saveFridge();
            });
            Navigator.pop(context);
          },
        ),
        //title: Text('Inside fridge ${widget.args["id"]}'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Container(
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 30),
              decoration: Design.roundedTextBox,
              child: const SizedBox(
                child: Center(
                  child: Text(
                    "Внутренности холодильника ",
                    style: Design.textDesignBig,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Container(
              width: MediaQuery.of(context).size.width / 2,
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 15),
              decoration: Design.roundedETextBox,
              child: SizedBox(
                child: Center(
                  child: TextField(
                    decoration: Design.roundedInputBox,
                    textAlign: TextAlign.center,
                    controller: TextEditingController()
                      ..text = fridge.fridgeName
                      ..selection = TextSelection.fromPosition(
                          TextPosition(offset: fridge.fridgeName.length)),
                    onChanged: (String value) {
                      fridge.fridgeName = value;
                    },
                    onEditingComplete: saveFridge,
                  ),
                  // child: Text(
                  //   "${widget.args["name"]}",
                  //   style: Design.textDesignBig,
                  //   textAlign: TextAlign.center,
                  // ),
                ),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: _selected.containsValue(true)
                    ? deleteSelected
                    : _showDeleteError,
                icon: const Icon(Icons.delete_outline_rounded),
                //child: const Text("Удалить выбранные элементы"),
              ),
              IconButton(
                onPressed: newProductCreation,
                icon: const Icon(Icons.add_circle_rounded),
                // child: const Text("Добавить новый"),
              ),
            ],
          ),
          Expanded(
              child: isLoading
                  ? const Text("Загрузка")
                  : products.isEmpty
                      ? const Text("Список пуст")
                      : DataTable(
                          columnSpacing: 30,
                          checkboxHorizontalMargin: 5,
                          showCheckboxColumn: _showCheckBoxes,
                          columns: const [
                            DataColumn(label: Text("Наименование")),
                            DataColumn(
                                label: Flexible(
                                    child: Text(
                              "Дней до окончания срока",
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ))),
                            DataColumn(label: Text("Кол-во"))
                          ],
                          rows: fillForTable(products),
                        ))
        ],
        // Navigator.pop(context); //выход отсюда
      ),
    );
  }
}
