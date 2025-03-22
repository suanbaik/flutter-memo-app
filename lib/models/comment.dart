class Comment {
  int? id;
  int memoId;
  String content;
  DateTime createdAt;

  Comment({this.id, required this.memoId, required this.content, required this.createdAt});

  Map<String, dynamic> toMap() {
    return {'id': id, 'memoId': memoId, 'content': content, 'createdAt': createdAt.toIso8601String()};
  }

  factory Comment.fromMap(Map<String, dynamic> map) {
    return Comment(
      id: map['id'],
      memoId: map['memoId'],
      content: map['content'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}
