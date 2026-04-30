import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';

import 'tables.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    UserProfiles,
    Runs,
    RunSamples,
    Plans,
    PlanSessionsTable,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.addColumn(userProfiles, userProfiles.name);
          }
          if (from < 3) {
            await m.addColumn(userProfiles, userProfiles.goalDistance);
          }
          if (from < 4) {
            await m.addColumn(plans, plans.planType);
          }
        },
      );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'bakas.sqlite'));

    // Workaround for Android close-on-restart sqlite issue (drift docs).
    if (Platform.isAndroid) {
      await applyWorkaroundToOpenSqlite3OnOldAndroidVersions();
    }
    return NativeDatabase.createInBackground(file);
  });
}
