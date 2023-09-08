import 'dart:async';
import 'dart:developer' as logger show log;
import 'dart:io' as io;

import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:synchronized/synchronized.dart';

class DBHelper {
  static DBHelper? _dbHelper;
  static Database? _database;

  final _lock = Lock();

  final String _tLogActivity = 'tlogactivity';
  final String tImeiTemp = 'timei';
  final String _tAppSettings = 'tappsettings';

  final String _colLastUpdate = 'lastupdate';
  final String _colJenis = 'jenis';
  final String _colUserId = 'nis';
  final String _colMenu = 'menu';
  final String _colKeterangan = 'keterangan';
  final String _colAkses = 'akses';

  DBHelper._createInstance();

  factory DBHelper() {
    _dbHelper ??= DBHelper._createInstance();
    return _dbHelper!;
  }

  Future<Database> get database async {
    if (_database == null) {
      await _lock.synchronized(() async {
        _database ??= await initializeDatabase();
      });
    }

    return _database!;
  }

  Future<Database> initializeDatabase() async {
    io.Directory directory = await getApplicationDocumentsDirectory();
    String path = join(directory.path, 'GokreasiDB');

    var kreasiDatabase = await openDatabase(
      path,
      version: 8,
      onConfigure: _onConfigure,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onDowngrade: onDatabaseDowngradeDelete,
    );

    return kreasiDatabase;
  }

  Future _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  void _onCreate(Database db, int version) async {
    var batch = db.batch();
    _prepareTable(batch);
    await batch.commit();
  }

  void _onUpgrade(Database db, int oldVersion, int newVersion) async {
    var batch = db.batch();
    _prepareTable(batch);
    await batch.commit();
  }

  void _prepareTable(Batch batch) {
    _dropTableIfExist(batch);
    _createTable(batch);
  }

  void _dropTableIfExist(Batch batch) {
    batch.execute('DROP TABLE IF EXISTS $_tLogActivity');
    batch.execute('DROP TABLE IF EXISTS $_tAppSettings');
  }

  void _createTable(Batch batch) {
    batch.execute('''
      CREATE TABLE IF NOT EXISTS $_tLogActivity(
        $_colUserId TEXT,
        $_colJenis TEXT,
        $_colMenu TEXT,
        $_colKeterangan TEXT,
        $_colAkses TEXT,
        $_colLastUpdate TEXT
      )
    ''');

    batch.execute('''
      CREATE TABLE IF NOT EXISTS $tImeiTemp(
        noimei INTEGER,
        imeitemp TEXT,
        PRIMARY KEY (noimei)
      )
    ''');

    batch.execute('''
      CREATE TABLE IF NOT EXISTS $_tAppSettings(
        id INTEGER,
        name TEXT,
        value TEXT,
        PRIMARY KEY (id)
      )
    ''');
  }

  Future<List<Map<String, dynamic>>> rawQueryFetch(String sql) async {
    Database db = await database;
    var list = await db.rawQuery(sql);
    return list;
  }

  Future<int> rawQueryInsert(String sql) async {
    Database db = await database;
    var result = await db.rawInsert(sql);
    return result;
  }

  Future<int> rawQueryUpdate(String sql) async {
    Database db = await database;
    var result = await db.rawUpdate(sql);
    return result;
  }

  Future<int> rawQueryDelete(String sql) async {
    Database db = await database;
    var result = await db.rawDelete(sql);
    return result;
  }

  Future<int> insertLogActivity(Map<String, dynamic> values) async {
    Database db = await database;
    var result = await db.insert(_tLogActivity, values);
    if (kDebugMode) {
      logger.log("result $result");
      logger.log("values $values");
    }
    return result;
  }

  Future<List<Map<String, dynamic>>> fetchLogActivity() async {
    Database db = await database;

    return await db.query(_tLogActivity);
  }

  Future<String?> fetchImei() async {
    Database db = await database;

    List<Map<String, dynamic>> data = await db.query(
      tImeiTemp,
      columns: ['imeitemp'],
      where: 'noimei = ?',
      whereArgs: [1],
    );

    if (data.isNotEmpty) return data[0]['imeitemp'];

    return null;
  }

  Future<int> insertImei(String imei) async {
    Database db = await database;
    final result = await db.insert(tImeiTemp, {'imeitemp': imei});
    return result;
  }

  Future<int> updateImei(String imei) async {
    Database db = await database;
    final result = await db.update(tImeiTemp, {'imeitemp': imei},
        where: 'noimei = ?', whereArgs: [1]);
    return result;
  }
}
