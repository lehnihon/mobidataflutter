import 'dart:io';

import 'package:mobidata_dtc/classes/configuracoes.class.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static DatabaseHelper _databaseHelper;
  static Database _database;
  DatabaseHelper._createInstance();

  String configTable = 'config';
  String idCol = 'id';

  factory DatabaseHelper() {
    if (_databaseHelper == null) {
      _databaseHelper = DatabaseHelper._createInstance();
    }
    return _databaseHelper;
  }

  Future<Database> get database async {
    if (_database == null) {
      _database = await initializeDatabase();
    }

    return _database;
  }

  Future<Database> initializeDatabase() async {
    Directory directory = await getApplicationDocumentsDirectory();
    String path = directory.path + 'contatos.db';

    var contatosDatabase =
        await openDatabase(path, version: 1, onCreate: _createDb);
    return contatosDatabase;
  }

  void _createDb(Database db, int newVersion) async {
    await db.execute('CREATE TABLE $configTable($idCol VARCHAR(255))');
  }

  Future<int> insertConfig(Configuracoes config) async {
    Database db = await this.database;
    var resultado = await db.insert(configTable, config.toMap());

    return resultado;
  }

  Future<Configuracoes> getConfig() async {
    Database db = await this.database;

    List<Map> maps = await db.query(
      configTable,
      columns: [idCol],
    );

    if (maps.length > 0) {
      return Configuracoes.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<int> updateConfig(Configuracoes config) async {
    var db = await this.database;

    var resultado = await db.update(
      configTable,
      config.toMap(),
    );

    return resultado;
  }

  Future close() async {
    Database db = await this.database;
    db.close;
  }
}
