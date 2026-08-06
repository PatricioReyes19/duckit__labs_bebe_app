import 'dart:io';

import 'package:sqflite/sqflite.dart' as sqlite;

import 'bebe_database_schema.dart';
import 'bebe_seed_data.dart';

class BebeDatabase {
  BebeDatabase({sqlite.DatabaseFactory? databaseFactory, String? databasePath})
    : _databaseFactory = databaseFactory ?? sqlite.databaseFactory,
      _databasePath = databasePath;

  static const databaseName = 'bebeapp.sqlite';

  final sqlite.DatabaseFactory _databaseFactory;
  final String? _databasePath;
  sqlite.Database? _instance;

  Future<sqlite.Database> get database async {
    final current = _instance;
    if (current != null) return current;
    final configuredPath = _databasePath;
    final path =
        configuredPath ??
        '${await _databaseFactory.getDatabasesPath()}'
            '${Platform.pathSeparator}$databaseName';
    return _instance = await _databaseFactory.openDatabase(
      path,
      options: sqlite.OpenDatabaseOptions(
        version: BebeDatabaseSchema.version,
        onConfigure: (database) => database.execute('PRAGMA foreign_keys = ON'),
        onCreate: (database, _) async {
          await BebeDatabaseSchema.create(database);
          await BebeSeedData.insert(database);
        },
        onUpgrade: (database, oldVersion, _) async {
          if (oldVersion < 2) {
            await BebeDatabaseSchema.createApplicationData(database);
            await BebeSeedData.insert(database);
          }
        },
      ),
    );
  }

  Future<void> close() async {
    final database = _instance;
    _instance = null;
    await database?.close();
  }
}
