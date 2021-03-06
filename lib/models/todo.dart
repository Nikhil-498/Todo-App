class Todo {
  final int? id;
  final String? title;
  final int? isDone;
  final int? taskId;

  Todo({this.id, this.isDone, this.title, this.taskId});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'taskId': taskId,
      'title': title,
      'isDone': isDone,
    };
  }
}
