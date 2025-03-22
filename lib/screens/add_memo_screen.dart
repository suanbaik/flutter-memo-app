import 'package:flutter/material.dart';
import '../db/db_helper.dart';
import '../models/memo.dart';

class AddMemoScreen extends StatelessWidget {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("새 메모 추가")),
      body: Column(
        children: [
          TextField(controller: titleController, decoration: InputDecoration(labelText: "제목")),
          TextField(controller: contentController, decoration: InputDecoration(labelText: "내용")),
          ElevatedButton(
            onPressed: () async {
              final memo = Memo(title: titleController.text, content: contentController.text, createdAt: DateTime.now());
              await DatabaseHelper.instance.insertMemo(memo);
              Navigator.pop(context);
            },
            child: Text("저장"),
          ),
        ],
      ),
    );
  }
}
