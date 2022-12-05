//import 'dart:html';

// ignore_for_file: unused_element, unused_field, unused_local_variable

import 'package:flutter/material.dart';
import 'package:refrigerator/db/database.dart';
import 'package:refrigerator/model/fridgemodel.dart';
import 'package:refrigerator/pages/fridge.dart';
import 'package:refrigerator/pages/productedit.dart';

void main() {
  runApp(const MyApp());
}

class Design {
  static const Color lightBlue = Color.fromARGB(255, 70, 162, 238);
  static const Color darkBlue = Color.fromARGB(255, 21, 17, 247);
  static const textDesign = TextStyle(color: Colors.white);
  static const textDesignBig = TextStyle(color: Colors.white, fontSize: 18);

  static var roundedInputBox = InputDecoration(
      fillColor: Design.lightBlue,
      focusedBorder: OutlineInputBorder(
          borderSide: BorderSide.none, borderRadius: BorderRadius.circular(50)),
      enabledBorder: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.circular(50)));

  static var roundedTextBox = const BoxDecoration(
      color: Design.darkBlue,
      border: Border.fromBorderSide(BorderSide.none),
      borderRadius: BorderRadius.all(Radius.elliptical(50, 100)));
  static var roundedETextBox = const BoxDecoration(
      color: Design.lightBlue,
      border: Border.fromBorderSide(BorderSide.none),
      borderRadius: BorderRadius.all(Radius.elliptical(50, 100)));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Мой недохолодильник',
      theme: ThemeData(
          primarySwatch: Colors.blue,
          inputDecorationTheme: //раскраска и оформление всех текстбоксов
              InputDecorationTheme(
                  filled: true,
                  fillColor: Design.darkBlue,
                  focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(width: 1.5),
                      borderRadius: BorderRadius.circular(50)),
                  enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(width: 1.5),
                      borderRadius: BorderRadius.circular(50))),
          textTheme: const TextTheme(
              subtitle1: Design.textDesign)), //раскраска и оформление текста
      home: const MyHomePage(title: 'Главная страница'),
      initialRoute: '/',
      routes: {
        // '/': (context) => const MyHomePage(title: 'главная страница'),
        '/fridge': (context) =>
            FridgePage(ModalRoute.of(context)!.settings.arguments as Map),
        '/fridge/productedit': (context) =>
            ProductEditPage(ModalRoute.of(context)!.settings.arguments as int)
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Map<int, bool> _selected = {}; //коды выбранных элементов в списке

  bool _showCheckBoxes = false; //показывать ли галочки
  void _onSelect(bool value, int i) {
    //обработка нажатий по строкам списка

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
        int fridgeId = i;

        String fridgeName =
            fridges.firstWhere((element) => element.id == i).fridgeName;
        var fridgeInfo = {"id": fridgeId, "name": fridgeName};
        Navigator.pushNamed(context, '/fridge', arguments: fridgeInfo)
            .then((_) => refreshHomePage());
      }
    }
  }

  List<DataRow> fillForTable(List<Fridge> raw) {
    //заполнение списка продуктов
    late List<DataRow> fFridges = [];
    for (int i = 0; i < raw.length; i++) {
      var elem = raw[i];
      fFridges.add(DataRow(
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
              Center(
                child: Text(
                  "${elem.fridgeName}",
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ]));
    }
    return fFridges;
  } //создание списка для подстановки в таблицу

  bool isLoading = false;

  late List<Fridge> fridges = [];

  @override
  void initState() {
    super.initState();
    refreshHomePage();
  }

  Future refreshHomePage() async {
    setState(() => isLoading = true);
    fridges = await Mydb.instance.readAllFridges();
    _selected = {for (var item in fridges) item.id!: false};
    setState(() {
      isLoading = false;
    });
  }

  Future addNewFridge() async {
    Map<String, dynamic> temp = {FridgesFields.fridgeName: "Тестовая строка"};
    await Mydb.instance.addFridges(temp);

    refreshHomePage();
  }

  Future deleteFridge(int id) async {
    await Mydb.instance.deleteFridges(id);

    refreshHomePage();
    // setState() {}
  }

  void _showWIP() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Предупреждение"),
          content: const Text("Это ещё не сделано"),
          actions: <Widget>[
            OutlinedButton(
              child: const Text("Понял, принял"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
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

  void deleteSelected() {
    //удаление выбранных элементов
    _showCheckBoxes = false;
    for (var element in _selected.entries) {
      if (element.value == true) {
        deleteFridge(element.key);
      }
    }
  }

  Future newFridgeCreation() async {
    //процесс создания продукта и перехода на страницу его редактирования
    await addNewFridge();
    late int temp1;
    int fridgeId = await Mydb.instance.lastFridge();
    //late int fridgeId = fridges.last.id!;

    String fridgeName =
        fridges.firstWhere((element) => element.id == fridgeId).fridgeName;
    var fridgeInfo = {"id": fridgeId, "name": fridgeName};
    Navigator.pushNamed(context, '/fridge', arguments: fridgeInfo)
        .then((_) => refreshHomePage());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        shadowColor: Colors.white,
        elevation: 0,
        // title: Text(widget.title),
      ),

      body: Column(
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 30),
            decoration: Design.roundedTextBox,
            child: const SizedBox(
              child: Center(
                child: Text(
                  "ХОЛОДИЛЬНИКИ ",
                  style: Design.textDesignBig,
                  textAlign: TextAlign.center,
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
                onPressed: newFridgeCreation,
                icon: const Icon(Icons.add_circle_rounded),
                // child: const Text("Добавить новый"),
              ),
            ],
          ),
          Expanded(
              child: fridges.isEmpty
                  ? const Text("Отсутствует холодильник, добавьте новый")
                  : DataTable(
                      headingRowHeight: 25,
                      columnSpacing: 30,
                      checkboxHorizontalMargin: 5,
                      showCheckboxColumn: _showCheckBoxes,
                      columns: const [
                        DataColumn(
                          label: Text(""),
                          //  label: Text("Название холодильника",)
                        ),
                      ],
                      rows: fillForTable(fridges),
                    ))
          // Expanded(
          //   child: fridges.isEmpty
          //       ? const Text("Список пуст")
          //       :
          //  ListView.builder(
          //     itemCount: fridges.length,
          //     itemBuilder: (BuildContext context, int index) {
          //       int nidex = index + 1;
          //       return TextField(
          //         decoration: InputDecoration(
          //             labelText:
          //                 ("${fridges[index].id},${fridges[index].fridgeName}")),

          //         readOnly: true,
          //         // onTap: () async {
          //         //   await deleteFridge(fridges[index].id ?? 1);
          //         // },
          //         onTap: () {
          //           int fridgeid = fridges[index].id ?? 1;
          //           String fridgeName = fridges[index].fridgeName;
          //           var fridgeInfo = {"id": fridgeid, "name": fridgeName};
          //           Navigator.pushNamed(context, '/fridge',
          //                   arguments: fridgeInfo)
          //               .then(
          //             (value) => refreshHomePage(),
          //           );
          //         },
          //       );
          //     },
          //   ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: _showWIP,
        tooltip: 'Increment',
        child: const Icon(Icons.photo_camera),
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
