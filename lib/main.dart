//import 'dart:html';

// ignore_for_file: unused_element, unused_field, unused_local_variable

import 'package:flutter/material.dart';
import 'package:refrigerator/db/database.dart';
import 'package:refrigerator/model/fridgemodel.dart';
import 'package:refrigerator/pages/fridge.dart';

void main() {
  runApp(const MyApp());
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
      ),
      home: const MyHomePage(title: 'Главная страница'),
      initialRoute: '/',
      routes: {
        // '/': (context) => const MyHomePage(title: 'главная страница'),
        '/fridge': (context) =>
            FridgePage(ModalRoute.of(context)!.settings.arguments as int)
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
  int _counter = 0;

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

    setState(() {
      isLoading = false;
    });
  }

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  void _decrementCounter() {
    setState(() {
      _counter--;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),

      body: Column(
        children: [
          Row(
            children: [
              TextButton(
                onPressed: () async {
                  fridges.isNotEmpty
                      ? await deleteFridge(fridges[fridges.length - 1].id ?? 1)
                      : throw Exception("Not enough rows in table fridges");
                },
                child: const Text("Убрать последний элемент"),
              ),
              Expanded(
                child: TextButton(
                  onPressed: addNewFridge,
                  child: const Text("Добавить новый"),
                ),
              ),
            ],
          ),
          Expanded(
            child: fridges.isEmpty
                ? const Text("Список пуст")
                : ListView.builder(
                    itemCount: fridges.length,
                    itemBuilder: (BuildContext context, int index) {
                      int nidex = index + 1;
                      return TextField(
                        decoration: InputDecoration(
                            labelText:
                                ("${fridges[index].id},${fridges[index].fridgeName}")),

                        readOnly: true,
                        // onTap: () async {
                        //   await deleteFridge(fridges[index].id ?? 1);
                        // },
                        onTap: () {
                          int fridgeid = fridges[index].id ?? 1;
                          Navigator.pushNamed(context, '/fridge',
                              arguments: fridgeid);
                        },
                      );
                    },
                  ),
          )
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
