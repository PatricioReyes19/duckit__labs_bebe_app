import 'dart:io';

import 'package:sqflite/sqflite.dart' as sqlite;

import 'bebe_database_schema.dart';
import 'bebe_seed_data.dart';

typedef DatabaseScopeProvider = Future<String?> Function();

class BebeDatabase {
  BebeDatabase({
    sqlite.DatabaseFactory? databaseFactory,
    this._databasePath,
    this._scopeProvider,
    this._seedDemoData = false,
  }) : _databaseFactory = databaseFactory ?? sqlite.databaseFactory;

  static const databaseName = 'bebeapp.sqlite';

  final sqlite.DatabaseFactory _databaseFactory;
  final String? _databasePath;
  final DatabaseScopeProvider? _scopeProvider;
  final bool _seedDemoData;
  sqlite.Database? _instance;
  String? _openedPath;
  Future<sqlite.Database>? _openingFuture;
  String? _openingPath;

  Future<sqlite.Database> get database async {
    final path = await _resolvePath();
    return _databaseForPath(path);
  }

  Future<sqlite.Database> _databaseForPath(String path) async {
    final current = _instance;
    if (current != null && _openedPath == path) return current;

    final opening = _openingFuture;
    if (opening != null) {
      if (_openingPath == path) return opening;
      try {
        await opening;
      } on Object {
        // The next open remains retryable after a failed initialization.
      }
      return _databaseForPath(path);
    }

    if (_instance != null) await close();

    late final Future<sqlite.Database> operation;
    operation = _openDatabase(path)
        .then((database) {
          if (identical(_openingFuture, operation)) {
            _instance = database;
            _openedPath = path;
          }
          return database;
        })
        .whenComplete(() {
          if (identical(_openingFuture, operation)) {
            _openingFuture = null;
            _openingPath = null;
          }
        });
    _openingPath = path;
    _openingFuture = operation;
    return operation;
  }

  Future<sqlite.Database> _openDatabase(String path) =>
      _databaseFactory.openDatabase(
        path,
        options: sqlite.OpenDatabaseOptions(
          version: BebeDatabaseSchema.version,
          onConfigure: (database) =>
              database.execute('PRAGMA foreign_keys = ON'),
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
            if (oldVersion < 5) {
              await BebeDatabaseSchema.upgradeFamilyInvitations(database);
            }
            if (oldVersion < 6) {
              await BebeDatabaseSchema.upgradeHealthAndSettingsForSync(
                database,
              );
            }
            if (oldVersion < 7) {
              await BebeDatabaseSchema.upgradeCoreRelationsV7(database);
            }
            if (oldVersion < 8) {
              await BebeDatabaseSchema.upgradePendingSyncIndexesV8(database);
            }
            if (oldVersion < 9) {
              await BebeDatabaseSchema.upgradeHealthAppointmentsV9(database);
            }
          },
        ),
      );

  Future<void> close() async {
    final opening = _openingFuture;
    if (opening != null) {
      try {
        await opening;
      } on Object {
        // A failed open leaves no instance to close.
      }
      if (_openingFuture != null) return;
    }
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
