// ignore_for_file: avoid_unnecessary_containers, avoid_print
import 'package:flutter/material.dart';
import 'package:todo/database_helper.dart';
import 'package:todo/models/task.dart';
import 'package:todo/models/todo.dart';
import 'package:todo/widget.dart';

class TaskPage extends StatefulWidget {
  final Task? task;
  const TaskPage({Key? key, this.task}) : super(key: key);

  @override
  State<TaskPage> createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  late int _taskId = 0;
  late String _taskTitle = "";
  late String _taskDescription = "";
  //late String todoText = "";

  late FocusNode _titleFocus;
  late FocusNode _descriptionFocus;
  late FocusNode _todoFocus;

  late bool _contentVisible = false;

  @override
  void initState() {
    if (widget.task != null) {
      _contentVisible = true;
      _taskTitle = widget.task!.title.toString();
      _taskId = widget.task!.id!.toInt();
      _taskDescription = widget.task!.description.toString();
    }

    _titleFocus = FocusNode();
    _descriptionFocus = FocusNode();
    _todoFocus = FocusNode();

    super.initState();
  }

  @override
  void dispose() {
    _descriptionFocus.dispose();
    _titleFocus.dispose();
    _todoFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          child: SafeArea(
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    bottom: 6.0,
                    top: 24.0,
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.arrow_back),
                        padding: const EdgeInsets.all(24.0),
                        iconSize: 30.0,
                      ),
                      Expanded(
                        child: TextField(
                          focusNode: _titleFocus,
                          onSubmitted: (value) async {
                            if (value != '') {
                              if (widget.task == null) {
                                Task _newTask = Task(title: value);
                                _taskId = await _dbHelper.insertTask(_newTask);
                                setState(() {
                                  _taskTitle = value;
                                  _contentVisible = true;
                                });
                              } else {
                                await _dbHelper.updateTaskTitle(_taskId, value);
                                print('Task Updated');
                              }
                              _descriptionFocus.requestFocus();
                            }
                          },
                          controller: TextEditingController()
                            ..text = _taskTitle,
                          decoration: const InputDecoration(
                            hintText: 'Enter Task Title',
                            border: InputBorder.none,
                          ),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 26.0,
                            color: Color(0xFF211551),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Visibility(
                  visible: _contentVisible,
                  child: Padding(
                    padding: const EdgeInsets.only(
                      bottom: 12.0,
                    ),
                    child: TextField(
                      focusNode: _descriptionFocus,
                      onSubmitted: (value) async {
                        if (value != '') {
                          if (_taskId != 0) {
                            await _dbHelper.updateTaskDescription(
                                _taskId, value);
                            _taskDescription = value;
                          }
                        }
                        _todoFocus.requestFocus();
                      },
                      controller: TextEditingController()
                        ..text = _taskDescription,
                      decoration: const InputDecoration(
                        hintText: 'Enter Description for the task',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 24.0,
                        ),
                      ),
                    ),
                  ),
                ),
                Visibility(
                  visible: _contentVisible,
                  child: FutureBuilder<List<Todo>>(
                    initialData: const [],
                    future: _dbHelper.getTodos(_taskId),
                    builder: (context, snapshot) {
                      return Container(
                        height: 275,
                        child: ListView.builder(
                          itemCount: snapshot.data!.length,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () async {
                                if (snapshot.data![index].isDone == 0) {
                                  await _dbHelper.updateTodoisDone(
                                      snapshot.data![index].id!, 1);
                                } else {
                                  await _dbHelper.updateTodoisDone(
                                      snapshot.data![index].id!, 0);
                                }
                                setState(() {});
                              },
                              child: TodoWidget(
                                text: snapshot.data![index].title,
                                isDone: snapshot.data![index].isDone == 0
                                    ? false
                                    : true,
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
                Visibility(
                  visible: _contentVisible,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24.0,
                    ),
                    child: Row(
                      children: [
                        Container(
                          margin: const EdgeInsets.only(
                            right: 12.0,
                          ),
                          width: 20.0,
                          height: 20.0,
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(6.0),
                            border: Border.all(
                              color: const Color(0xFF86829D),
                              width: 1.5,
                            ),
                          ),
                          child: const Image(
                            image: AssetImage('assets/check_icon.png'),
                          ),
                        ),
                        Expanded(
                          child: TextField(
                            controller: TextEditingController()..text = "",
                            focusNode: _todoFocus,
                            onSubmitted: (value) async {
                              if (value != '') {
                                if (_taskId != 0) {
                                  DatabaseHelper _dbHelper = DatabaseHelper();
                                  Todo _newTodo = Todo(
                                    title: value,
                                    taskId: _taskId,
                                    isDone: 0,
                                  );
                                  await _dbHelper.insertTodo(_newTodo);
                                  setState(() {});
                                  _todoFocus.requestFocus();
                                  print('creating new todo');
                                } else {
                                  print('update the todo');
                                }
                              }
                            },
                            decoration: const InputDecoration(
                              hintText: 'Enter ToDo title',
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Visibility(
              visible: _contentVisible,
              child: Positioned(
                bottom: 24.0,
                right: 24.0,
                child: Container(
                  width: 60.0,
                  height: 60.0,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFE3577),
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: IconButton(
                    onPressed: () async {
                      if (_taskId != 0) {
                        await _dbHelper.deleteTask(_taskId);
                        Navigator.pop(context);
                      }
                    },
                    icon: const Icon(Icons.delete),
                  ),
                ),
              ),
            ),
          ],
        ),
      )),
    );
  }
}
