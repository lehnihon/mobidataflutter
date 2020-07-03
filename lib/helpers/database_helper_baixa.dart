import 'dart:io';

import 'package:mobidata_dtc/classes/baixa.class.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelperBaixa {
  static DatabaseHelperBaixa _databaseHelperBaixa;
  static Database _databaseBaixa;
  DatabaseHelperBaixa._createInstance();

  String idCol = 'id';
  String baixaTable = 'baixa';
  String notaCol = 'nota';
  String statusCol = 'status';
  String fotoCol = 'foto';
  String dataCol = 'data';
  String horaCol = 'hora';
  String latitudeCol = 'latitude';
  String longitudeCol = 'longitude';
  String useridCol = 'userid';

  factory DatabaseHelperBaixa() {
    if (_databaseHelperBaixa == null) {
      _databaseHelperBaixa = DatabaseHelperBaixa._createInstance();
    }
    return _databaseHelperBaixa;
  }

  Future<Database> get database async {
    if (_databaseBaixa == null) {
      _databaseBaixa = await initializeDatabase();
    }

    return _databaseBaixa;
  }

  Future<Database> initializeDatabase() async {
    Directory directory = await getApplicationDocumentsDirectory();
    String path = directory.path + 'baixa.db';

    var baixasDatabase =
        await openDatabase(path, version: 1, onCreate: _createDb);
    return baixasDatabase;
  }

  void _createDb(Database db, int newVersion) async {
    await db.execute(
        'CREATE TABLE $baixaTable($idCol INTEGER PRIMARY KEY AUTOINCREMENT,$notaCol VARCHAR(255), $statusCol VARCHAR(255), $fotoCol TEXT, $dataCol VARCHAR(255), $horaCol VARCHAR(255), $latitudeCol VARCHAR(255), $longitudeCol VARCHAR(255), $useridCol VARCHAR(255))');
  }

  Future<int> insertBaixa(Baixa baixa) async {
    Database db = await this.database;

    var resultado = await db.insert(baixaTable, baixa.toMap());

    return resultado;
  }

  Future<Baixa> getBaixa(int id) async {
    Database db = await this.database;

    List<Map> maps = await db.query(baixaTable,
        columns: [
          notaCol,
          statusCol,
          fotoCol,
          dataCol,
          horaCol,
          latitudeCol,
          longitudeCol,
          useridCol,
        ],
        where: "$idCol = ?",
        whereArgs: [id]);

    if (maps.length > 0) {
      return Baixa.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<List<Baixa>> getBaixaLista() async {
    Database db = await this.database;

    var resultado = await db.query(baixaTable);

    List<Baixa> lista = resultado.isNotEmpty
        ? resultado.map((c) => Baixa.fromMap(c)).toList()
        : [];

    return lista;
  }

  Future<int> updateBaixa(Baixa baixa) async {
    var db = await this.database;

    var resultado = await db.update(
      baixaTable,
      baixa.toMap(),
    );

    return resultado;
  }

  Future<int> getCount() async {
    Database db = await this.database;
    List<Map<String, dynamic>> x =
        await db.rawQuery('SELECT COUNT (*) from $baixaTable');

    int resultado = Sqflite.firstIntValue(x);
    return resultado;
  }

  Future close() async {
    Database db = await this.database;
    db.close;
  }
}
