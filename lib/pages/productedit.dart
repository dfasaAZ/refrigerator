//import 'dart:html';

// ignore_for_file: unnecessary_import

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:refrigerator/db/database.dart';
import 'package:refrigerator/main.dart';
import 'package:refrigerator/model/productmodel.dart';
import 'package:refrigerator/notifications/local_notifications.dart';

//List<int> quantity = [1, 2];
// void fillQuantity() {
//   for (int i = 3; i < 99; i++) {
//     quantity.add(i);
//   }
//   ;
// }

Set<DropdownMenuItem<String>>? testquantity;
Set<DropdownMenuItem<String>> measure = {
  const DropdownMenuItem(
    value: "шт",
    child: Text("шт"),
  ),
  const DropdownMenuItem(
    value: "кг",
    child: Text("кг"),
  ),
  const DropdownMenuItem(
    value: "л",
    child: Text("л"),
  ),
  const DropdownMenuItem(
    value: "гр",
    child: Text("гр"),
  ),
};
// void fillQuantity() {
//   for (int i = 2; i < 99; i++) {
//     DropdownMenuItem<String> temp = DropdownMenuItem(
//       value: i.toString(),
//       child: Text(i.toString()),
//     );
//     testquantity?.add(temp);
//   }
// }

class ProductEditPage extends StatefulWidget {
  final int args;
  const ProductEditPage(this.args, {super.key});
  @override
  State<StatefulWidget> createState() => _ProductEditPageState();
}

class _ProductEditPageState extends State<ProductEditPage> {
  late Products product = Products(
      fridge_id: 1,
      productName: "1",
      exp_date: DateTime.now(),
      quantity: 1,
      measure: "шт");
  DateTime selecteddate = DateTime.now();
  bool isLoading = false;
  @override
  void initState() {
    DropdownMenuItem<String> temp;
    if (testquantity == null) {
      testquantity = {const DropdownMenuItem(value: "1", child: Text("1"))};
      for (int i = 2; i < 101; i++) {
        temp = DropdownMenuItem(
          value: i.toString(),
          child: Text(i.toString()),
        );
        testquantity?.add(temp);
      }
    }
    refreshProductEditPage(widget.args);

    super.initState();
  }

  late final LocalNotificationService service;

  void listenToNotification() =>
      service.onNotificationClick.stream.listen(onNoticationListener);
  void onNoticationListener(String? payload) {
    if (payload != null && payload.isNotEmpty) {
      print('payload $payload');

      // Navigator.push(
      //     context,
      //     MaterialPageRoute(
      //         builder: ((context) => FridgePage(payload))));
    }
  }

  Future _calendar(BuildContext context) async {
    final DateTime? date = await showDatePicker(
        context: context,
        initialEntryMode: DatePickerEntryMode.calendarOnly,
        initialDate: product.exp_date,
        firstDate: DateTime(2021),
        lastDate: DateTime(selecteddate.year + 30));
    if (date != null && date != selecteddate) {
      setState(() {
        selecteddate = date;
        product.exp_date = selecteddate;
        saveProduct();
      });
    }
  }

  Future saveProduct() async {
    Mydb.instance.updateProducts(product);

    if (product.exp_date.isAfter(DateTime.now())) {
      await LocalNotificationService().showScheduledNotification(
          id: product.id!,
          title: "Сроки годности",
          body:
              "Срок годности одного из ваших продуктов подходит к концу: ${product.productName}",
          date: product.exp_date);
    }

    // refreshProductEditPage(widget.args);
  }

  Future refreshProductEditPage(int id) async {
    setState(() => isLoading = true);
    product = await Mydb.instance.readOneProducts(id);

    setState(() {
      isLoading = false;
    });
  }

  void exit(context) {
    // testquantity = null;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    const double space = 10; //расстояние между блоками
    String selectedquantity = "1";
    String selectedmeasure = "шт";

    selectedquantity = product.quantity.toString();
    selectedmeasure = product.measure;
    selecteddate = product.exp_date;
    const borderpadding = EdgeInsets.all(8.0);

    //fillQuantity();
    //var filledQ = testquantity;
    //final List<int> filledQ = quantity;
    //final List<int> filledQ = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
    return Scaffold(
      resizeToAvoidBottomInset:
          false, //чтобы элементы не съезжали при открытии клавиатуры
      appBar: AppBar(
        leading: GestureDetector(
          child: const Icon(Icons.arrow_back),
          onTap: () {
            // exit(context);
            Navigator.pop(context);
          },
        ),
        title: Text('Изменение продукта'),
        // actions: [
        //   Padding(
        //     padding: const EdgeInsets.only(right: 6),
        //     child: GestureDetector(
        //       onTap: () => saveProduct(),
        //       child: const Icon(Icons.save_rounded),
        //     ),
        //   )
        // ],
      ),
      body: !isLoading
          ? DefaultTextStyle(
              style: Design.textDesign,
              child: Center(
                child: Column(children: [
                  Container(
                    padding: const EdgeInsets.only(top: 30, bottom: space),
                    child: SizedBox(
                      width: 200,
                      child: TextField(
                        decoration: Design.roundedInputBox,
                        textAlign: TextAlign.center,
                        controller: TextEditingController()
                          ..text = product.productName
                          ..selection = TextSelection.fromPosition(
                              TextPosition(offset: product.productName.length)),
                        onChanged: (String value) {
                          product.productName = value;
                        },
                      ),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.only(bottom: space),
                        child: IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(right: space),
                                child: Container(
                                  decoration: Design.roundedTextBox,
                                  child: const Padding(
                                    padding: borderpadding,
                                    child: Center(
                                      child: Text(
                                        "Дата окончания срока годности",
                                        style: Design.textDesign,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                decoration: Design.roundedETextBox,
                                padding: borderpadding,
                                child: TextButton(
                                  onPressed: (() => _calendar(context)),
                                  child: Text(
                                    "${product.exp_date.day.toString()}.${product.exp_date.month.toString()}.${product.exp_date.year.toString()}",
                                    style: Design.textDesign,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: space),
                              child: Container(
                                decoration: Design.roundedTextBox,
                                child: const Padding(
                                  padding: borderpadding,
                                  child: Center(
                                    child: Text(
                                      "Количество",
                                      style: Design.textDesign,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: space),
                              child: Container(
                                decoration: Design.roundedETextBox,
                                // decoration: BoxDecoration(
                                //     borderRadius: BorderRadius.circular(15.0),
                                //     border: Border.all(
                                //         style: BorderStyle.solid, width: 0.80)),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10.0),
                                  child: DropdownButton<String>(
                                    dropdownColor: Design.lightBlue,
                                    items: testquantity!.toList(),
                                    onChanged: (value) {
                                      product.quantity = int.parse(value!);
                                      setState(() {
                                        selectedquantity = value;
                                        //saveProduct();
                                      });
                                    },
                                    value: selectedquantity,
                                  ),
                                  //child: Text(product.quantity.toString()),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: space),
                              child: Container(
                                decoration: Design.roundedETextBox,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10.0),
                                  child: DropdownButton<String>(
                                    dropdownColor: Design.lightBlue,
                                    items: measure.toList(),
                                    onChanged: (value) {
                                      product.measure = value!;
                                      setState(() {
                                        selectedmeasure = value;
                                        //saveProduct();
                                      });
                                    },
                                    value: selectedmeasure,
                                  ),
                                  //child: Text(product.measure),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10) +
                          const EdgeInsets.only(bottom: 50),
                      child: Container(
                        // padding: EdgeInsets.symmetric(horizontal: 50),
                        decoration: Design.roundedETextBox,
                        child: TextButton(
                            style: TextButton.styleFrom(
                                minimumSize: const Size.fromHeight(60)),
                            onPressed: (() {
                              saveProduct();
                              Navigator.pop(context);
                            }),
                            child: const Text(
                              "Сохранить",
                              style: Design.textDesign,
                            )),
                      ),
                    ),
                  )
                ]),
              ),
            )
          : const Text("Загрузка продукта"),
    );
  }
}
