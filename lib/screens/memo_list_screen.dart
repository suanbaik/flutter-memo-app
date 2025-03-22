import 'package:flutter/material.dart';
import '../db/db_helper.dart';
import '../models/memo.dart';
import '../models/comment.dart';

class MemoListScreen extends StatefulWidget {
  const MemoListScreen({super.key});

  @override
  _MemoListScreenState createState() => _MemoListScreenState();
}

class _MemoListScreenState extends State<MemoListScreen> {
  late Future<List<Memo>> memos;

  @override
  void initState() {
    super.initState();
    memos = DatabaseHelper.instance.fetchMemos();
  }

  String timeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);
    String formattedDate = "${dateTime.year}.${dateTime.month.toString().padLeft(2, '0')}.${dateTime.day.toString().padLeft(2, '0')}";

    if (diff.inMinutes < 1) return "방금 전 · $formattedDate";
    if (diff.inMinutes < 60) return "${diff.inMinutes}분 전 · $formattedDate";
    if (diff.inHours < 24) return "${diff.inHours}시간 전 · $formattedDate";
    if (diff.inDays < 7) return "${diff.inDays}일 전 · $formattedDate";
    return formattedDate;
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("단아치과의원", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text("서울 구로구 구로 1동", style: TextStyle(fontSize: 14, color: Colors.grey)),
            ],
          ),
          bottom: const TabBar(
            tabs: [
              Tab(text: "메모"),
              Tab(text: "일정"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildMemoTab(),
            const Center(child: Text("일정 내용 없음")),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            _showAddMemoDialog(context);
          },
          label: Text("메모 작성하기"),
          icon: Icon(Icons.edit),
          backgroundColor: Colors.blue,
        ),
      ),
    );
  }

  Widget _buildMemoTab() {
    return FutureBuilder<List<Memo>>(
      future: memos,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
        final memoList = snapshot.data!;
        return Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                "거래처 관련자에 대한 내밀 또는 개인 정보 등 명예훼손 문제가 발생될 수 있으니 꼭! 유의하여 작성해 주세요!",
                style: TextStyle(color: Colors.red, fontSize: 14),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text("총 ${memoList.length}개", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: memoList.length,
                itemBuilder: (context, index) {
                  final memo = memoList[index];
                  return Card(
                    margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListTile(
                            leading: CircleAvatar(child: Icon(Icons.person)),
                            title: Text("CE | 강서지점", style: TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // 👉 우측 상단 수정/삭제 버튼
                                Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      TextButton(
                                        onPressed: () {
                                          _showEditMemoDialog(context, memo);
                                        },
                                        child: Text(
                                          "수정",
                                          style: TextStyle(fontSize: 12, color: Colors.grey),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () async {
                                          await DatabaseHelper.instance.deleteMemo(memo.id!);
                                          setState(() {
                                            memos = DatabaseHelper.instance.fetchMemos();
                                          });
                                        },
                                        child: Text(
                                          "삭제",
                                          style: TextStyle(fontSize: 12, color: Colors.grey),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(timeAgo(memo.createdAt), style: TextStyle(fontSize: 12, color: Colors.grey)),
                                SizedBox(height: 4),
                                Text(memo.content),
                                SizedBox(height: 4),
                                GestureDetector(
                                  onTap: () {
                                    _showReplyDialog(context, memo);
                                  },
                                  child: Text(
                                    "답글 쓰기",
                                    style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 56.0, right: 16),
                            child: FutureBuilder<List<Comment>>(
                              future: DatabaseHelper.instance.fetchComments(memo.id!),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData || snapshot.data!.isEmpty) return SizedBox();
                                return Column(
                                  children: snapshot.data!.map((comment) {
                                    return ListTile(
                                      dense: true,
                                      contentPadding: EdgeInsets.zero,
                                      leading: CircleAvatar(
                                        radius: 12,
                                        child: Icon(Icons.person, size: 14),
                                      ),
                                      title: Text("CE | 강서지점", style: TextStyle(fontSize: 13)),
                                      subtitle: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(timeAgo(comment.createdAt), style: TextStyle(fontSize: 11)),
                                          Text(comment.content, style: TextStyle(fontSize: 13)),
                                        ],
                                      ),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          TextButton(
                                            onPressed: () {
                                              _showEditCommentDialog(context, comment);
                                            },
                                            child: Text("수정", style: TextStyle(fontSize: 12)),
                                          ),
                                          TextButton(
                                            onPressed: () async {
                                              await DatabaseHelper.instance.deleteComment(comment.id!);
                                              setState(() {});
                                            },
                                            child: Text("삭제", style: TextStyle(fontSize: 12, color: Colors.red)),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
  void _showAddMemoDialog(BuildContext context) {
    final titleController = TextEditingController(text: "단아치과의원단아치과의원아이이이");
    final contentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("메모 작성하기"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  readOnly: true,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.place, color: Colors.blue),
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 12),
                TextField(
                  controller: contentController,
                  decoration: InputDecoration(
                    hintText: "기록하고 싶은 영업 내용을 글로 남겨보세요.",
                    helperText: "거래처 관련자에 대한 내밀 또는 개인 정보 등 입력 시 유의하세요!",
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 4,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("취소"),
            ),
            ElevatedButton(
              onPressed: () async {
                if (titleController.text.isNotEmpty && contentController.text.isNotEmpty) {
                  await DatabaseHelper.instance.insertMemo(Memo(
                    title: titleController.text,
                    content: contentController.text,
                    createdAt: DateTime.now(),
                  ));
                  Navigator.pop(context);
                  setState(() {
                    memos = DatabaseHelper.instance.fetchMemos();
                  });
                }
              },
              child: Text("완료"),
            ),
          ],
        );
      },
    );
  }

  void _showEditMemoDialog(BuildContext context, Memo memo) {
    final contentController = TextEditingController(text: memo.content);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("메모 수정하기"),
          content: SingleChildScrollView(
            child: TextField(
              controller: contentController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("취소"),
            ),
            ElevatedButton(
              onPressed: () async {
                if (contentController.text.isNotEmpty) {
                  await DatabaseHelper.instance.updateMemo(Memo(
                    id: memo.id,
                    title: memo.title,
                    content: contentController.text,
                    createdAt: memo.createdAt,
                  ));
                  Navigator.pop(context);
                  setState(() {
                    memos = DatabaseHelper.instance.fetchMemos();
                  });
                }
              },
              child: Text("수정"),
            ),
          ],
        );
      },
    );
  }

  void _showReplyDialog(BuildContext context, Memo memo) {
    final contentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("답글 작성하기"),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("▶ ${memo.content}", style: TextStyle(fontSize: 13, fontStyle: FontStyle.italic)),
                SizedBox(height: 8),
                TextField(
                  controller: contentController,
                  decoration: InputDecoration(
                    hintText: "답글 내용을 입력하세요.",
                    helperText: "개인정보 입력 시 유의하세요!",
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 4,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("취소"),
            ),
            ElevatedButton(
              onPressed: () async {
                if (contentController.text.isNotEmpty) {
                  await DatabaseHelper.instance.insertComment(Comment(
                    memoId: memo.id!,
                    content: contentController.text,
                    createdAt: DateTime.now(),
                  ));
                  Navigator.pop(context);
                  setState(() {});
                }
              },
              child: Text("완료"),
            ),
          ],
        );
      },
    );
  }

  void _showEditCommentDialog(BuildContext context, Comment comment) {
    final contentController = TextEditingController(text: comment.content);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("댓글 수정하기"),
          content: SingleChildScrollView(
            child: TextField(
              controller: contentController,
              decoration: InputDecoration(
                hintText: "수정할 댓글 내용을 입력하세요.",
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("취소"),
            ),
            ElevatedButton(
              onPressed: () async {
                if (contentController.text.isNotEmpty) {
                  await DatabaseHelper.instance.updateComment(Comment(
                    id: comment.id,
                    memoId: comment.memoId,
                    content: contentController.text,
                    createdAt: comment.createdAt,
                  ));
                  Navigator.pop(context);
                  setState(() {});
                }
              },
              child: Text("수정"),
            ),
          ],
        );
      },
    );
  }
}
