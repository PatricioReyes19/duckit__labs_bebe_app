import 'dart:io';

import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();

  test('IT-ACCOUNT-001: switching A to B opens isolated databases', () async {
    final suffix = DateTime.now().microsecondsSinceEpoch;
    final scopeA = 'bdd001-user-a-$suffix';
    final scopeB = 'bdd001-user-b-$suffix';
    var currentScope = scopeA;
    final database = BebeDatabase(
      databaseFactory: databaseFactoryFfi,
      scopeProvider: () async => currentScope,
    );
    final families = SqliteFamilyRepository(
      database,
      idGenerator: (prefix) => '$prefix-$currentScope',
    );
    final databaseDirectory = await databaseFactoryFfi.getDatabasesPath();
    final pathA =
        '$databaseDirectory${Platform.pathSeparator}'
        'bebeapp_$scopeA.sqlite';
    final pathB =
        '$databaseDirectory${Platform.pathSeparator}'
        'bebeapp_$scopeB.sqlite';
    addTearDown(() async {
      await database.close();
      await databaseFactoryFfi.deleteDatabase(pathA);
      await databaseFactoryFfi.deleteDatabase(pathB);
    });

    await families.createInitialFamily(
      InitialFamilyDraft(
        familyName: 'Family A',
        babyName: 'Baby A',
        birthDate: DateTime.utc(2026),
        ownerName: 'A',
        ownerEmail: 'a@example.com',
      ),
    );
    expect((await families.getCurrent()).activeBaby.name, 'Baby A');

    await database.close();
    currentScope = scopeB;
    expect(await families.listAvailable(), isEmpty);
    await families.createInitialFamily(
      InitialFamilyDraft(
        familyName: 'Family B',
        babyName: 'Baby B',
        birthDate: DateTime.utc(2026),
        ownerName: 'B',
        ownerEmail: 'b@example.com',
      ),
    );
    expect((await families.getCurrent()).activeBaby.name, 'Baby B');

    await database.close();
    currentScope = scopeA;
    final restoredA = await families.getCurrent();
    expect(restoredA.activeBaby.name, 'Baby A');
    expect(restoredA.babies.where((baby) => baby.name == 'Baby B'), isEmpty);
  });
}
