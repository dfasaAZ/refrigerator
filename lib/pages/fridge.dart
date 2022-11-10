import 'package:flutter/material.dart';
import 'package:refrigerator/db/database.dart';
import 'package:refrigerator/model/fridgemodel.dart';
import 'package:path/path.dart';
import 'package:refrigerator/model/productmodel.dart';
import 'package:sqflite/sqflite.dart';

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

  Future refreshFridgePage(int id) async {
    setState(() => isLoading = true);
    products = await Mydb.instance.readAllProductsFridge(id);

    setState(() {
      isLoading = false;
    });
  }

  Future deleteProduct(int id) async {
    await Mydb.instance.deleteProducts(id);
    refreshFridgePage(widget.args);
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
      body: Column(
        children: [
          Row(
            children: [
              TextButton(
                onPressed: () async {
                  products.isNotEmpty
                      ? await deleteProduct(
                          products[products.length - 1].id ?? 1)
                      : throw Exception("Not enough rows in table products");
                },
                child: const Text("Убрать последний элемент"),
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
                : ListView.builder(
                    itemCount: products.length,
                    itemBuilder: (BuildContext context, int index) {
                      int nidex = index + 1;
                      return TextField(
                        decoration: InputDecoration(
                            labelText:
                                ("${products[index].id},${products[index].fridge_id},${products[index].productName},${products[index].exp_date},${products[index].measure},${products[index].quantity}")),

                        readOnly: true,
                        // onTap: () async {
                        //   await deleteFridge(fridges[index].id ?? 1);
                        // },
                        onTap: () {
                          //TODO:open product card
                        },
                      );
                    },
                  ),
          )
        ],
        // Navigator.pop(context); //выход отсюда
      ),
    );
  }
}
