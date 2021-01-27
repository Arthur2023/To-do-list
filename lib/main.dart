import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

void main() {
  runApp(MaterialApp(
      title: 'Lista de tarefas',
      home: Home(),
      theme: ThemeData(
          hintColor: Colors.grey,
          primaryColor: Colors.grey,
          inputDecorationTheme: InputDecorationTheme(
            enabledBorder:
                OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
            focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.pink[700])),
            hintStyle: TextStyle(color: Colors.pink[700]),
          ))));
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  void _addToDo() {
    setState(() {
      Map<String, dynamic> newTodo = Map();
      newTodo['title'] = _ToDocontroller.text;
      _ToDocontroller.text = '';
      newTodo['ok'] = false;
      _Todolist.add(newTodo);
    });
  }

  final _ToDocontroller = TextEditingController();

  List _Todolist = [];

  Future<File> _getFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File("${directory.path}tare.json");
  }

  Future<File> _saveData() async {
    String data = json.encode(_Todolist);
    final file = await _getFile();
    return file.writeAsString(data);
  }

  Future<String> _readData() async {
    try {
      final file = await _getFile();
      return file.readAsString();
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text(
              'Lista de Tarefas',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.pink[700],
            centerTitle: true),
        body: Column(
          children: <Widget>[
            Container(
              padding: EdgeInsets.fromLTRB(2, 10, 2, 4),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: _ToDocontroller,
                      decoration: InputDecoration(labelText: 'Nova tarefa'),
                    ),
                  ),
                  SizedBox(width: 2),
                  RaisedButton(
                      color: Colors.pink[700],
                      child: Text('Adicionar',
                          style: TextStyle(color: Colors.white)),
                      onPressed: () {
                        _addToDo();
                      }),
                ],
              ),
            ),
            Expanded(
                child: ListView.builder(
                    padding: EdgeInsets.only(top: 7),
                    itemCount: _Todolist.length,
                    itemBuilder: (context, index) {
                      return CheckboxListTile(
                        title: Text(_Todolist[index]['title']),
                        value: _Todolist[index]['ok'],
                        secondary: CircleAvatar(
                            child: Icon(
                          _Todolist[index]['ok'] ? Icons.check : Icons.error,
                          color: Colors.pink[700],
                        )),
                        onChanged: (c) {
                          setState(() {
                            _Todolist[index]['ok'] = c;
                          });
                        },
                      );
                    }))
          ],
        ));
  }
}
