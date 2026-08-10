import 'dart:io';

import 'package:sqflite/sqflite.dart' as sqlite;

import 'bebe_database_schema.dart';
import 'bebe_seed_data.dart';

typedef DatabaseScopeProvider = Future<String?> Function();

class BebeDatabase {
  BebeDatabase({
    sqlite.DatabaseFactory? databaseFactory,
    String? databasePath,
    DatabaseScopeProvider? scopeProvider,
    bool seedDemoData = false,
  }) : _databaseFactory = databaseFactory ?? sqlite.databaseFactory,
       _databasePath = databasePath,
       _scopeProvider = scopeProvider,
       _seedDemoData = seedDemoData;

  static const databaseName = 'bebeapp.sqlite';

  final sqlite.DatabaseFactory _databaseFactory;
  final String? _databasePath;
  final DatabaseScopeProvider? _scopeProvider;
  final bool _seedDemoData;
  sqlite.Database? _instance;
  String? _openedPath;

  Future<sqlite.Database> get database async {
    final path = await _resolvePath();
    final current = _instance;
    if (current != null && _openedPath == path) return current;
    if (current != null) await close();
    _openedPath = path;
    return _instance = await _databaseFactory.openDatabase(
      path,
      options: sqlite.OpenDatabaseOptions(
        version: BebeDatabaseSchema.version,
        onConfigure: (database) => database.execute('PRAGMA foreign_keys = ON'),
        onCreate: (database, _) async {
          await BebeDatabaseSchema.create(database);
          if (_seedDemoData) await BebeSeedData.insert(database);
        },
        onUpgrade: (database, oldVersion, _) async {
          if (oldVersion < 2) {
            await BebeDatabaseSchema.createApplicationData(database);
            if (_seedDemoData) await BebeSeedData.insert(database);
          }
          if (oldVersion < 3) {
            await BebeDatabaseSchema.upgradeRegisterEventsForSync(database);
          }
          if (oldVersion < 4) {
            await BebeDatabaseSchema.upgradeAgendaEventsForSync(database);
          }
        },
      ),
    );
  }

  Future<void> close() async {
    final database = _instance;
    _instance = null;
    _openedPath = null;
    await database?.close();
  }

  Future<String> _resolvePath() async {
    final configuredPath = _databasePath;
    if (configuredPath != null) return configuredPath;

    final scope = (await _scopeProvider?.call())?.trim();
    if (scope == null || scope.isEmpty) {
      throw StateError(
        'An authenticated account is required before opening local data.',
      );
    }
    final safeScope = scope.replaceAll(RegExp('[^a-zA-Z0-9_-]'), '_');
    final directory = await _databaseFactory.getDatabasesPath();
    return '$directory${Platform.pathSeparator}bebeapp_$safeScope.sqlite';
  }
}
