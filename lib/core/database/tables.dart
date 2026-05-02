import 'package:drift/drift.dart';

@DataClassName('UserProfileRow')
class UserProfiles extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().withDefault(const Constant(''))();
  IntColumn get ageYears => integer()();
  TextColumn get gender => text()(); // enum string
  RealColumn get heightCm => real()();
  RealColumn get weightKg => real()();
  TextColumn get fitnessLevel => text()(); // enum string
  RealColumn get recentRunDistanceM => real().nullable()();
  IntColumn get recentRunDurationSec => integer().nullable()();
  IntColumn get daysPerWeek => integer().withDefault(const Constant(4))();
  TextColumn get goalDistance =>
      text().withDefault(const Constant('marathon'))();
  DateTimeColumn get targetMarathonDate => dateTime()();
  IntColumn get goalMarathonTimeSec => integer().nullable()();
  // True = training for a specific race day (uses targetMarathonDate to
  // anchor the taper). False = open-ended progressive plan that ramps
  // volume + introduces quality work without targeting a race.
  // Defaults to true so existing rows behave the way they always did.
  BoolColumn get hasRaceGoal =>
      boolean().withDefault(const Constant(true))();
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

  // Cached fastest contiguous split times for each milestone distance.
  // Computed from the sample stream when the run is finalized; null if
  // the run wasn't long enough to contain a split at that distance.
  RealColumn get bestSplit1kSec => real().nullable()();
  RealColumn get bestSplit5kSec => real().nullable()();
  RealColumn get bestSplit10kSec => real().nullable()();
  RealColumn get bestSplitHalfSec => real().nullable()();
  RealColumn get bestSplitMarathonSec => real().nullable()();

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
  TextColumn get planType => text().withDefault(const Constant('race'))();
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
