import 'dart:io';

import 'package:mobidata_dtc/classes/status.class.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelperStatus {
  static DatabaseHelperStatus _databaseHelperStatus;
  static Database _databaseStatus;
  DatabaseHelperStatus._createInstance();

  String idCol = 'id';
  String statusTable = 'status';
  String nomeCol = 'nome';
  String tirafotoCol = 'tira_foto';

  factory DatabaseHelperStatus() {
    if (_databaseHelperStatus == null) {
      _databaseHelperStatus = DatabaseHelperStatus._createInstance();
    }
    return _databaseHelperStatus;
  }

  Future<Database> get database async {
    if (_databaseStatus == null) {
      _databaseStatus = await initializeDatabase();
    }

    return _databaseStatus;
  }

  Future<Database> initializeDatabase() async {
    Directory directory = await getApplicationDocumentsDirectory();
    String path = directory.path + 'status.db';

    var statusDatabase =
        await openDatabase(path, version: 1, onCreate: _createDb);
    return statusDatabase;
  }

  void _createDb(Database db, int newVersion) async {
    await db.execute(
        'CREATE TABLE $statusTable($idCol INTEGER,$nomeCol VARCHAR(255), $tirafotoCol VARCHAR(255))');
  }

  Future<int> insertStatus(Status status) async {
    Database db = await this.database;

    var resultado = await db.insert(statusTable, status.toMap());

    return resultado;
  }

  Future<Status> getStatus(int id) async {
    Database db = await this.database;

    List<Map> maps = await db.query(statusTable,
        columns: [
          idCol,
          nomeCol,
          tirafotoCol,
        ],
        where: "$idCol = ?",
        whereArgs: [id]);

    if (maps.length > 0) {
      return Status.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<List<Status>> getStatusLista() async {
    Database db = await this.database;

    var resultado = await db.query(statusTable);

    List<Status> lista = resultado.isNotEmpty
        ? resultado.map((c) => Status.fromMap(c)).toList()
        : [];

    return lista;
  }

  Future<int> updateStatus(Status status) async {
    var db = await this.database;

    var resultado = await db.update(
      statusTable,
      status.toMap(),
    );

    return resultado;
  }

  Future<int> getCount() async {
    Database db = await this.database;
    List<Map<String, dynamic>> x =
        await db.rawQuery('SELECT COUNT (*) from $statusTable');

    int resultado = Sqflite.firstIntValue(x);
    return resultado;
  }

  Future close() async {
    Database db = await this.database;
    db.close;
  }
}
