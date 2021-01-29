import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
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
  Widget buildItem(BuildContext context, int index) {
    return Dismissible(
        key: Key(DateTime
            .now()
            .microsecondsSinceEpoch
            .toString()),
        background: Container(
          color: Colors.pink[600],
          child: Align(
            alignment: Alignment(-0.9, 0.0),
            child: Icon(Icons.delete, color: Colors.white),
          ),
        ),
        direction: DismissDirection.startToEnd,
        child: CheckboxListTile(
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
              _saveData();
            });
          },
        ),
        onDismissed: (direction) {
          setState(() {
            _lastRemoved = Map.from(_Todolist[index]);
            _lastRemovedPos = index;
            _Todolist.removeAt(index);
            _saveData();

            final snack = SnackBar(
                content: Text('Tarefa ${_lastRemoved['title']} removida!'),
                backgroundColor: Colors.grey,
                action: SnackBarAction(label: ' Desfazer',
                    onPressed: () {
                      setState(() {
                        _Todolist.insert(_lastRemovedPos, _lastRemoved);
                        _saveData();
                      });

                    }),
                duration: Duration(seconds: 2),
            );
            Scaffold.of(context).showSnackBar(snack);
          }
          );
        });
}

@override
void initState() {
  super.initState();
  _readData().then((data) {
    setState(() {
      _Todolist = json.decode(data);

      _saveData();
    });
  });
}

void _addToDo() {
  setState(() {
    Map<String, dynamic> newTodo = Map();
    newTodo['title'] = _ToDocontroller.text;
    _ToDocontroller.text = '';
    newTodo['ok'] = false;
    _Todolist.add(newTodo);
    _saveData();
  });
}

Future<Null> _refresh() async{
    await Future.delayed(Duration(seconds: 1 ));
  setState(() {
    _Todolist.sort((a, b){
      if(a['ok'] && !b['ok']) return 1;
      else if(!a['ok'] && b['ok']) return -1;
      else return 0;
    });
    _saveData();
  });
  return null;
}

final _ToDocontroller = TextEditingController();

List _Todolist = [];
Map<String, dynamic> _lastRemoved;
int _lastRemovedPos;

Future<File> _getFile() async {
  final directory = await getApplicationDocumentsDirectory();
  return File("${directory.path}data.json");
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
          Expanded( child:
          RefreshIndicator(
            onRefresh: _refresh  ,
          child: ListView.builder(
                  padding: EdgeInsets.only(top: 7),
                  itemCount: _Todolist.length,
                  itemBuilder: buildItem),
          )
          ),
        ],
      ));
}}
