import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  AppDatabase._(this.db);

  final Database db;

  static Future<AppDatabase> open() async {
    final path = p.join(await getDatabasesPath(), 'quiet_vault_browser.db');
    final db = await openDatabase(
      path,
      version: 2,
      onCreate: (database, version) async {
        await database.execute('''
          CREATE TABLE collections(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            color_hex TEXT NOT NULL,
            created_at TEXT NOT NULL
          )
        ''');

        await database.execute('''
          CREATE TABLE saved_links(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            url TEXT NOT NULL,
            icon_path TEXT NOT NULL DEFAULT '',
            collection_id INTEGER NOT NULL,
            note TEXT NOT NULL DEFAULT '',
            tags_csv TEXT NOT NULL DEFAULT '',
            is_favorite INTEGER NOT NULL DEFAULT 0,
            created_at TEXT NOT NULL,
            updated_at TEXT NOT NULL,
            last_opened_at TEXT,
            FOREIGN KEY(collection_id) REFERENCES collections(id)
          )
        ''');

        await database.execute('''
          CREATE TABLE quick_links(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            label TEXT NOT NULL,
            url TEXT NOT NULL,
            sort_order INTEGER NOT NULL DEFAULT 0
          )
        ''');

        await database.execute('''
          CREATE TABLE recent_sessions(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            url TEXT NOT NULL,
            title TEXT NOT NULL DEFAULT '',
            visited_at TEXT NOT NULL
          )
        ''');

        await database.insert('collections', {
          'name': 'Inbox',
          'color_hex': '#FF6B6B',
          'created_at': DateTime.now().toIso8601String(),
        });
      },
      onUpgrade: (database, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await database.execute(
            "ALTER TABLE saved_links ADD COLUMN icon_path TEXT NOT NULL DEFAULT ''",
          );
        }
      },
    );

    return AppDatabase._(db);
  }
}
