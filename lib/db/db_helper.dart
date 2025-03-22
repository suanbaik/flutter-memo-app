import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/memo.dart';
import '../models/comment.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('memo_app.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE memos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        createdAt TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE comments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        memoId INTEGER NOT NULL,
        content TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        FOREIGN KEY (memoId) REFERENCES memos (id) ON DELETE CASCADE
      )
    ''');
  }

  Future<void> insertMemo(Memo memo) async {
    final db = await database;
    await db.insert('memos', memo.toMap());
  }

  Future<List<Memo>> fetchMemos() async {
    final db = await database;
    final result = await db.query('memos', orderBy: 'createdAt DESC');
    return result.map((e) => Memo.fromMap(e)).toList();
  }

  Future<void> deleteMemo(int id) async {
    final db = await database;
    await db.delete('memos', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteComment(int id) async {
    final db = await database;
    await db.delete(
      'comments',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> insertComment(Comment comment) async {
    final db = await database;
    await db.insert(
      'comments',
      comment.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateMemo(Memo memo) async {
    final db = await database;
    await db.update(
      'memos',
      memo.toMap(),
      where: 'id = ?',
      whereArgs: [memo.id],
    );
  }

  Future<void> updateComment(Comment comment) async {
    final db = await database;
    await db.update(
      'comments',
      comment.toMap(),
      where: 'id = ?',
      whereArgs: [comment.id],
    );
  }

  Future<List<Comment>> fetchComments(int memoId) async {
    final db = await database;
    final result = await db.query('comments', where: 'memoId = ?', whereArgs: [memoId], orderBy: 'createdAt DESC');
    return result.map((e) => Comment.fromMap(e)).toList();
  }

  Future<void> insertDummyData() async {
    final db = await database;

    final memos = await db.query('memos');
    if (memos.isEmpty) {
      int memoId1 = await db.insert('memos', {
        'title': '단아치과의원',
        'content': '원장님 미팅, 다음번에 브로셔 가지고 다시 한 번 미팅',
        'createdAt': DateTime.now().toIso8601String(),
      });

      int memoId2 = await db.insert('memos', {
        'title': '단아치과의원',
        'content': '원장님 미팅, 다음번에 브로셔 가지고 다시 한 번 미팅',
        'createdAt': DateTime.now().toIso8601String(),
      });

      await db.insert('comments', {
        'title': '단아치과의원',
        'memoId': memoId1,
        'content': '원장님 미팅, 다음번에 브로셔 가지고 다시 한 번 미팅',
        'createdAt': DateTime.now().toIso8601String(),
      });

      await db.insert('comments', {
        'title': '단아치과의원',
        'memoId': memoId1,
        'content': '원장님 미팅, 다음번에 브로셔 가지고 다시 한 번 미팅',
        'createdAt': DateTime.now().toIso8601String(),
      });

      await db.insert('comments', {
        'title': '단아치과의원',
        'memoId': memoId2,
        'content': '원장님 미팅, 다음번에 브로셔 가지고 다시 한 번 미팅',
        'createdAt': DateTime.now().toIso8601String(),
      });
    }
  }

}
