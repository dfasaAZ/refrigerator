import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:refrigerator/db/database.dart';
import 'package:refrigerator/model/productmodel.dart';

class FridgePage extends StatefulWidget {
  final int args;
  const FridgePage(this.args, {super.key});
  @override
  State<StatefulWidget> createState() => _FridgePageState();
}

class _FridgePageState extends State<FridgePage> {
  bool isLoading = false;
  //var args;
  late List<Products> products = [];

  Map<int, bool> _selected = {};

  bool _showCheckBoxes = false;
  void _onSelect(bool value, int i) {
    {
      if (_showCheckBoxes) {
        setState(() {
          _selected[i] = value;
          if (_selected.values.every((element) => element == false)) {
            _showCheckBoxes = false;
          }
        });
      } else {
        int productid = i ?? 1;
        Navigator.pushNamed(context, '/fridge/productedit',
                arguments: productid)
            .then((_) => refreshFridgePage(widget.args));
      }
    }
  }

  //late Map selected = {};
  @override
  void initState() {
    refreshFridgePage(widget.args);
    super.initState();
    // Future.delayed(Duration.zero, () {
    //   setState(() {
    //     final args = ModalRoute.of(context)!.settings.arguments;
    //   });
    //   refreshFridgePage(args);
    // });
  }

  List<DataRow> fillForTable(List<Products> raw) {
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
              Text(
                  "${elem.id} ${elem.fridge_id} ${elem.productName} ${elem.quantity} ${elem.measure} ${elem.exp_date}"),
            )
          ]));
    }
    return fProducts;
  } //создание списка для подстановки в таблицу

  Future refreshFridgePage(int id) async {
    setState(() => isLoading = true);

    products = await Mydb.instance.readAllProductsFridge(id);
    _selected = {for (var item in products) item.id!: false};

    //_selected = (products.length, ((index) => false));

    setState(() {
      isLoading = false;
    });
  }

  Future deleteProduct(int id) async {
    await Mydb.instance.deleteProducts(id);
    refreshFridgePage(widget.args);
  }

  void deleteSelected() {
    _showCheckBoxes = false;
    for (var element in _selected.entries) {
      if (element.value == true) {
        deleteProduct(element.key);
      }
    }
  }

  void _showDeleteError() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          scrollable: true,
          title: const Text("Ошибка удаления"),
          content: SingleChildScrollView(
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
    final temp = Products(
        fridge_id: widget.args,
        productName: 'имя продукта',
        exp_date: DateTime.now(),
        quantity: 6,
        measure: "шт");
    Mydb.instance.createProducts(temp);
    refreshFridgePage(widget.args);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Inside fridge ${widget.args}'),
      ),
      body: isLoading
          ? const Text("Загрузка")
          : Column(
              children: [
                Row(
                  children: [
                    TextButton(
                      onPressed: _selected.containsValue(true)
                          ? deleteSelected
                          : _showDeleteError,
                      // () async {
                      //   products.isNotEmpty
                      //       ? await deleteProduct(
                      //           products[products.length - 1].id ?? 1)
                      //       : throw Exception(
                      //           "Not enough rows in table products");
                      // },
                      child: const Text("Удалить выбранные элементы"),
                    ),
                    Expanded(
                      child: TextButton(
                        onPressed: addNewProduct,
                        child: const Text("Добавить новый"),
                      ),
                    ),
                  ],
                ),
                Expanded(
                    child: products.isEmpty
                        ? const Text("Список пуст")
                        : DataTable(
                            showCheckboxColumn: _showCheckBoxes,
                            columns: [DataColumn(label: Text("Список"))],
                            rows: fillForTable(products),
                            // DataRow(cells: [DataCell(Text("data"))])
                          )
                    // : ListView.builder(
                    //     itemCount: products.length,
                    //     itemBuilder: (BuildContext context, int index) {
                    //       int nidex = index + 1;
                    //       return TextField(
                    //         decoration: InputDecoration(
                    //             labelText:
                    //                 ("${products[index].id},${products[index].fridge_id},${products[index].productName},${products[index].exp_date},${products[index].measure},${products[index].quantity}")),

                    //         readOnly: true,
                    //         // onTap: () async {
                    //         //   await deleteFridge(fridges[index].id ?? 1);
                    //         // },
                    //         onTap: () {
                    //           int productid = products[index].id ?? 1;
                    //           Navigator.pushNamed(context, '/fridge/productedit',
                    //                   arguments: productid)
                    //               .then((_) => refreshFridgePage(widget.args));
                    //         },
                    //       );
                    //     },
                    //   ),
                    )
              ],
              // Navigator.pop(context); //выход отсюда
            ),
    );
  }
}
