class Memo {
  int? id;
  String title;
  String content;
  DateTime createdAt;

  Memo({this.id, required this.title, required this.content, required this.createdAt});

  Map<String, dynamic> toMap() {
    return {'id': id, 'title': title, 'content': content, 'createdAt': createdAt.toIso8601String()};
  }

  factory Memo.fromMap(Map<String, dynamic> map) {
    return Memo(
      id: map['id'],
      title: map['title'],
      content: map['content'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}
