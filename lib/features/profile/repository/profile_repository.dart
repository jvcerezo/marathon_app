import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../models/user_profile.dart';

class ProfileRepository {
  final AppDatabase _db;
  ProfileRepository(this._db);

  Future<UserProfile?> get() async {
    final rows = await _db.select(_db.userProfiles).get();
    if (rows.isEmpty) return null;
    return _toDomain(rows.first);
  }

  Stream<UserProfile?> watch() {
    return _db.select(_db.userProfiles).watch().map(
          (rows) => rows.isEmpty ? null : _toDomain(rows.first),
        );
  }

  Future<void> save(UserProfile profile) async {
    await _db.into(_db.userProfiles).insertOnConflictUpdate(
          UserProfilesCompanion.insert(
            id: profile.id,
            ageYears: profile.ageYears,
            gender: profile.gender.name,
            heightCm: profile.heightCm,
            weightKg: profile.weightKg,
            fitnessLevel: profile.fitnessLevel.name,
            recentRunDistanceM: Value(profile.recentRunDistanceM),
            recentRunDurationSec: Value(profile.recentRunDuration?.inSeconds),
            daysPerWeek: Value(profile.daysPerWeek),
            targetMarathonDate: profile.targetMarathonDate,
            goalMarathonTimeSec: Value(profile.goalMarathonTime?.inSeconds),
            createdAt: profile.createdAt,
            updatedAt: profile.updatedAt,
          ),
        );
  }

  UserProfile _toDomain(UserProfileRow row) => UserProfile(
        id: row.id,
        ageYears: row.ageYears,
        gender: Gender.values.firstWhere((g) => g.name == row.gender),
        heightCm: row.heightCm,
        weightKg: row.weightKg,
        fitnessLevel: FitnessLevel.values
            .firstWhere((f) => f.name == row.fitnessLevel),
        recentRunDistanceM: row.recentRunDistanceM,
        recentRunDuration: row.recentRunDurationSec == null
            ? null
            : Duration(seconds: row.recentRunDurationSec!),
        daysPerWeek: row.daysPerWeek,
        targetMarathonDate: row.targetMarathonDate,
        goalMarathonTime: row.goalMarathonTimeSec == null
            ? null
            : Duration(seconds: row.goalMarathonTimeSec!),
        createdAt: row.createdAt,
        updatedAt: row.updatedAt,
      );
}
