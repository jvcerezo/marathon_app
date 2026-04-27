import 'package:drift/drift.dart';

@DataClassName('UserProfileRow')
class UserProfiles extends Table {
  TextColumn get id => text()();
  IntColumn get ageYears => integer()();
  TextColumn get gender => text()(); // enum string
  RealColumn get heightCm => real()();
  RealColumn get weightKg => real()();
  TextColumn get fitnessLevel => text()(); // enum string
  RealColumn get recentRunDistanceM => real().nullable()();
  IntColumn get recentRunDurationSec => integer().nullable()();
  IntColumn get daysPerWeek => integer().withDefault(const Constant(4))();
  DateTimeColumn get targetMarathonDate => dateTime()();
  IntColumn get goalMarathonTimeSec => integer().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('RunRow')
class Runs extends Table {
  TextColumn get id => text()();
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get endedAt => dateTime().nullable()();
  RealColumn get distanceM => real().withDefault(const Constant(0))();
  IntColumn get movingTimeSec => integer().withDefault(const Constant(0))();
  IntColumn get elapsedTimeSec => integer().withDefault(const Constant(0))();
  RealColumn get avgPaceSecPerKm => real().nullable()();
  RealColumn get elevationGainM => real().withDefault(const Constant(0))();
  TextColumn get encodedPolyline => text().nullable()();
  TextColumn get source => text().withDefault(const Constant('gps'))();
  TextColumn get matchedSessionId => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('RunSampleRow')
class RunSamples extends Table {
  TextColumn get runId => text()();
  IntColumn get tOffsetMs => integer()();
  RealColumn get lat => real()();
  RealColumn get lon => real()();
  RealColumn get elevationM => real().nullable()();
  RealColumn get instantSpeedMps => real().nullable()();

  @override
  Set<Column> get primaryKey => {runId, tOffsetMs};
}

@DataClassName('PlanRow')
class Plans extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  DateTimeColumn get startsOn => dateTime()();
  DateTimeColumn get targetMarathonDate => dateTime()();
  IntColumn get totalWeeks => integer()();
  RealColumn get startVdot => real()();
  RealColumn get targetVdot => real()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('PlanSessionRow')
class PlanSessionsTable extends Table {
  @override
  String get tableName => 'plan_sessions';

  TextColumn get id => text()();
  TextColumn get planId => text()();
  DateTimeColumn get scheduledDate => dateTime()();
  IntColumn get weekNumber => integer()();
  IntColumn get dayOfWeek => integer()();
  TextColumn get type => text()();
  RealColumn get prescribedDistanceKm => real()();
  RealColumn get prescribedPaceSecPerKm => real().nullable()();
  TextColumn get notes => text().nullable()();
  TextColumn get status => text()();
  TextColumn get matchedRunId => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
