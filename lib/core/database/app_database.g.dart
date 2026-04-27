// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $UserProfilesTable extends UserProfiles
    with TableInfo<$UserProfilesTable, UserProfileRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserProfilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ageYearsMeta = const VerificationMeta(
    'ageYears',
  );
  @override
  late final GeneratedColumn<int> ageYears = GeneratedColumn<int>(
    'age_years',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _genderMeta = const VerificationMeta('gender');
  @override
  late final GeneratedColumn<String> gender = GeneratedColumn<String>(
    'gender',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _heightCmMeta = const VerificationMeta(
    'heightCm',
  );
  @override
  late final GeneratedColumn<double> heightCm = GeneratedColumn<double>(
    'height_cm',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _weightKgMeta = const VerificationMeta(
    'weightKg',
  );
  @override
  late final GeneratedColumn<double> weightKg = GeneratedColumn<double>(
    'weight_kg',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fitnessLevelMeta = const VerificationMeta(
    'fitnessLevel',
  );
  @override
  late final GeneratedColumn<String> fitnessLevel = GeneratedColumn<String>(
    'fitness_level',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _recentRunDistanceMMeta =
      const VerificationMeta('recentRunDistanceM');
  @override
  late final GeneratedColumn<double> recentRunDistanceM =
      GeneratedColumn<double>(
        'recent_run_distance_m',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _recentRunDurationSecMeta =
      const VerificationMeta('recentRunDurationSec');
  @override
  late final GeneratedColumn<int> recentRunDurationSec = GeneratedColumn<int>(
    'recent_run_duration_sec',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _daysPerWeekMeta = const VerificationMeta(
    'daysPerWeek',
  );
  @override
  late final GeneratedColumn<int> daysPerWeek = GeneratedColumn<int>(
    'days_per_week',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(4),
  );
  static const VerificationMeta _targetMarathonDateMeta =
      const VerificationMeta('targetMarathonDate');
  @override
  late final GeneratedColumn<DateTime> targetMarathonDate =
      GeneratedColumn<DateTime>(
        'target_marathon_date',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _goalMarathonTimeSecMeta =
      const VerificationMeta('goalMarathonTimeSec');
  @override
  late final GeneratedColumn<int> goalMarathonTimeSec = GeneratedColumn<int>(
    'goal_marathon_time_sec',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    ageYears,
    gender,
    heightCm,
    weightKg,
    fitnessLevel,
    recentRunDistanceM,
    recentRunDurationSec,
    daysPerWeek,
    targetMarathonDate,
    goalMarathonTimeSec,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_profiles';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserProfileRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('age_years')) {
      context.handle(
        _ageYearsMeta,
        ageYears.isAcceptableOrUnknown(data['age_years']!, _ageYearsMeta),
      );
    } else if (isInserting) {
      context.missing(_ageYearsMeta);
    }
    if (data.containsKey('gender')) {
      context.handle(
        _genderMeta,
        gender.isAcceptableOrUnknown(data['gender']!, _genderMeta),
      );
    } else if (isInserting) {
      context.missing(_genderMeta);
    }
    if (data.containsKey('height_cm')) {
      context.handle(
        _heightCmMeta,
        heightCm.isAcceptableOrUnknown(data['height_cm']!, _heightCmMeta),
      );
    } else if (isInserting) {
      context.missing(_heightCmMeta);
    }
    if (data.containsKey('weight_kg')) {
      context.handle(
        _weightKgMeta,
        weightKg.isAcceptableOrUnknown(data['weight_kg']!, _weightKgMeta),
      );
    } else if (isInserting) {
      context.missing(_weightKgMeta);
    }
    if (data.containsKey('fitness_level')) {
      context.handle(
        _fitnessLevelMeta,
        fitnessLevel.isAcceptableOrUnknown(
          data['fitness_level']!,
          _fitnessLevelMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_fitnessLevelMeta);
    }
    if (data.containsKey('recent_run_distance_m')) {
      context.handle(
        _recentRunDistanceMMeta,
        recentRunDistanceM.isAcceptableOrUnknown(
          data['recent_run_distance_m']!,
          _recentRunDistanceMMeta,
        ),
      );
    }
    if (data.containsKey('recent_run_duration_sec')) {
      context.handle(
        _recentRunDurationSecMeta,
        recentRunDurationSec.isAcceptableOrUnknown(
          data['recent_run_duration_sec']!,
          _recentRunDurationSecMeta,
        ),
      );
    }
    if (data.containsKey('days_per_week')) {
      context.handle(
        _daysPerWeekMeta,
        daysPerWeek.isAcceptableOrUnknown(
          data['days_per_week']!,
          _daysPerWeekMeta,
        ),
      );
    }
    if (data.containsKey('target_marathon_date')) {
      context.handle(
        _targetMarathonDateMeta,
        targetMarathonDate.isAcceptableOrUnknown(
          data['target_marathon_date']!,
          _targetMarathonDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_targetMarathonDateMeta);
    }
    if (data.containsKey('goal_marathon_time_sec')) {
      context.handle(
        _goalMarathonTimeSecMeta,
        goalMarathonTimeSec.isAcceptableOrUnknown(
          data['goal_marathon_time_sec']!,
          _goalMarathonTimeSecMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserProfileRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserProfileRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      ageYears: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}age_years'],
      )!,
      gender: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}gender'],
      )!,
      heightCm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}height_cm'],
      )!,
      weightKg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}weight_kg'],
      )!,
      fitnessLevel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}fitness_level'],
      )!,
      recentRunDistanceM: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}recent_run_distance_m'],
      ),
      recentRunDurationSec: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}recent_run_duration_sec'],
      ),
      daysPerWeek: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}days_per_week'],
      )!,
      targetMarathonDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}target_marathon_date'],
      )!,
      goalMarathonTimeSec: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}goal_marathon_time_sec'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $UserProfilesTable createAlias(String alias) {
    return $UserProfilesTable(attachedDatabase, alias);
  }
}

class UserProfileRow extends DataClass implements Insertable<UserProfileRow> {
  final String id;
  final int ageYears;
  final String gender;
  final double heightCm;
  final double weightKg;
  final String fitnessLevel;
  final double? recentRunDistanceM;
  final int? recentRunDurationSec;
  final int daysPerWeek;
  final DateTime targetMarathonDate;
  final int? goalMarathonTimeSec;
  final DateTime createdAt;
  final DateTime updatedAt;
  const UserProfileRow({
    required this.id,
    required this.ageYears,
    required this.gender,
    required this.heightCm,
    required this.weightKg,
    required this.fitnessLevel,
    this.recentRunDistanceM,
    this.recentRunDurationSec,
    required this.daysPerWeek,
    required this.targetMarathonDate,
    this.goalMarathonTimeSec,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['age_years'] = Variable<int>(ageYears);
    map['gender'] = Variable<String>(gender);
    map['height_cm'] = Variable<double>(heightCm);
    map['weight_kg'] = Variable<double>(weightKg);
    map['fitness_level'] = Variable<String>(fitnessLevel);
    if (!nullToAbsent || recentRunDistanceM != null) {
      map['recent_run_distance_m'] = Variable<double>(recentRunDistanceM);
    }
    if (!nullToAbsent || recentRunDurationSec != null) {
      map['recent_run_duration_sec'] = Variable<int>(recentRunDurationSec);
    }
    map['days_per_week'] = Variable<int>(daysPerWeek);
    map['target_marathon_date'] = Variable<DateTime>(targetMarathonDate);
    if (!nullToAbsent || goalMarathonTimeSec != null) {
      map['goal_marathon_time_sec'] = Variable<int>(goalMarathonTimeSec);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  UserProfilesCompanion toCompanion(bool nullToAbsent) {
    return UserProfilesCompanion(
      id: Value(id),
      ageYears: Value(ageYears),
      gender: Value(gender),
      heightCm: Value(heightCm),
      weightKg: Value(weightKg),
      fitnessLevel: Value(fitnessLevel),
      recentRunDistanceM: recentRunDistanceM == null && nullToAbsent
          ? const Value.absent()
          : Value(recentRunDistanceM),
      recentRunDurationSec: recentRunDurationSec == null && nullToAbsent
          ? const Value.absent()
          : Value(recentRunDurationSec),
      daysPerWeek: Value(daysPerWeek),
      targetMarathonDate: Value(targetMarathonDate),
      goalMarathonTimeSec: goalMarathonTimeSec == null && nullToAbsent
          ? const Value.absent()
          : Value(goalMarathonTimeSec),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory UserProfileRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserProfileRow(
      id: serializer.fromJson<String>(json['id']),
      ageYears: serializer.fromJson<int>(json['ageYears']),
      gender: serializer.fromJson<String>(json['gender']),
      heightCm: serializer.fromJson<double>(json['heightCm']),
      weightKg: serializer.fromJson<double>(json['weightKg']),
      fitnessLevel: serializer.fromJson<String>(json['fitnessLevel']),
      recentRunDistanceM: serializer.fromJson<double?>(
        json['recentRunDistanceM'],
      ),
      recentRunDurationSec: serializer.fromJson<int?>(
        json['recentRunDurationSec'],
      ),
      daysPerWeek: serializer.fromJson<int>(json['daysPerWeek']),
      targetMarathonDate: serializer.fromJson<DateTime>(
        json['targetMarathonDate'],
      ),
      goalMarathonTimeSec: serializer.fromJson<int?>(
        json['goalMarathonTimeSec'],
      ),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'ageYears': serializer.toJson<int>(ageYears),
      'gender': serializer.toJson<String>(gender),
      'heightCm': serializer.toJson<double>(heightCm),
      'weightKg': serializer.toJson<double>(weightKg),
      'fitnessLevel': serializer.toJson<String>(fitnessLevel),
      'recentRunDistanceM': serializer.toJson<double?>(recentRunDistanceM),
      'recentRunDurationSec': serializer.toJson<int?>(recentRunDurationSec),
      'daysPerWeek': serializer.toJson<int>(daysPerWeek),
      'targetMarathonDate': serializer.toJson<DateTime>(targetMarathonDate),
      'goalMarathonTimeSec': serializer.toJson<int?>(goalMarathonTimeSec),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  UserProfileRow copyWith({
    String? id,
    int? ageYears,
    String? gender,
    double? heightCm,
    double? weightKg,
    String? fitnessLevel,
    Value<double?> recentRunDistanceM = const Value.absent(),
    Value<int?> recentRunDurationSec = const Value.absent(),
    int? daysPerWeek,
    DateTime? targetMarathonDate,
    Value<int?> goalMarathonTimeSec = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => UserProfileRow(
    id: id ?? this.id,
    ageYears: ageYears ?? this.ageYears,
    gender: gender ?? this.gender,
    heightCm: heightCm ?? this.heightCm,
    weightKg: weightKg ?? this.weightKg,
    fitnessLevel: fitnessLevel ?? this.fitnessLevel,
    recentRunDistanceM: recentRunDistanceM.present
        ? recentRunDistanceM.value
        : this.recentRunDistanceM,
    recentRunDurationSec: recentRunDurationSec.present
        ? recentRunDurationSec.value
        : this.recentRunDurationSec,
    daysPerWeek: daysPerWeek ?? this.daysPerWeek,
    targetMarathonDate: targetMarathonDate ?? this.targetMarathonDate,
    goalMarathonTimeSec: goalMarathonTimeSec.present
        ? goalMarathonTimeSec.value
        : this.goalMarathonTimeSec,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  UserProfileRow copyWithCompanion(UserProfilesCompanion data) {
    return UserProfileRow(
      id: data.id.present ? data.id.value : this.id,
      ageYears: data.ageYears.present ? data.ageYears.value : this.ageYears,
      gender: data.gender.present ? data.gender.value : this.gender,
      heightCm: data.heightCm.present ? data.heightCm.value : this.heightCm,
      weightKg: data.weightKg.present ? data.weightKg.value : this.weightKg,
      fitnessLevel: data.fitnessLevel.present
          ? data.fitnessLevel.value
          : this.fitnessLevel,
      recentRunDistanceM: data.recentRunDistanceM.present
          ? data.recentRunDistanceM.value
          : this.recentRunDistanceM,
      recentRunDurationSec: data.recentRunDurationSec.present
          ? data.recentRunDurationSec.value
          : this.recentRunDurationSec,
      daysPerWeek: data.daysPerWeek.present
          ? data.daysPerWeek.value
          : this.daysPerWeek,
      targetMarathonDate: data.targetMarathonDate.present
          ? data.targetMarathonDate.value
          : this.targetMarathonDate,
      goalMarathonTimeSec: data.goalMarathonTimeSec.present
          ? data.goalMarathonTimeSec.value
          : this.goalMarathonTimeSec,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserProfileRow(')
          ..write('id: $id, ')
          ..write('ageYears: $ageYears, ')
          ..write('gender: $gender, ')
          ..write('heightCm: $heightCm, ')
          ..write('weightKg: $weightKg, ')
          ..write('fitnessLevel: $fitnessLevel, ')
          ..write('recentRunDistanceM: $recentRunDistanceM, ')
          ..write('recentRunDurationSec: $recentRunDurationSec, ')
          ..write('daysPerWeek: $daysPerWeek, ')
          ..write('targetMarathonDate: $targetMarathonDate, ')
          ..write('goalMarathonTimeSec: $goalMarathonTimeSec, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    ageYears,
    gender,
    heightCm,
    weightKg,
    fitnessLevel,
    recentRunDistanceM,
    recentRunDurationSec,
    daysPerWeek,
    targetMarathonDate,
    goalMarathonTimeSec,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserProfileRow &&
          other.id == this.id &&
          other.ageYears == this.ageYears &&
          other.gender == this.gender &&
          other.heightCm == this.heightCm &&
          other.weightKg == this.weightKg &&
          other.fitnessLevel == this.fitnessLevel &&
          other.recentRunDistanceM == this.recentRunDistanceM &&
          other.recentRunDurationSec == this.recentRunDurationSec &&
          other.daysPerWeek == this.daysPerWeek &&
          other.targetMarathonDate == this.targetMarathonDate &&
          other.goalMarathonTimeSec == this.goalMarathonTimeSec &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class UserProfilesCompanion extends UpdateCompanion<UserProfileRow> {
  final Value<String> id;
  final Value<int> ageYears;
  final Value<String> gender;
  final Value<double> heightCm;
  final Value<double> weightKg;
  final Value<String> fitnessLevel;
  final Value<double?> recentRunDistanceM;
  final Value<int?> recentRunDurationSec;
  final Value<int> daysPerWeek;
  final Value<DateTime> targetMarathonDate;
  final Value<int?> goalMarathonTimeSec;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const UserProfilesCompanion({
    this.id = const Value.absent(),
    this.ageYears = const Value.absent(),
    this.gender = const Value.absent(),
    this.heightCm = const Value.absent(),
    this.weightKg = const Value.absent(),
    this.fitnessLevel = const Value.absent(),
    this.recentRunDistanceM = const Value.absent(),
    this.recentRunDurationSec = const Value.absent(),
    this.daysPerWeek = const Value.absent(),
    this.targetMarathonDate = const Value.absent(),
    this.goalMarathonTimeSec = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UserProfilesCompanion.insert({
    required String id,
    required int ageYears,
    required String gender,
    required double heightCm,
    required double weightKg,
    required String fitnessLevel,
    this.recentRunDistanceM = const Value.absent(),
    this.recentRunDurationSec = const Value.absent(),
    this.daysPerWeek = const Value.absent(),
    required DateTime targetMarathonDate,
    this.goalMarathonTimeSec = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       ageYears = Value(ageYears),
       gender = Value(gender),
       heightCm = Value(heightCm),
       weightKg = Value(weightKg),
       fitnessLevel = Value(fitnessLevel),
       targetMarathonDate = Value(targetMarathonDate),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<UserProfileRow> custom({
    Expression<String>? id,
    Expression<int>? ageYears,
    Expression<String>? gender,
    Expression<double>? heightCm,
    Expression<double>? weightKg,
    Expression<String>? fitnessLevel,
    Expression<double>? recentRunDistanceM,
    Expression<int>? recentRunDurationSec,
    Expression<int>? daysPerWeek,
    Expression<DateTime>? targetMarathonDate,
    Expression<int>? goalMarathonTimeSec,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ageYears != null) 'age_years': ageYears,
      if (gender != null) 'gender': gender,
      if (heightCm != null) 'height_cm': heightCm,
      if (weightKg != null) 'weight_kg': weightKg,
      if (fitnessLevel != null) 'fitness_level': fitnessLevel,
      if (recentRunDistanceM != null)
        'recent_run_distance_m': recentRunDistanceM,
      if (recentRunDurationSec != null)
        'recent_run_duration_sec': recentRunDurationSec,
      if (daysPerWeek != null) 'days_per_week': daysPerWeek,
      if (targetMarathonDate != null)
        'target_marathon_date': targetMarathonDate,
      if (goalMarathonTimeSec != null)
        'goal_marathon_time_sec': goalMarathonTimeSec,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UserProfilesCompanion copyWith({
    Value<String>? id,
    Value<int>? ageYears,
    Value<String>? gender,
    Value<double>? heightCm,
    Value<double>? weightKg,
    Value<String>? fitnessLevel,
    Value<double?>? recentRunDistanceM,
    Value<int?>? recentRunDurationSec,
    Value<int>? daysPerWeek,
    Value<DateTime>? targetMarathonDate,
    Value<int?>? goalMarathonTimeSec,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return UserProfilesCompanion(
      id: id ?? this.id,
      ageYears: ageYears ?? this.ageYears,
      gender: gender ?? this.gender,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      fitnessLevel: fitnessLevel ?? this.fitnessLevel,
      recentRunDistanceM: recentRunDistanceM ?? this.recentRunDistanceM,
      recentRunDurationSec: recentRunDurationSec ?? this.recentRunDurationSec,
      daysPerWeek: daysPerWeek ?? this.daysPerWeek,
      targetMarathonDate: targetMarathonDate ?? this.targetMarathonDate,
      goalMarathonTimeSec: goalMarathonTimeSec ?? this.goalMarathonTimeSec,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (ageYears.present) {
      map['age_years'] = Variable<int>(ageYears.value);
    }
    if (gender.present) {
      map['gender'] = Variable<String>(gender.value);
    }
    if (heightCm.present) {
      map['height_cm'] = Variable<double>(heightCm.value);
    }
    if (weightKg.present) {
      map['weight_kg'] = Variable<double>(weightKg.value);
    }
    if (fitnessLevel.present) {
      map['fitness_level'] = Variable<String>(fitnessLevel.value);
    }
    if (recentRunDistanceM.present) {
      map['recent_run_distance_m'] = Variable<double>(recentRunDistanceM.value);
    }
    if (recentRunDurationSec.present) {
      map['recent_run_duration_sec'] = Variable<int>(
        recentRunDurationSec.value,
      );
    }
    if (daysPerWeek.present) {
      map['days_per_week'] = Variable<int>(daysPerWeek.value);
    }
    if (targetMarathonDate.present) {
      map['target_marathon_date'] = Variable<DateTime>(
        targetMarathonDate.value,
      );
    }
    if (goalMarathonTimeSec.present) {
      map['goal_marathon_time_sec'] = Variable<int>(goalMarathonTimeSec.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserProfilesCompanion(')
          ..write('id: $id, ')
          ..write('ageYears: $ageYears, ')
          ..write('gender: $gender, ')
          ..write('heightCm: $heightCm, ')
          ..write('weightKg: $weightKg, ')
          ..write('fitnessLevel: $fitnessLevel, ')
          ..write('recentRunDistanceM: $recentRunDistanceM, ')
          ..write('recentRunDurationSec: $recentRunDurationSec, ')
          ..write('daysPerWeek: $daysPerWeek, ')
          ..write('targetMarathonDate: $targetMarathonDate, ')
          ..write('goalMarathonTimeSec: $goalMarathonTimeSec, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RunsTable extends Runs with TableInfo<$RunsTable, RunRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RunsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endedAtMeta = const VerificationMeta(
    'endedAt',
  );
  @override
  late final GeneratedColumn<DateTime> endedAt = GeneratedColumn<DateTime>(
    'ended_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _distanceMMeta = const VerificationMeta(
    'distanceM',
  );
  @override
  late final GeneratedColumn<double> distanceM = GeneratedColumn<double>(
    'distance_m',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _movingTimeSecMeta = const VerificationMeta(
    'movingTimeSec',
  );
  @override
  late final GeneratedColumn<int> movingTimeSec = GeneratedColumn<int>(
    'moving_time_sec',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _elapsedTimeSecMeta = const VerificationMeta(
    'elapsedTimeSec',
  );
  @override
  late final GeneratedColumn<int> elapsedTimeSec = GeneratedColumn<int>(
    'elapsed_time_sec',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _avgPaceSecPerKmMeta = const VerificationMeta(
    'avgPaceSecPerKm',
  );
  @override
  late final GeneratedColumn<double> avgPaceSecPerKm = GeneratedColumn<double>(
    'avg_pace_sec_per_km',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _elevationGainMMeta = const VerificationMeta(
    'elevationGainM',
  );
  @override
  late final GeneratedColumn<double> elevationGainM = GeneratedColumn<double>(
    'elevation_gain_m',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _encodedPolylineMeta = const VerificationMeta(
    'encodedPolyline',
  );
  @override
  late final GeneratedColumn<String> encodedPolyline = GeneratedColumn<String>(
    'encoded_polyline',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('gps'),
  );
  static const VerificationMeta _matchedSessionIdMeta = const VerificationMeta(
    'matchedSessionId',
  );
  @override
  late final GeneratedColumn<String> matchedSessionId = GeneratedColumn<String>(
    'matched_session_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    startedAt,
    endedAt,
    distanceM,
    movingTimeSec,
    elapsedTimeSec,
    avgPaceSecPerKm,
    elevationGainM,
    encodedPolyline,
    source,
    matchedSessionId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'runs';
  @override
  VerificationContext validateIntegrity(
    Insertable<RunRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('ended_at')) {
      context.handle(
        _endedAtMeta,
        endedAt.isAcceptableOrUnknown(data['ended_at']!, _endedAtMeta),
      );
    }
    if (data.containsKey('distance_m')) {
      context.handle(
        _distanceMMeta,
        distanceM.isAcceptableOrUnknown(data['distance_m']!, _distanceMMeta),
      );
    }
    if (data.containsKey('moving_time_sec')) {
      context.handle(
        _movingTimeSecMeta,
        movingTimeSec.isAcceptableOrUnknown(
          data['moving_time_sec']!,
          _movingTimeSecMeta,
        ),
      );
    }
    if (data.containsKey('elapsed_time_sec')) {
      context.handle(
        _elapsedTimeSecMeta,
        elapsedTimeSec.isAcceptableOrUnknown(
          data['elapsed_time_sec']!,
          _elapsedTimeSecMeta,
        ),
      );
    }
    if (data.containsKey('avg_pace_sec_per_km')) {
      context.handle(
        _avgPaceSecPerKmMeta,
        avgPaceSecPerKm.isAcceptableOrUnknown(
          data['avg_pace_sec_per_km']!,
          _avgPaceSecPerKmMeta,
        ),
      );
    }
    if (data.containsKey('elevation_gain_m')) {
      context.handle(
        _elevationGainMMeta,
        elevationGainM.isAcceptableOrUnknown(
          data['elevation_gain_m']!,
          _elevationGainMMeta,
        ),
      );
    }
    if (data.containsKey('encoded_polyline')) {
      context.handle(
        _encodedPolylineMeta,
        encodedPolyline.isAcceptableOrUnknown(
          data['encoded_polyline']!,
          _encodedPolylineMeta,
        ),
      );
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    }
    if (data.containsKey('matched_session_id')) {
      context.handle(
        _matchedSessionIdMeta,
        matchedSessionId.isAcceptableOrUnknown(
          data['matched_session_id']!,
          _matchedSessionIdMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RunRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RunRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      )!,
      endedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}ended_at'],
      ),
      distanceM: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}distance_m'],
      )!,
      movingTimeSec: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}moving_time_sec'],
      )!,
      elapsedTimeSec: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}elapsed_time_sec'],
      )!,
      avgPaceSecPerKm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}avg_pace_sec_per_km'],
      ),
      elevationGainM: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}elevation_gain_m'],
      )!,
      encodedPolyline: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}encoded_polyline'],
      ),
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      matchedSessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}matched_session_id'],
      ),
    );
  }

  @override
  $RunsTable createAlias(String alias) {
    return $RunsTable(attachedDatabase, alias);
  }
}

class RunRow extends DataClass implements Insertable<RunRow> {
  final String id;
  final DateTime startedAt;
  final DateTime? endedAt;
  final double distanceM;
  final int movingTimeSec;
  final int elapsedTimeSec;
  final double? avgPaceSecPerKm;
  final double elevationGainM;
  final String? encodedPolyline;
  final String source;
  final String? matchedSessionId;
  const RunRow({
    required this.id,
    required this.startedAt,
    this.endedAt,
    required this.distanceM,
    required this.movingTimeSec,
    required this.elapsedTimeSec,
    this.avgPaceSecPerKm,
    required this.elevationGainM,
    this.encodedPolyline,
    required this.source,
    this.matchedSessionId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['started_at'] = Variable<DateTime>(startedAt);
    if (!nullToAbsent || endedAt != null) {
      map['ended_at'] = Variable<DateTime>(endedAt);
    }
    map['distance_m'] = Variable<double>(distanceM);
    map['moving_time_sec'] = Variable<int>(movingTimeSec);
    map['elapsed_time_sec'] = Variable<int>(elapsedTimeSec);
    if (!nullToAbsent || avgPaceSecPerKm != null) {
      map['avg_pace_sec_per_km'] = Variable<double>(avgPaceSecPerKm);
    }
    map['elevation_gain_m'] = Variable<double>(elevationGainM);
    if (!nullToAbsent || encodedPolyline != null) {
      map['encoded_polyline'] = Variable<String>(encodedPolyline);
    }
    map['source'] = Variable<String>(source);
    if (!nullToAbsent || matchedSessionId != null) {
      map['matched_session_id'] = Variable<String>(matchedSessionId);
    }
    return map;
  }

  RunsCompanion toCompanion(bool nullToAbsent) {
    return RunsCompanion(
      id: Value(id),
      startedAt: Value(startedAt),
      endedAt: endedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(endedAt),
      distanceM: Value(distanceM),
      movingTimeSec: Value(movingTimeSec),
      elapsedTimeSec: Value(elapsedTimeSec),
      avgPaceSecPerKm: avgPaceSecPerKm == null && nullToAbsent
          ? const Value.absent()
          : Value(avgPaceSecPerKm),
      elevationGainM: Value(elevationGainM),
      encodedPolyline: encodedPolyline == null && nullToAbsent
          ? const Value.absent()
          : Value(encodedPolyline),
      source: Value(source),
      matchedSessionId: matchedSessionId == null && nullToAbsent
          ? const Value.absent()
          : Value(matchedSessionId),
    );
  }

  factory RunRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RunRow(
      id: serializer.fromJson<String>(json['id']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      endedAt: serializer.fromJson<DateTime?>(json['endedAt']),
      distanceM: serializer.fromJson<double>(json['distanceM']),
      movingTimeSec: serializer.fromJson<int>(json['movingTimeSec']),
      elapsedTimeSec: serializer.fromJson<int>(json['elapsedTimeSec']),
      avgPaceSecPerKm: serializer.fromJson<double?>(json['avgPaceSecPerKm']),
      elevationGainM: serializer.fromJson<double>(json['elevationGainM']),
      encodedPolyline: serializer.fromJson<String?>(json['encodedPolyline']),
      source: serializer.fromJson<String>(json['source']),
      matchedSessionId: serializer.fromJson<String?>(json['matchedSessionId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'endedAt': serializer.toJson<DateTime?>(endedAt),
      'distanceM': serializer.toJson<double>(distanceM),
      'movingTimeSec': serializer.toJson<int>(movingTimeSec),
      'elapsedTimeSec': serializer.toJson<int>(elapsedTimeSec),
      'avgPaceSecPerKm': serializer.toJson<double?>(avgPaceSecPerKm),
      'elevationGainM': serializer.toJson<double>(elevationGainM),
      'encodedPolyline': serializer.toJson<String?>(encodedPolyline),
      'source': serializer.toJson<String>(source),
      'matchedSessionId': serializer.toJson<String?>(matchedSessionId),
    };
  }

  RunRow copyWith({
    String? id,
    DateTime? startedAt,
    Value<DateTime?> endedAt = const Value.absent(),
    double? distanceM,
    int? movingTimeSec,
    int? elapsedTimeSec,
    Value<double?> avgPaceSecPerKm = const Value.absent(),
    double? elevationGainM,
    Value<String?> encodedPolyline = const Value.absent(),
    String? source,
    Value<String?> matchedSessionId = const Value.absent(),
  }) => RunRow(
    id: id ?? this.id,
    startedAt: startedAt ?? this.startedAt,
    endedAt: endedAt.present ? endedAt.value : this.endedAt,
    distanceM: distanceM ?? this.distanceM,
    movingTimeSec: movingTimeSec ?? this.movingTimeSec,
    elapsedTimeSec: elapsedTimeSec ?? this.elapsedTimeSec,
    avgPaceSecPerKm: avgPaceSecPerKm.present
        ? avgPaceSecPerKm.value
        : this.avgPaceSecPerKm,
    elevationGainM: elevationGainM ?? this.elevationGainM,
    encodedPolyline: encodedPolyline.present
        ? encodedPolyline.value
        : this.encodedPolyline,
    source: source ?? this.source,
    matchedSessionId: matchedSessionId.present
        ? matchedSessionId.value
        : this.matchedSessionId,
  );
  RunRow copyWithCompanion(RunsCompanion data) {
    return RunRow(
      id: data.id.present ? data.id.value : this.id,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      endedAt: data.endedAt.present ? data.endedAt.value : this.endedAt,
      distanceM: data.distanceM.present ? data.distanceM.value : this.distanceM,
      movingTimeSec: data.movingTimeSec.present
          ? data.movingTimeSec.value
          : this.movingTimeSec,
      elapsedTimeSec: data.elapsedTimeSec.present
          ? data.elapsedTimeSec.value
          : this.elapsedTimeSec,
      avgPaceSecPerKm: data.avgPaceSecPerKm.present
          ? data.avgPaceSecPerKm.value
          : this.avgPaceSecPerKm,
      elevationGainM: data.elevationGainM.present
          ? data.elevationGainM.value
          : this.elevationGainM,
      encodedPolyline: data.encodedPolyline.present
          ? data.encodedPolyline.value
          : this.encodedPolyline,
      source: data.source.present ? data.source.value : this.source,
      matchedSessionId: data.matchedSessionId.present
          ? data.matchedSessionId.value
          : this.matchedSessionId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RunRow(')
          ..write('id: $id, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('distanceM: $distanceM, ')
          ..write('movingTimeSec: $movingTimeSec, ')
          ..write('elapsedTimeSec: $elapsedTimeSec, ')
          ..write('avgPaceSecPerKm: $avgPaceSecPerKm, ')
          ..write('elevationGainM: $elevationGainM, ')
          ..write('encodedPolyline: $encodedPolyline, ')
          ..write('source: $source, ')
          ..write('matchedSessionId: $matchedSessionId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    startedAt,
    endedAt,
    distanceM,
    movingTimeSec,
    elapsedTimeSec,
    avgPaceSecPerKm,
    elevationGainM,
    encodedPolyline,
    source,
    matchedSessionId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RunRow &&
          other.id == this.id &&
          other.startedAt == this.startedAt &&
          other.endedAt == this.endedAt &&
          other.distanceM == this.distanceM &&
          other.movingTimeSec == this.movingTimeSec &&
          other.elapsedTimeSec == this.elapsedTimeSec &&
          other.avgPaceSecPerKm == this.avgPaceSecPerKm &&
          other.elevationGainM == this.elevationGainM &&
          other.encodedPolyline == this.encodedPolyline &&
          other.source == this.source &&
          other.matchedSessionId == this.matchedSessionId);
}

class RunsCompanion extends UpdateCompanion<RunRow> {
  final Value<String> id;
  final Value<DateTime> startedAt;
  final Value<DateTime?> endedAt;
  final Value<double> distanceM;
  final Value<int> movingTimeSec;
  final Value<int> elapsedTimeSec;
  final Value<double?> avgPaceSecPerKm;
  final Value<double> elevationGainM;
  final Value<String?> encodedPolyline;
  final Value<String> source;
  final Value<String?> matchedSessionId;
  final Value<int> rowid;
  const RunsCompanion({
    this.id = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.endedAt = const Value.absent(),
    this.distanceM = const Value.absent(),
    this.movingTimeSec = const Value.absent(),
    this.elapsedTimeSec = const Value.absent(),
    this.avgPaceSecPerKm = const Value.absent(),
    this.elevationGainM = const Value.absent(),
    this.encodedPolyline = const Value.absent(),
    this.source = const Value.absent(),
    this.matchedSessionId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RunsCompanion.insert({
    required String id,
    required DateTime startedAt,
    this.endedAt = const Value.absent(),
    this.distanceM = const Value.absent(),
    this.movingTimeSec = const Value.absent(),
    this.elapsedTimeSec = const Value.absent(),
    this.avgPaceSecPerKm = const Value.absent(),
    this.elevationGainM = const Value.absent(),
    this.encodedPolyline = const Value.absent(),
    this.source = const Value.absent(),
    this.matchedSessionId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       startedAt = Value(startedAt);
  static Insertable<RunRow> custom({
    Expression<String>? id,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? endedAt,
    Expression<double>? distanceM,
    Expression<int>? movingTimeSec,
    Expression<int>? elapsedTimeSec,
    Expression<double>? avgPaceSecPerKm,
    Expression<double>? elevationGainM,
    Expression<String>? encodedPolyline,
    Expression<String>? source,
    Expression<String>? matchedSessionId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (startedAt != null) 'started_at': startedAt,
      if (endedAt != null) 'ended_at': endedAt,
      if (distanceM != null) 'distance_m': distanceM,
      if (movingTimeSec != null) 'moving_time_sec': movingTimeSec,
      if (elapsedTimeSec != null) 'elapsed_time_sec': elapsedTimeSec,
      if (avgPaceSecPerKm != null) 'avg_pace_sec_per_km': avgPaceSecPerKm,
      if (elevationGainM != null) 'elevation_gain_m': elevationGainM,
      if (encodedPolyline != null) 'encoded_polyline': encodedPolyline,
      if (source != null) 'source': source,
      if (matchedSessionId != null) 'matched_session_id': matchedSessionId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RunsCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? startedAt,
    Value<DateTime?>? endedAt,
    Value<double>? distanceM,
    Value<int>? movingTimeSec,
    Value<int>? elapsedTimeSec,
    Value<double?>? avgPaceSecPerKm,
    Value<double>? elevationGainM,
    Value<String?>? encodedPolyline,
    Value<String>? source,
    Value<String?>? matchedSessionId,
    Value<int>? rowid,
  }) {
    return RunsCompanion(
      id: id ?? this.id,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      distanceM: distanceM ?? this.distanceM,
      movingTimeSec: movingTimeSec ?? this.movingTimeSec,
      elapsedTimeSec: elapsedTimeSec ?? this.elapsedTimeSec,
      avgPaceSecPerKm: avgPaceSecPerKm ?? this.avgPaceSecPerKm,
      elevationGainM: elevationGainM ?? this.elevationGainM,
      encodedPolyline: encodedPolyline ?? this.encodedPolyline,
      source: source ?? this.source,
      matchedSessionId: matchedSessionId ?? this.matchedSessionId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (endedAt.present) {
      map['ended_at'] = Variable<DateTime>(endedAt.value);
    }
    if (distanceM.present) {
      map['distance_m'] = Variable<double>(distanceM.value);
    }
    if (movingTimeSec.present) {
      map['moving_time_sec'] = Variable<int>(movingTimeSec.value);
    }
    if (elapsedTimeSec.present) {
      map['elapsed_time_sec'] = Variable<int>(elapsedTimeSec.value);
    }
    if (avgPaceSecPerKm.present) {
      map['avg_pace_sec_per_km'] = Variable<double>(avgPaceSecPerKm.value);
    }
    if (elevationGainM.present) {
      map['elevation_gain_m'] = Variable<double>(elevationGainM.value);
    }
    if (encodedPolyline.present) {
      map['encoded_polyline'] = Variable<String>(encodedPolyline.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (matchedSessionId.present) {
      map['matched_session_id'] = Variable<String>(matchedSessionId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RunsCompanion(')
          ..write('id: $id, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('distanceM: $distanceM, ')
          ..write('movingTimeSec: $movingTimeSec, ')
          ..write('elapsedTimeSec: $elapsedTimeSec, ')
          ..write('avgPaceSecPerKm: $avgPaceSecPerKm, ')
          ..write('elevationGainM: $elevationGainM, ')
          ..write('encodedPolyline: $encodedPolyline, ')
          ..write('source: $source, ')
          ..write('matchedSessionId: $matchedSessionId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RunSamplesTable extends RunSamples
    with TableInfo<$RunSamplesTable, RunSampleRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RunSamplesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _runIdMeta = const VerificationMeta('runId');
  @override
  late final GeneratedColumn<String> runId = GeneratedColumn<String>(
    'run_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tOffsetMsMeta = const VerificationMeta(
    'tOffsetMs',
  );
  @override
  late final GeneratedColumn<int> tOffsetMs = GeneratedColumn<int>(
    't_offset_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _latMeta = const VerificationMeta('lat');
  @override
  late final GeneratedColumn<double> lat = GeneratedColumn<double>(
    'lat',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lonMeta = const VerificationMeta('lon');
  @override
  late final GeneratedColumn<double> lon = GeneratedColumn<double>(
    'lon',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _elevationMMeta = const VerificationMeta(
    'elevationM',
  );
  @override
  late final GeneratedColumn<double> elevationM = GeneratedColumn<double>(
    'elevation_m',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _instantSpeedMpsMeta = const VerificationMeta(
    'instantSpeedMps',
  );
  @override
  late final GeneratedColumn<double> instantSpeedMps = GeneratedColumn<double>(
    'instant_speed_mps',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    runId,
    tOffsetMs,
    lat,
    lon,
    elevationM,
    instantSpeedMps,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'run_samples';
  @override
  VerificationContext validateIntegrity(
    Insertable<RunSampleRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('run_id')) {
      context.handle(
        _runIdMeta,
        runId.isAcceptableOrUnknown(data['run_id']!, _runIdMeta),
      );
    } else if (isInserting) {
      context.missing(_runIdMeta);
    }
    if (data.containsKey('t_offset_ms')) {
      context.handle(
        _tOffsetMsMeta,
        tOffsetMs.isAcceptableOrUnknown(data['t_offset_ms']!, _tOffsetMsMeta),
      );
    } else if (isInserting) {
      context.missing(_tOffsetMsMeta);
    }
    if (data.containsKey('lat')) {
      context.handle(
        _latMeta,
        lat.isAcceptableOrUnknown(data['lat']!, _latMeta),
      );
    } else if (isInserting) {
      context.missing(_latMeta);
    }
    if (data.containsKey('lon')) {
      context.handle(
        _lonMeta,
        lon.isAcceptableOrUnknown(data['lon']!, _lonMeta),
      );
    } else if (isInserting) {
      context.missing(_lonMeta);
    }
    if (data.containsKey('elevation_m')) {
      context.handle(
        _elevationMMeta,
        elevationM.isAcceptableOrUnknown(data['elevation_m']!, _elevationMMeta),
      );
    }
    if (data.containsKey('instant_speed_mps')) {
      context.handle(
        _instantSpeedMpsMeta,
        instantSpeedMps.isAcceptableOrUnknown(
          data['instant_speed_mps']!,
          _instantSpeedMpsMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {runId, tOffsetMs};
  @override
  RunSampleRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RunSampleRow(
      runId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}run_id'],
      )!,
      tOffsetMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}t_offset_ms'],
      )!,
      lat: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}lat'],
      )!,
      lon: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}lon'],
      )!,
      elevationM: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}elevation_m'],
      ),
      instantSpeedMps: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}instant_speed_mps'],
      ),
    );
  }

  @override
  $RunSamplesTable createAlias(String alias) {
    return $RunSamplesTable(attachedDatabase, alias);
  }
}

class RunSampleRow extends DataClass implements Insertable<RunSampleRow> {
  final String runId;
  final int tOffsetMs;
  final double lat;
  final double lon;
  final double? elevationM;
  final double? instantSpeedMps;
  const RunSampleRow({
    required this.runId,
    required this.tOffsetMs,
    required this.lat,
    required this.lon,
    this.elevationM,
    this.instantSpeedMps,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['run_id'] = Variable<String>(runId);
    map['t_offset_ms'] = Variable<int>(tOffsetMs);
    map['lat'] = Variable<double>(lat);
    map['lon'] = Variable<double>(lon);
    if (!nullToAbsent || elevationM != null) {
      map['elevation_m'] = Variable<double>(elevationM);
    }
    if (!nullToAbsent || instantSpeedMps != null) {
      map['instant_speed_mps'] = Variable<double>(instantSpeedMps);
    }
    return map;
  }

  RunSamplesCompanion toCompanion(bool nullToAbsent) {
    return RunSamplesCompanion(
      runId: Value(runId),
      tOffsetMs: Value(tOffsetMs),
      lat: Value(lat),
      lon: Value(lon),
      elevationM: elevationM == null && nullToAbsent
          ? const Value.absent()
          : Value(elevationM),
      instantSpeedMps: instantSpeedMps == null && nullToAbsent
          ? const Value.absent()
          : Value(instantSpeedMps),
    );
  }

  factory RunSampleRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RunSampleRow(
      runId: serializer.fromJson<String>(json['runId']),
      tOffsetMs: serializer.fromJson<int>(json['tOffsetMs']),
      lat: serializer.fromJson<double>(json['lat']),
      lon: serializer.fromJson<double>(json['lon']),
      elevationM: serializer.fromJson<double?>(json['elevationM']),
      instantSpeedMps: serializer.fromJson<double?>(json['instantSpeedMps']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'runId': serializer.toJson<String>(runId),
      'tOffsetMs': serializer.toJson<int>(tOffsetMs),
      'lat': serializer.toJson<double>(lat),
      'lon': serializer.toJson<double>(lon),
      'elevationM': serializer.toJson<double?>(elevationM),
      'instantSpeedMps': serializer.toJson<double?>(instantSpeedMps),
    };
  }

  RunSampleRow copyWith({
    String? runId,
    int? tOffsetMs,
    double? lat,
    double? lon,
    Value<double?> elevationM = const Value.absent(),
    Value<double?> instantSpeedMps = const Value.absent(),
  }) => RunSampleRow(
    runId: runId ?? this.runId,
    tOffsetMs: tOffsetMs ?? this.tOffsetMs,
    lat: lat ?? this.lat,
    lon: lon ?? this.lon,
    elevationM: elevationM.present ? elevationM.value : this.elevationM,
    instantSpeedMps: instantSpeedMps.present
        ? instantSpeedMps.value
        : this.instantSpeedMps,
  );
  RunSampleRow copyWithCompanion(RunSamplesCompanion data) {
    return RunSampleRow(
      runId: data.runId.present ? data.runId.value : this.runId,
      tOffsetMs: data.tOffsetMs.present ? data.tOffsetMs.value : this.tOffsetMs,
      lat: data.lat.present ? data.lat.value : this.lat,
      lon: data.lon.present ? data.lon.value : this.lon,
      elevationM: data.elevationM.present
          ? data.elevationM.value
          : this.elevationM,
      instantSpeedMps: data.instantSpeedMps.present
          ? data.instantSpeedMps.value
          : this.instantSpeedMps,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RunSampleRow(')
          ..write('runId: $runId, ')
          ..write('tOffsetMs: $tOffsetMs, ')
          ..write('lat: $lat, ')
          ..write('lon: $lon, ')
          ..write('elevationM: $elevationM, ')
          ..write('instantSpeedMps: $instantSpeedMps')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(runId, tOffsetMs, lat, lon, elevationM, instantSpeedMps);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RunSampleRow &&
          other.runId == this.runId &&
          other.tOffsetMs == this.tOffsetMs &&
          other.lat == this.lat &&
          other.lon == this.lon &&
          other.elevationM == this.elevationM &&
          other.instantSpeedMps == this.instantSpeedMps);
}

class RunSamplesCompanion extends UpdateCompanion<RunSampleRow> {
  final Value<String> runId;
  final Value<int> tOffsetMs;
  final Value<double> lat;
  final Value<double> lon;
  final Value<double?> elevationM;
  final Value<double?> instantSpeedMps;
  final Value<int> rowid;
  const RunSamplesCompanion({
    this.runId = const Value.absent(),
    this.tOffsetMs = const Value.absent(),
    this.lat = const Value.absent(),
    this.lon = const Value.absent(),
    this.elevationM = const Value.absent(),
    this.instantSpeedMps = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RunSamplesCompanion.insert({
    required String runId,
    required int tOffsetMs,
    required double lat,
    required double lon,
    this.elevationM = const Value.absent(),
    this.instantSpeedMps = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : runId = Value(runId),
       tOffsetMs = Value(tOffsetMs),
       lat = Value(lat),
       lon = Value(lon);
  static Insertable<RunSampleRow> custom({
    Expression<String>? runId,
    Expression<int>? tOffsetMs,
    Expression<double>? lat,
    Expression<double>? lon,
    Expression<double>? elevationM,
    Expression<double>? instantSpeedMps,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (runId != null) 'run_id': runId,
      if (tOffsetMs != null) 't_offset_ms': tOffsetMs,
      if (lat != null) 'lat': lat,
      if (lon != null) 'lon': lon,
      if (elevationM != null) 'elevation_m': elevationM,
      if (instantSpeedMps != null) 'instant_speed_mps': instantSpeedMps,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RunSamplesCompanion copyWith({
    Value<String>? runId,
    Value<int>? tOffsetMs,
    Value<double>? lat,
    Value<double>? lon,
    Value<double?>? elevationM,
    Value<double?>? instantSpeedMps,
    Value<int>? rowid,
  }) {
    return RunSamplesCompanion(
      runId: runId ?? this.runId,
      tOffsetMs: tOffsetMs ?? this.tOffsetMs,
      lat: lat ?? this.lat,
      lon: lon ?? this.lon,
      elevationM: elevationM ?? this.elevationM,
      instantSpeedMps: instantSpeedMps ?? this.instantSpeedMps,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (runId.present) {
      map['run_id'] = Variable<String>(runId.value);
    }
    if (tOffsetMs.present) {
      map['t_offset_ms'] = Variable<int>(tOffsetMs.value);
    }
    if (lat.present) {
      map['lat'] = Variable<double>(lat.value);
    }
    if (lon.present) {
      map['lon'] = Variable<double>(lon.value);
    }
    if (elevationM.present) {
      map['elevation_m'] = Variable<double>(elevationM.value);
    }
    if (instantSpeedMps.present) {
      map['instant_speed_mps'] = Variable<double>(instantSpeedMps.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RunSamplesCompanion(')
          ..write('runId: $runId, ')
          ..write('tOffsetMs: $tOffsetMs, ')
          ..write('lat: $lat, ')
          ..write('lon: $lon, ')
          ..write('elevationM: $elevationM, ')
          ..write('instantSpeedMps: $instantSpeedMps, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PlansTable extends Plans with TableInfo<$PlansTable, PlanRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlansTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startsOnMeta = const VerificationMeta(
    'startsOn',
  );
  @override
  late final GeneratedColumn<DateTime> startsOn = GeneratedColumn<DateTime>(
    'starts_on',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetMarathonDateMeta =
      const VerificationMeta('targetMarathonDate');
  @override
  late final GeneratedColumn<DateTime> targetMarathonDate =
      GeneratedColumn<DateTime>(
        'target_marathon_date',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _totalWeeksMeta = const VerificationMeta(
    'totalWeeks',
  );
  @override
  late final GeneratedColumn<int> totalWeeks = GeneratedColumn<int>(
    'total_weeks',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startVdotMeta = const VerificationMeta(
    'startVdot',
  );
  @override
  late final GeneratedColumn<double> startVdot = GeneratedColumn<double>(
    'start_vdot',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetVdotMeta = const VerificationMeta(
    'targetVdot',
  );
  @override
  late final GeneratedColumn<double> targetVdot = GeneratedColumn<double>(
    'target_vdot',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    startsOn,
    targetMarathonDate,
    totalWeeks,
    startVdot,
    targetVdot,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'plans';
  @override
  VerificationContext validateIntegrity(
    Insertable<PlanRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('starts_on')) {
      context.handle(
        _startsOnMeta,
        startsOn.isAcceptableOrUnknown(data['starts_on']!, _startsOnMeta),
      );
    } else if (isInserting) {
      context.missing(_startsOnMeta);
    }
    if (data.containsKey('target_marathon_date')) {
      context.handle(
        _targetMarathonDateMeta,
        targetMarathonDate.isAcceptableOrUnknown(
          data['target_marathon_date']!,
          _targetMarathonDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_targetMarathonDateMeta);
    }
    if (data.containsKey('total_weeks')) {
      context.handle(
        _totalWeeksMeta,
        totalWeeks.isAcceptableOrUnknown(data['total_weeks']!, _totalWeeksMeta),
      );
    } else if (isInserting) {
      context.missing(_totalWeeksMeta);
    }
    if (data.containsKey('start_vdot')) {
      context.handle(
        _startVdotMeta,
        startVdot.isAcceptableOrUnknown(data['start_vdot']!, _startVdotMeta),
      );
    } else if (isInserting) {
      context.missing(_startVdotMeta);
    }
    if (data.containsKey('target_vdot')) {
      context.handle(
        _targetVdotMeta,
        targetVdot.isAcceptableOrUnknown(data['target_vdot']!, _targetVdotMeta),
      );
    } else if (isInserting) {
      context.missing(_targetVdotMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PlanRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlanRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      startsOn: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}starts_on'],
      )!,
      targetMarathonDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}target_marathon_date'],
      )!,
      totalWeeks: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_weeks'],
      )!,
      startVdot: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}start_vdot'],
      )!,
      targetVdot: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}target_vdot'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $PlansTable createAlias(String alias) {
    return $PlansTable(attachedDatabase, alias);
  }
}

class PlanRow extends DataClass implements Insertable<PlanRow> {
  final String id;
  final String userId;
  final DateTime startsOn;
  final DateTime targetMarathonDate;
  final int totalWeeks;
  final double startVdot;
  final double targetVdot;
  final DateTime createdAt;
  const PlanRow({
    required this.id,
    required this.userId,
    required this.startsOn,
    required this.targetMarathonDate,
    required this.totalWeeks,
    required this.startVdot,
    required this.targetVdot,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['starts_on'] = Variable<DateTime>(startsOn);
    map['target_marathon_date'] = Variable<DateTime>(targetMarathonDate);
    map['total_weeks'] = Variable<int>(totalWeeks);
    map['start_vdot'] = Variable<double>(startVdot);
    map['target_vdot'] = Variable<double>(targetVdot);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  PlansCompanion toCompanion(bool nullToAbsent) {
    return PlansCompanion(
      id: Value(id),
      userId: Value(userId),
      startsOn: Value(startsOn),
      targetMarathonDate: Value(targetMarathonDate),
      totalWeeks: Value(totalWeeks),
      startVdot: Value(startVdot),
      targetVdot: Value(targetVdot),
      createdAt: Value(createdAt),
    );
  }

  factory PlanRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlanRow(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      startsOn: serializer.fromJson<DateTime>(json['startsOn']),
      targetMarathonDate: serializer.fromJson<DateTime>(
        json['targetMarathonDate'],
      ),
      totalWeeks: serializer.fromJson<int>(json['totalWeeks']),
      startVdot: serializer.fromJson<double>(json['startVdot']),
      targetVdot: serializer.fromJson<double>(json['targetVdot']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'startsOn': serializer.toJson<DateTime>(startsOn),
      'targetMarathonDate': serializer.toJson<DateTime>(targetMarathonDate),
      'totalWeeks': serializer.toJson<int>(totalWeeks),
      'startVdot': serializer.toJson<double>(startVdot),
      'targetVdot': serializer.toJson<double>(targetVdot),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  PlanRow copyWith({
    String? id,
    String? userId,
    DateTime? startsOn,
    DateTime? targetMarathonDate,
    int? totalWeeks,
    double? startVdot,
    double? targetVdot,
    DateTime? createdAt,
  }) => PlanRow(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    startsOn: startsOn ?? this.startsOn,
    targetMarathonDate: targetMarathonDate ?? this.targetMarathonDate,
    totalWeeks: totalWeeks ?? this.totalWeeks,
    startVdot: startVdot ?? this.startVdot,
    targetVdot: targetVdot ?? this.targetVdot,
    createdAt: createdAt ?? this.createdAt,
  );
  PlanRow copyWithCompanion(PlansCompanion data) {
    return PlanRow(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      startsOn: data.startsOn.present ? data.startsOn.value : this.startsOn,
      targetMarathonDate: data.targetMarathonDate.present
          ? data.targetMarathonDate.value
          : this.targetMarathonDate,
      totalWeeks: data.totalWeeks.present
          ? data.totalWeeks.value
          : this.totalWeeks,
      startVdot: data.startVdot.present ? data.startVdot.value : this.startVdot,
      targetVdot: data.targetVdot.present
          ? data.targetVdot.value
          : this.targetVdot,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlanRow(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('startsOn: $startsOn, ')
          ..write('targetMarathonDate: $targetMarathonDate, ')
          ..write('totalWeeks: $totalWeeks, ')
          ..write('startVdot: $startVdot, ')
          ..write('targetVdot: $targetVdot, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    startsOn,
    targetMarathonDate,
    totalWeeks,
    startVdot,
    targetVdot,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlanRow &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.startsOn == this.startsOn &&
          other.targetMarathonDate == this.targetMarathonDate &&
          other.totalWeeks == this.totalWeeks &&
          other.startVdot == this.startVdot &&
          other.targetVdot == this.targetVdot &&
          other.createdAt == this.createdAt);
}

class PlansCompanion extends UpdateCompanion<PlanRow> {
  final Value<String> id;
  final Value<String> userId;
  final Value<DateTime> startsOn;
  final Value<DateTime> targetMarathonDate;
  final Value<int> totalWeeks;
  final Value<double> startVdot;
  final Value<double> targetVdot;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const PlansCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.startsOn = const Value.absent(),
    this.targetMarathonDate = const Value.absent(),
    this.totalWeeks = const Value.absent(),
    this.startVdot = const Value.absent(),
    this.targetVdot = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PlansCompanion.insert({
    required String id,
    required String userId,
    required DateTime startsOn,
    required DateTime targetMarathonDate,
    required int totalWeeks,
    required double startVdot,
    required double targetVdot,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       startsOn = Value(startsOn),
       targetMarathonDate = Value(targetMarathonDate),
       totalWeeks = Value(totalWeeks),
       startVdot = Value(startVdot),
       targetVdot = Value(targetVdot),
       createdAt = Value(createdAt);
  static Insertable<PlanRow> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<DateTime>? startsOn,
    Expression<DateTime>? targetMarathonDate,
    Expression<int>? totalWeeks,
    Expression<double>? startVdot,
    Expression<double>? targetVdot,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (startsOn != null) 'starts_on': startsOn,
      if (targetMarathonDate != null)
        'target_marathon_date': targetMarathonDate,
      if (totalWeeks != null) 'total_weeks': totalWeeks,
      if (startVdot != null) 'start_vdot': startVdot,
      if (targetVdot != null) 'target_vdot': targetVdot,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PlansCompanion copyWith({
    Value<String>? id,
    Value<String>? userId,
    Value<DateTime>? startsOn,
    Value<DateTime>? targetMarathonDate,
    Value<int>? totalWeeks,
    Value<double>? startVdot,
    Value<double>? targetVdot,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return PlansCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      startsOn: startsOn ?? this.startsOn,
      targetMarathonDate: targetMarathonDate ?? this.targetMarathonDate,
      totalWeeks: totalWeeks ?? this.totalWeeks,
      startVdot: startVdot ?? this.startVdot,
      targetVdot: targetVdot ?? this.targetVdot,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (startsOn.present) {
      map['starts_on'] = Variable<DateTime>(startsOn.value);
    }
    if (targetMarathonDate.present) {
      map['target_marathon_date'] = Variable<DateTime>(
        targetMarathonDate.value,
      );
    }
    if (totalWeeks.present) {
      map['total_weeks'] = Variable<int>(totalWeeks.value);
    }
    if (startVdot.present) {
      map['start_vdot'] = Variable<double>(startVdot.value);
    }
    if (targetVdot.present) {
      map['target_vdot'] = Variable<double>(targetVdot.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlansCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('startsOn: $startsOn, ')
          ..write('targetMarathonDate: $targetMarathonDate, ')
          ..write('totalWeeks: $totalWeeks, ')
          ..write('startVdot: $startVdot, ')
          ..write('targetVdot: $targetVdot, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PlanSessionsTableTable extends PlanSessionsTable
    with TableInfo<$PlanSessionsTableTable, PlanSessionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlanSessionsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _planIdMeta = const VerificationMeta('planId');
  @override
  late final GeneratedColumn<String> planId = GeneratedColumn<String>(
    'plan_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _scheduledDateMeta = const VerificationMeta(
    'scheduledDate',
  );
  @override
  late final GeneratedColumn<DateTime> scheduledDate =
      GeneratedColumn<DateTime>(
        'scheduled_date',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _weekNumberMeta = const VerificationMeta(
    'weekNumber',
  );
  @override
  late final GeneratedColumn<int> weekNumber = GeneratedColumn<int>(
    'week_number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dayOfWeekMeta = const VerificationMeta(
    'dayOfWeek',
  );
  @override
  late final GeneratedColumn<int> dayOfWeek = GeneratedColumn<int>(
    'day_of_week',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _prescribedDistanceKmMeta =
      const VerificationMeta('prescribedDistanceKm');
  @override
  late final GeneratedColumn<double> prescribedDistanceKm =
      GeneratedColumn<double>(
        'prescribed_distance_km',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _prescribedPaceSecPerKmMeta =
      const VerificationMeta('prescribedPaceSecPerKm');
  @override
  late final GeneratedColumn<double> prescribedPaceSecPerKm =
      GeneratedColumn<double>(
        'prescribed_pace_sec_per_km',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _matchedRunIdMeta = const VerificationMeta(
    'matchedRunId',
  );
  @override
  late final GeneratedColumn<String> matchedRunId = GeneratedColumn<String>(
    'matched_run_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    planId,
    scheduledDate,
    weekNumber,
    dayOfWeek,
    type,
    prescribedDistanceKm,
    prescribedPaceSecPerKm,
    notes,
    status,
    matchedRunId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'plan_sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<PlanSessionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('plan_id')) {
      context.handle(
        _planIdMeta,
        planId.isAcceptableOrUnknown(data['plan_id']!, _planIdMeta),
      );
    } else if (isInserting) {
      context.missing(_planIdMeta);
    }
    if (data.containsKey('scheduled_date')) {
      context.handle(
        _scheduledDateMeta,
        scheduledDate.isAcceptableOrUnknown(
          data['scheduled_date']!,
          _scheduledDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_scheduledDateMeta);
    }
    if (data.containsKey('week_number')) {
      context.handle(
        _weekNumberMeta,
        weekNumber.isAcceptableOrUnknown(data['week_number']!, _weekNumberMeta),
      );
    } else if (isInserting) {
      context.missing(_weekNumberMeta);
    }
    if (data.containsKey('day_of_week')) {
      context.handle(
        _dayOfWeekMeta,
        dayOfWeek.isAcceptableOrUnknown(data['day_of_week']!, _dayOfWeekMeta),
      );
    } else if (isInserting) {
      context.missing(_dayOfWeekMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('prescribed_distance_km')) {
      context.handle(
        _prescribedDistanceKmMeta,
        prescribedDistanceKm.isAcceptableOrUnknown(
          data['prescribed_distance_km']!,
          _prescribedDistanceKmMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_prescribedDistanceKmMeta);
    }
    if (data.containsKey('prescribed_pace_sec_per_km')) {
      context.handle(
        _prescribedPaceSecPerKmMeta,
        prescribedPaceSecPerKm.isAcceptableOrUnknown(
          data['prescribed_pace_sec_per_km']!,
          _prescribedPaceSecPerKmMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('matched_run_id')) {
      context.handle(
        _matchedRunIdMeta,
        matchedRunId.isAcceptableOrUnknown(
          data['matched_run_id']!,
          _matchedRunIdMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PlanSessionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlanSessionRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      planId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}plan_id'],
      )!,
      scheduledDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}scheduled_date'],
      )!,
      weekNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}week_number'],
      )!,
      dayOfWeek: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}day_of_week'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      prescribedDistanceKm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}prescribed_distance_km'],
      )!,
      prescribedPaceSecPerKm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}prescribed_pace_sec_per_km'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      matchedRunId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}matched_run_id'],
      ),
    );
  }

  @override
  $PlanSessionsTableTable createAlias(String alias) {
    return $PlanSessionsTableTable(attachedDatabase, alias);
  }
}

class PlanSessionRow extends DataClass implements Insertable<PlanSessionRow> {
  final String id;
  final String planId;
  final DateTime scheduledDate;
  final int weekNumber;
  final int dayOfWeek;
  final String type;
  final double prescribedDistanceKm;
  final double? prescribedPaceSecPerKm;
  final String? notes;
  final String status;
  final String? matchedRunId;
  const PlanSessionRow({
    required this.id,
    required this.planId,
    required this.scheduledDate,
    required this.weekNumber,
    required this.dayOfWeek,
    required this.type,
    required this.prescribedDistanceKm,
    this.prescribedPaceSecPerKm,
    this.notes,
    required this.status,
    this.matchedRunId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['plan_id'] = Variable<String>(planId);
    map['scheduled_date'] = Variable<DateTime>(scheduledDate);
    map['week_number'] = Variable<int>(weekNumber);
    map['day_of_week'] = Variable<int>(dayOfWeek);
    map['type'] = Variable<String>(type);
    map['prescribed_distance_km'] = Variable<double>(prescribedDistanceKm);
    if (!nullToAbsent || prescribedPaceSecPerKm != null) {
      map['prescribed_pace_sec_per_km'] = Variable<double>(
        prescribedPaceSecPerKm,
      );
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || matchedRunId != null) {
      map['matched_run_id'] = Variable<String>(matchedRunId);
    }
    return map;
  }

  PlanSessionsTableCompanion toCompanion(bool nullToAbsent) {
    return PlanSessionsTableCompanion(
      id: Value(id),
      planId: Value(planId),
      scheduledDate: Value(scheduledDate),
      weekNumber: Value(weekNumber),
      dayOfWeek: Value(dayOfWeek),
      type: Value(type),
      prescribedDistanceKm: Value(prescribedDistanceKm),
      prescribedPaceSecPerKm: prescribedPaceSecPerKm == null && nullToAbsent
          ? const Value.absent()
          : Value(prescribedPaceSecPerKm),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      status: Value(status),
      matchedRunId: matchedRunId == null && nullToAbsent
          ? const Value.absent()
          : Value(matchedRunId),
    );
  }

  factory PlanSessionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlanSessionRow(
      id: serializer.fromJson<String>(json['id']),
      planId: serializer.fromJson<String>(json['planId']),
      scheduledDate: serializer.fromJson<DateTime>(json['scheduledDate']),
      weekNumber: serializer.fromJson<int>(json['weekNumber']),
      dayOfWeek: serializer.fromJson<int>(json['dayOfWeek']),
      type: serializer.fromJson<String>(json['type']),
      prescribedDistanceKm: serializer.fromJson<double>(
        json['prescribedDistanceKm'],
      ),
      prescribedPaceSecPerKm: serializer.fromJson<double?>(
        json['prescribedPaceSecPerKm'],
      ),
      notes: serializer.fromJson<String?>(json['notes']),
      status: serializer.fromJson<String>(json['status']),
      matchedRunId: serializer.fromJson<String?>(json['matchedRunId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'planId': serializer.toJson<String>(planId),
      'scheduledDate': serializer.toJson<DateTime>(scheduledDate),
      'weekNumber': serializer.toJson<int>(weekNumber),
      'dayOfWeek': serializer.toJson<int>(dayOfWeek),
      'type': serializer.toJson<String>(type),
      'prescribedDistanceKm': serializer.toJson<double>(prescribedDistanceKm),
      'prescribedPaceSecPerKm': serializer.toJson<double?>(
        prescribedPaceSecPerKm,
      ),
      'notes': serializer.toJson<String?>(notes),
      'status': serializer.toJson<String>(status),
      'matchedRunId': serializer.toJson<String?>(matchedRunId),
    };
  }

  PlanSessionRow copyWith({
    String? id,
    String? planId,
    DateTime? scheduledDate,
    int? weekNumber,
    int? dayOfWeek,
    String? type,
    double? prescribedDistanceKm,
    Value<double?> prescribedPaceSecPerKm = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    String? status,
    Value<String?> matchedRunId = const Value.absent(),
  }) => PlanSessionRow(
    id: id ?? this.id,
    planId: planId ?? this.planId,
    scheduledDate: scheduledDate ?? this.scheduledDate,
    weekNumber: weekNumber ?? this.weekNumber,
    dayOfWeek: dayOfWeek ?? this.dayOfWeek,
    type: type ?? this.type,
    prescribedDistanceKm: prescribedDistanceKm ?? this.prescribedDistanceKm,
    prescribedPaceSecPerKm: prescribedPaceSecPerKm.present
        ? prescribedPaceSecPerKm.value
        : this.prescribedPaceSecPerKm,
    notes: notes.present ? notes.value : this.notes,
    status: status ?? this.status,
    matchedRunId: matchedRunId.present ? matchedRunId.value : this.matchedRunId,
  );
  PlanSessionRow copyWithCompanion(PlanSessionsTableCompanion data) {
    return PlanSessionRow(
      id: data.id.present ? data.id.value : this.id,
      planId: data.planId.present ? data.planId.value : this.planId,
      scheduledDate: data.scheduledDate.present
          ? data.scheduledDate.value
          : this.scheduledDate,
      weekNumber: data.weekNumber.present
          ? data.weekNumber.value
          : this.weekNumber,
      dayOfWeek: data.dayOfWeek.present ? data.dayOfWeek.value : this.dayOfWeek,
      type: data.type.present ? data.type.value : this.type,
      prescribedDistanceKm: data.prescribedDistanceKm.present
          ? data.prescribedDistanceKm.value
          : this.prescribedDistanceKm,
      prescribedPaceSecPerKm: data.prescribedPaceSecPerKm.present
          ? data.prescribedPaceSecPerKm.value
          : this.prescribedPaceSecPerKm,
      notes: data.notes.present ? data.notes.value : this.notes,
      status: data.status.present ? data.status.value : this.status,
      matchedRunId: data.matchedRunId.present
          ? data.matchedRunId.value
          : this.matchedRunId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlanSessionRow(')
          ..write('id: $id, ')
          ..write('planId: $planId, ')
          ..write('scheduledDate: $scheduledDate, ')
          ..write('weekNumber: $weekNumber, ')
          ..write('dayOfWeek: $dayOfWeek, ')
          ..write('type: $type, ')
          ..write('prescribedDistanceKm: $prescribedDistanceKm, ')
          ..write('prescribedPaceSecPerKm: $prescribedPaceSecPerKm, ')
          ..write('notes: $notes, ')
          ..write('status: $status, ')
          ..write('matchedRunId: $matchedRunId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    planId,
    scheduledDate,
    weekNumber,
    dayOfWeek,
    type,
    prescribedDistanceKm,
    prescribedPaceSecPerKm,
    notes,
    status,
    matchedRunId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlanSessionRow &&
          other.id == this.id &&
          other.planId == this.planId &&
          other.scheduledDate == this.scheduledDate &&
          other.weekNumber == this.weekNumber &&
          other.dayOfWeek == this.dayOfWeek &&
          other.type == this.type &&
          other.prescribedDistanceKm == this.prescribedDistanceKm &&
          other.prescribedPaceSecPerKm == this.prescribedPaceSecPerKm &&
          other.notes == this.notes &&
          other.status == this.status &&
          other.matchedRunId == this.matchedRunId);
}

class PlanSessionsTableCompanion extends UpdateCompanion<PlanSessionRow> {
  final Value<String> id;
  final Value<String> planId;
  final Value<DateTime> scheduledDate;
  final Value<int> weekNumber;
  final Value<int> dayOfWeek;
  final Value<String> type;
  final Value<double> prescribedDistanceKm;
  final Value<double?> prescribedPaceSecPerKm;
  final Value<String?> notes;
  final Value<String> status;
  final Value<String?> matchedRunId;
  final Value<int> rowid;
  const PlanSessionsTableCompanion({
    this.id = const Value.absent(),
    this.planId = const Value.absent(),
    this.scheduledDate = const Value.absent(),
    this.weekNumber = const Value.absent(),
    this.dayOfWeek = const Value.absent(),
    this.type = const Value.absent(),
    this.prescribedDistanceKm = const Value.absent(),
    this.prescribedPaceSecPerKm = const Value.absent(),
    this.notes = const Value.absent(),
    this.status = const Value.absent(),
    this.matchedRunId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PlanSessionsTableCompanion.insert({
    required String id,
    required String planId,
    required DateTime scheduledDate,
    required int weekNumber,
    required int dayOfWeek,
    required String type,
    required double prescribedDistanceKm,
    this.prescribedPaceSecPerKm = const Value.absent(),
    this.notes = const Value.absent(),
    required String status,
    this.matchedRunId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       planId = Value(planId),
       scheduledDate = Value(scheduledDate),
       weekNumber = Value(weekNumber),
       dayOfWeek = Value(dayOfWeek),
       type = Value(type),
       prescribedDistanceKm = Value(prescribedDistanceKm),
       status = Value(status);
  static Insertable<PlanSessionRow> custom({
    Expression<String>? id,
    Expression<String>? planId,
    Expression<DateTime>? scheduledDate,
    Expression<int>? weekNumber,
    Expression<int>? dayOfWeek,
    Expression<String>? type,
    Expression<double>? prescribedDistanceKm,
    Expression<double>? prescribedPaceSecPerKm,
    Expression<String>? notes,
    Expression<String>? status,
    Expression<String>? matchedRunId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (planId != null) 'plan_id': planId,
      if (scheduledDate != null) 'scheduled_date': scheduledDate,
      if (weekNumber != null) 'week_number': weekNumber,
      if (dayOfWeek != null) 'day_of_week': dayOfWeek,
      if (type != null) 'type': type,
      if (prescribedDistanceKm != null)
        'prescribed_distance_km': prescribedDistanceKm,
      if (prescribedPaceSecPerKm != null)
        'prescribed_pace_sec_per_km': prescribedPaceSecPerKm,
      if (notes != null) 'notes': notes,
      if (status != null) 'status': status,
      if (matchedRunId != null) 'matched_run_id': matchedRunId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PlanSessionsTableCompanion copyWith({
    Value<String>? id,
    Value<String>? planId,
    Value<DateTime>? scheduledDate,
    Value<int>? weekNumber,
    Value<int>? dayOfWeek,
    Value<String>? type,
    Value<double>? prescribedDistanceKm,
    Value<double?>? prescribedPaceSecPerKm,
    Value<String?>? notes,
    Value<String>? status,
    Value<String?>? matchedRunId,
    Value<int>? rowid,
  }) {
    return PlanSessionsTableCompanion(
      id: id ?? this.id,
      planId: planId ?? this.planId,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      weekNumber: weekNumber ?? this.weekNumber,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      type: type ?? this.type,
      prescribedDistanceKm: prescribedDistanceKm ?? this.prescribedDistanceKm,
      prescribedPaceSecPerKm:
          prescribedPaceSecPerKm ?? this.prescribedPaceSecPerKm,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      matchedRunId: matchedRunId ?? this.matchedRunId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (planId.present) {
      map['plan_id'] = Variable<String>(planId.value);
    }
    if (scheduledDate.present) {
      map['scheduled_date'] = Variable<DateTime>(scheduledDate.value);
    }
    if (weekNumber.present) {
      map['week_number'] = Variable<int>(weekNumber.value);
    }
    if (dayOfWeek.present) {
      map['day_of_week'] = Variable<int>(dayOfWeek.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (prescribedDistanceKm.present) {
      map['prescribed_distance_km'] = Variable<double>(
        prescribedDistanceKm.value,
      );
    }
    if (prescribedPaceSecPerKm.present) {
      map['prescribed_pace_sec_per_km'] = Variable<double>(
        prescribedPaceSecPerKm.value,
      );
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (matchedRunId.present) {
      map['matched_run_id'] = Variable<String>(matchedRunId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlanSessionsTableCompanion(')
          ..write('id: $id, ')
          ..write('planId: $planId, ')
          ..write('scheduledDate: $scheduledDate, ')
          ..write('weekNumber: $weekNumber, ')
          ..write('dayOfWeek: $dayOfWeek, ')
          ..write('type: $type, ')
          ..write('prescribedDistanceKm: $prescribedDistanceKm, ')
          ..write('prescribedPaceSecPerKm: $prescribedPaceSecPerKm, ')
          ..write('notes: $notes, ')
          ..write('status: $status, ')
          ..write('matchedRunId: $matchedRunId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $UserProfilesTable userProfiles = $UserProfilesTable(this);
  late final $RunsTable runs = $RunsTable(this);
  late final $RunSamplesTable runSamples = $RunSamplesTable(this);
  late final $PlansTable plans = $PlansTable(this);
  late final $PlanSessionsTableTable planSessionsTable =
      $PlanSessionsTableTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    userProfiles,
    runs,
    runSamples,
    plans,
    planSessionsTable,
  ];
}

typedef $$UserProfilesTableCreateCompanionBuilder =
    UserProfilesCompanion Function({
      required String id,
      required int ageYears,
      required String gender,
      required double heightCm,
      required double weightKg,
      required String fitnessLevel,
      Value<double?> recentRunDistanceM,
      Value<int?> recentRunDurationSec,
      Value<int> daysPerWeek,
      required DateTime targetMarathonDate,
      Value<int?> goalMarathonTimeSec,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$UserProfilesTableUpdateCompanionBuilder =
    UserProfilesCompanion Function({
      Value<String> id,
      Value<int> ageYears,
      Value<String> gender,
      Value<double> heightCm,
      Value<double> weightKg,
      Value<String> fitnessLevel,
      Value<double?> recentRunDistanceM,
      Value<int?> recentRunDurationSec,
      Value<int> daysPerWeek,
      Value<DateTime> targetMarathonDate,
      Value<int?> goalMarathonTimeSec,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$UserProfilesTableFilterComposer
    extends Composer<_$AppDatabase, $UserProfilesTable> {
  $$UserProfilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ageYears => $composableBuilder(
    column: $table.ageYears,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get gender => $composableBuilder(
    column: $table.gender,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get heightCm => $composableBuilder(
    column: $table.heightCm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get weightKg => $composableBuilder(
    column: $table.weightKg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fitnessLevel => $composableBuilder(
    column: $table.fitnessLevel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get recentRunDistanceM => $composableBuilder(
    column: $table.recentRunDistanceM,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get recentRunDurationSec => $composableBuilder(
    column: $table.recentRunDurationSec,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get daysPerWeek => $composableBuilder(
    column: $table.daysPerWeek,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get targetMarathonDate => $composableBuilder(
    column: $table.targetMarathonDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get goalMarathonTimeSec => $composableBuilder(
    column: $table.goalMarathonTimeSec,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UserProfilesTableOrderingComposer
    extends Composer<_$AppDatabase, $UserProfilesTable> {
  $$UserProfilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ageYears => $composableBuilder(
    column: $table.ageYears,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get gender => $composableBuilder(
    column: $table.gender,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get heightCm => $composableBuilder(
    column: $table.heightCm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get weightKg => $composableBuilder(
    column: $table.weightKg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fitnessLevel => $composableBuilder(
    column: $table.fitnessLevel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get recentRunDistanceM => $composableBuilder(
    column: $table.recentRunDistanceM,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get recentRunDurationSec => $composableBuilder(
    column: $table.recentRunDurationSec,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get daysPerWeek => $composableBuilder(
    column: $table.daysPerWeek,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get targetMarathonDate => $composableBuilder(
    column: $table.targetMarathonDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get goalMarathonTimeSec => $composableBuilder(
    column: $table.goalMarathonTimeSec,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UserProfilesTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserProfilesTable> {
  $$UserProfilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get ageYears =>
      $composableBuilder(column: $table.ageYears, builder: (column) => column);

  GeneratedColumn<String> get gender =>
      $composableBuilder(column: $table.gender, builder: (column) => column);

  GeneratedColumn<double> get heightCm =>
      $composableBuilder(column: $table.heightCm, builder: (column) => column);

  GeneratedColumn<double> get weightKg =>
      $composableBuilder(column: $table.weightKg, builder: (column) => column);

  GeneratedColumn<String> get fitnessLevel => $composableBuilder(
    column: $table.fitnessLevel,
    builder: (column) => column,
  );

  GeneratedColumn<double> get recentRunDistanceM => $composableBuilder(
    column: $table.recentRunDistanceM,
    builder: (column) => column,
  );

  GeneratedColumn<int> get recentRunDurationSec => $composableBuilder(
    column: $table.recentRunDurationSec,
    builder: (column) => column,
  );

  GeneratedColumn<int> get daysPerWeek => $composableBuilder(
    column: $table.daysPerWeek,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get targetMarathonDate => $composableBuilder(
    column: $table.targetMarathonDate,
    builder: (column) => column,
  );

  GeneratedColumn<int> get goalMarathonTimeSec => $composableBuilder(
    column: $table.goalMarathonTimeSec,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$UserProfilesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UserProfilesTable,
          UserProfileRow,
          $$UserProfilesTableFilterComposer,
          $$UserProfilesTableOrderingComposer,
          $$UserProfilesTableAnnotationComposer,
          $$UserProfilesTableCreateCompanionBuilder,
          $$UserProfilesTableUpdateCompanionBuilder,
          (
            UserProfileRow,
            BaseReferences<_$AppDatabase, $UserProfilesTable, UserProfileRow>,
          ),
          UserProfileRow,
          PrefetchHooks Function()
        > {
  $$UserProfilesTableTableManager(_$AppDatabase db, $UserProfilesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserProfilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserProfilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> ageYears = const Value.absent(),
                Value<String> gender = const Value.absent(),
                Value<double> heightCm = const Value.absent(),
                Value<double> weightKg = const Value.absent(),
                Value<String> fitnessLevel = const Value.absent(),
                Value<double?> recentRunDistanceM = const Value.absent(),
                Value<int?> recentRunDurationSec = const Value.absent(),
                Value<int> daysPerWeek = const Value.absent(),
                Value<DateTime> targetMarathonDate = const Value.absent(),
                Value<int?> goalMarathonTimeSec = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UserProfilesCompanion(
                id: id,
                ageYears: ageYears,
                gender: gender,
                heightCm: heightCm,
                weightKg: weightKg,
                fitnessLevel: fitnessLevel,
                recentRunDistanceM: recentRunDistanceM,
                recentRunDurationSec: recentRunDurationSec,
                daysPerWeek: daysPerWeek,
                targetMarathonDate: targetMarathonDate,
                goalMarathonTimeSec: goalMarathonTimeSec,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int ageYears,
                required String gender,
                required double heightCm,
                required double weightKg,
                required String fitnessLevel,
                Value<double?> recentRunDistanceM = const Value.absent(),
                Value<int?> recentRunDurationSec = const Value.absent(),
                Value<int> daysPerWeek = const Value.absent(),
                required DateTime targetMarathonDate,
                Value<int?> goalMarathonTimeSec = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => UserProfilesCompanion.insert(
                id: id,
                ageYears: ageYears,
                gender: gender,
                heightCm: heightCm,
                weightKg: weightKg,
                fitnessLevel: fitnessLevel,
                recentRunDistanceM: recentRunDistanceM,
                recentRunDurationSec: recentRunDurationSec,
                daysPerWeek: daysPerWeek,
                targetMarathonDate: targetMarathonDate,
                goalMarathonTimeSec: goalMarathonTimeSec,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UserProfilesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UserProfilesTable,
      UserProfileRow,
      $$UserProfilesTableFilterComposer,
      $$UserProfilesTableOrderingComposer,
      $$UserProfilesTableAnnotationComposer,
      $$UserProfilesTableCreateCompanionBuilder,
      $$UserProfilesTableUpdateCompanionBuilder,
      (
        UserProfileRow,
        BaseReferences<_$AppDatabase, $UserProfilesTable, UserProfileRow>,
      ),
      UserProfileRow,
      PrefetchHooks Function()
    >;
typedef $$RunsTableCreateCompanionBuilder =
    RunsCompanion Function({
      required String id,
      required DateTime startedAt,
      Value<DateTime?> endedAt,
      Value<double> distanceM,
      Value<int> movingTimeSec,
      Value<int> elapsedTimeSec,
      Value<double?> avgPaceSecPerKm,
      Value<double> elevationGainM,
      Value<String?> encodedPolyline,
      Value<String> source,
      Value<String?> matchedSessionId,
      Value<int> rowid,
    });
typedef $$RunsTableUpdateCompanionBuilder =
    RunsCompanion Function({
      Value<String> id,
      Value<DateTime> startedAt,
      Value<DateTime?> endedAt,
      Value<double> distanceM,
      Value<int> movingTimeSec,
      Value<int> elapsedTimeSec,
      Value<double?> avgPaceSecPerKm,
      Value<double> elevationGainM,
      Value<String?> encodedPolyline,
      Value<String> source,
      Value<String?> matchedSessionId,
      Value<int> rowid,
    });

class $$RunsTableFilterComposer extends Composer<_$AppDatabase, $RunsTable> {
  $$RunsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get distanceM => $composableBuilder(
    column: $table.distanceM,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get movingTimeSec => $composableBuilder(
    column: $table.movingTimeSec,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get elapsedTimeSec => $composableBuilder(
    column: $table.elapsedTimeSec,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get avgPaceSecPerKm => $composableBuilder(
    column: $table.avgPaceSecPerKm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get elevationGainM => $composableBuilder(
    column: $table.elevationGainM,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get encodedPolyline => $composableBuilder(
    column: $table.encodedPolyline,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get matchedSessionId => $composableBuilder(
    column: $table.matchedSessionId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RunsTableOrderingComposer extends Composer<_$AppDatabase, $RunsTable> {
  $$RunsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get distanceM => $composableBuilder(
    column: $table.distanceM,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get movingTimeSec => $composableBuilder(
    column: $table.movingTimeSec,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get elapsedTimeSec => $composableBuilder(
    column: $table.elapsedTimeSec,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get avgPaceSecPerKm => $composableBuilder(
    column: $table.avgPaceSecPerKm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get elevationGainM => $composableBuilder(
    column: $table.elevationGainM,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get encodedPolyline => $composableBuilder(
    column: $table.encodedPolyline,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get matchedSessionId => $composableBuilder(
    column: $table.matchedSessionId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RunsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RunsTable> {
  $$RunsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get endedAt =>
      $composableBuilder(column: $table.endedAt, builder: (column) => column);

  GeneratedColumn<double> get distanceM =>
      $composableBuilder(column: $table.distanceM, builder: (column) => column);

  GeneratedColumn<int> get movingTimeSec => $composableBuilder(
    column: $table.movingTimeSec,
    builder: (column) => column,
  );

  GeneratedColumn<int> get elapsedTimeSec => $composableBuilder(
    column: $table.elapsedTimeSec,
    builder: (column) => column,
  );

  GeneratedColumn<double> get avgPaceSecPerKm => $composableBuilder(
    column: $table.avgPaceSecPerKm,
    builder: (column) => column,
  );

  GeneratedColumn<double> get elevationGainM => $composableBuilder(
    column: $table.elevationGainM,
    builder: (column) => column,
  );

  GeneratedColumn<String> get encodedPolyline => $composableBuilder(
    column: $table.encodedPolyline,
    builder: (column) => column,
  );

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<String> get matchedSessionId => $composableBuilder(
    column: $table.matchedSessionId,
    builder: (column) => column,
  );
}

class $$RunsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RunsTable,
          RunRow,
          $$RunsTableFilterComposer,
          $$RunsTableOrderingComposer,
          $$RunsTableAnnotationComposer,
          $$RunsTableCreateCompanionBuilder,
          $$RunsTableUpdateCompanionBuilder,
          (RunRow, BaseReferences<_$AppDatabase, $RunsTable, RunRow>),
          RunRow,
          PrefetchHooks Function()
        > {
  $$RunsTableTableManager(_$AppDatabase db, $RunsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RunsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RunsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RunsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> startedAt = const Value.absent(),
                Value<DateTime?> endedAt = const Value.absent(),
                Value<double> distanceM = const Value.absent(),
                Value<int> movingTimeSec = const Value.absent(),
                Value<int> elapsedTimeSec = const Value.absent(),
                Value<double?> avgPaceSecPerKm = const Value.absent(),
                Value<double> elevationGainM = const Value.absent(),
                Value<String?> encodedPolyline = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<String?> matchedSessionId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RunsCompanion(
                id: id,
                startedAt: startedAt,
                endedAt: endedAt,
                distanceM: distanceM,
                movingTimeSec: movingTimeSec,
                elapsedTimeSec: elapsedTimeSec,
                avgPaceSecPerKm: avgPaceSecPerKm,
                elevationGainM: elevationGainM,
                encodedPolyline: encodedPolyline,
                source: source,
                matchedSessionId: matchedSessionId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime startedAt,
                Value<DateTime?> endedAt = const Value.absent(),
                Value<double> distanceM = const Value.absent(),
                Value<int> movingTimeSec = const Value.absent(),
                Value<int> elapsedTimeSec = const Value.absent(),
                Value<double?> avgPaceSecPerKm = const Value.absent(),
                Value<double> elevationGainM = const Value.absent(),
                Value<String?> encodedPolyline = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<String?> matchedSessionId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RunsCompanion.insert(
                id: id,
                startedAt: startedAt,
                endedAt: endedAt,
                distanceM: distanceM,
                movingTimeSec: movingTimeSec,
                elapsedTimeSec: elapsedTimeSec,
                avgPaceSecPerKm: avgPaceSecPerKm,
                elevationGainM: elevationGainM,
                encodedPolyline: encodedPolyline,
                source: source,
                matchedSessionId: matchedSessionId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RunsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RunsTable,
      RunRow,
      $$RunsTableFilterComposer,
      $$RunsTableOrderingComposer,
      $$RunsTableAnnotationComposer,
      $$RunsTableCreateCompanionBuilder,
      $$RunsTableUpdateCompanionBuilder,
      (RunRow, BaseReferences<_$AppDatabase, $RunsTable, RunRow>),
      RunRow,
      PrefetchHooks Function()
    >;
typedef $$RunSamplesTableCreateCompanionBuilder =
    RunSamplesCompanion Function({
      required String runId,
      required int tOffsetMs,
      required double lat,
      required double lon,
      Value<double?> elevationM,
      Value<double?> instantSpeedMps,
      Value<int> rowid,
    });
typedef $$RunSamplesTableUpdateCompanionBuilder =
    RunSamplesCompanion Function({
      Value<String> runId,
      Value<int> tOffsetMs,
      Value<double> lat,
      Value<double> lon,
      Value<double?> elevationM,
      Value<double?> instantSpeedMps,
      Value<int> rowid,
    });

class $$RunSamplesTableFilterComposer
    extends Composer<_$AppDatabase, $RunSamplesTable> {
  $$RunSamplesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get runId => $composableBuilder(
    column: $table.runId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get tOffsetMs => $composableBuilder(
    column: $table.tOffsetMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get lat => $composableBuilder(
    column: $table.lat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get lon => $composableBuilder(
    column: $table.lon,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get elevationM => $composableBuilder(
    column: $table.elevationM,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get instantSpeedMps => $composableBuilder(
    column: $table.instantSpeedMps,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RunSamplesTableOrderingComposer
    extends Composer<_$AppDatabase, $RunSamplesTable> {
  $$RunSamplesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get runId => $composableBuilder(
    column: $table.runId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get tOffsetMs => $composableBuilder(
    column: $table.tOffsetMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get lat => $composableBuilder(
    column: $table.lat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get lon => $composableBuilder(
    column: $table.lon,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get elevationM => $composableBuilder(
    column: $table.elevationM,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get instantSpeedMps => $composableBuilder(
    column: $table.instantSpeedMps,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RunSamplesTableAnnotationComposer
    extends Composer<_$AppDatabase, $RunSamplesTable> {
  $$RunSamplesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get runId =>
      $composableBuilder(column: $table.runId, builder: (column) => column);

  GeneratedColumn<int> get tOffsetMs =>
      $composableBuilder(column: $table.tOffsetMs, builder: (column) => column);

  GeneratedColumn<double> get lat =>
      $composableBuilder(column: $table.lat, builder: (column) => column);

  GeneratedColumn<double> get lon =>
      $composableBuilder(column: $table.lon, builder: (column) => column);

  GeneratedColumn<double> get elevationM => $composableBuilder(
    column: $table.elevationM,
    builder: (column) => column,
  );

  GeneratedColumn<double> get instantSpeedMps => $composableBuilder(
    column: $table.instantSpeedMps,
    builder: (column) => column,
  );
}

class $$RunSamplesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RunSamplesTable,
          RunSampleRow,
          $$RunSamplesTableFilterComposer,
          $$RunSamplesTableOrderingComposer,
          $$RunSamplesTableAnnotationComposer,
          $$RunSamplesTableCreateCompanionBuilder,
          $$RunSamplesTableUpdateCompanionBuilder,
          (
            RunSampleRow,
            BaseReferences<_$AppDatabase, $RunSamplesTable, RunSampleRow>,
          ),
          RunSampleRow,
          PrefetchHooks Function()
        > {
  $$RunSamplesTableTableManager(_$AppDatabase db, $RunSamplesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RunSamplesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RunSamplesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RunSamplesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> runId = const Value.absent(),
                Value<int> tOffsetMs = const Value.absent(),
                Value<double> lat = const Value.absent(),
                Value<double> lon = const Value.absent(),
                Value<double?> elevationM = const Value.absent(),
                Value<double?> instantSpeedMps = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RunSamplesCompanion(
                runId: runId,
                tOffsetMs: tOffsetMs,
                lat: lat,
                lon: lon,
                elevationM: elevationM,
                instantSpeedMps: instantSpeedMps,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String runId,
                required int tOffsetMs,
                required double lat,
                required double lon,
                Value<double?> elevationM = const Value.absent(),
                Value<double?> instantSpeedMps = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RunSamplesCompanion.insert(
                runId: runId,
                tOffsetMs: tOffsetMs,
                lat: lat,
                lon: lon,
                elevationM: elevationM,
                instantSpeedMps: instantSpeedMps,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RunSamplesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RunSamplesTable,
      RunSampleRow,
      $$RunSamplesTableFilterComposer,
      $$RunSamplesTableOrderingComposer,
      $$RunSamplesTableAnnotationComposer,
      $$RunSamplesTableCreateCompanionBuilder,
      $$RunSamplesTableUpdateCompanionBuilder,
      (
        RunSampleRow,
        BaseReferences<_$AppDatabase, $RunSamplesTable, RunSampleRow>,
      ),
      RunSampleRow,
      PrefetchHooks Function()
    >;
typedef $$PlansTableCreateCompanionBuilder =
    PlansCompanion Function({
      required String id,
      required String userId,
      required DateTime startsOn,
      required DateTime targetMarathonDate,
      required int totalWeeks,
      required double startVdot,
      required double targetVdot,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$PlansTableUpdateCompanionBuilder =
    PlansCompanion Function({
      Value<String> id,
      Value<String> userId,
      Value<DateTime> startsOn,
      Value<DateTime> targetMarathonDate,
      Value<int> totalWeeks,
      Value<double> startVdot,
      Value<double> targetVdot,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$PlansTableFilterComposer extends Composer<_$AppDatabase, $PlansTable> {
  $$PlansTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startsOn => $composableBuilder(
    column: $table.startsOn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get targetMarathonDate => $composableBuilder(
    column: $table.targetMarathonDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalWeeks => $composableBuilder(
    column: $table.totalWeeks,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get startVdot => $composableBuilder(
    column: $table.startVdot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get targetVdot => $composableBuilder(
    column: $table.targetVdot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PlansTableOrderingComposer
    extends Composer<_$AppDatabase, $PlansTable> {
  $$PlansTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startsOn => $composableBuilder(
    column: $table.startsOn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get targetMarathonDate => $composableBuilder(
    column: $table.targetMarathonDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalWeeks => $composableBuilder(
    column: $table.totalWeeks,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get startVdot => $composableBuilder(
    column: $table.startVdot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get targetVdot => $composableBuilder(
    column: $table.targetVdot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PlansTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlansTable> {
  $$PlansTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<DateTime> get startsOn =>
      $composableBuilder(column: $table.startsOn, builder: (column) => column);

  GeneratedColumn<DateTime> get targetMarathonDate => $composableBuilder(
    column: $table.targetMarathonDate,
    builder: (column) => column,
  );

  GeneratedColumn<int> get totalWeeks => $composableBuilder(
    column: $table.totalWeeks,
    builder: (column) => column,
  );

  GeneratedColumn<double> get startVdot =>
      $composableBuilder(column: $table.startVdot, builder: (column) => column);

  GeneratedColumn<double> get targetVdot => $composableBuilder(
    column: $table.targetVdot,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$PlansTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PlansTable,
          PlanRow,
          $$PlansTableFilterComposer,
          $$PlansTableOrderingComposer,
          $$PlansTableAnnotationComposer,
          $$PlansTableCreateCompanionBuilder,
          $$PlansTableUpdateCompanionBuilder,
          (PlanRow, BaseReferences<_$AppDatabase, $PlansTable, PlanRow>),
          PlanRow,
          PrefetchHooks Function()
        > {
  $$PlansTableTableManager(_$AppDatabase db, $PlansTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlansTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlansTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlansTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<DateTime> startsOn = const Value.absent(),
                Value<DateTime> targetMarathonDate = const Value.absent(),
                Value<int> totalWeeks = const Value.absent(),
                Value<double> startVdot = const Value.absent(),
                Value<double> targetVdot = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PlansCompanion(
                id: id,
                userId: userId,
                startsOn: startsOn,
                targetMarathonDate: targetMarathonDate,
                totalWeeks: totalWeeks,
                startVdot: startVdot,
                targetVdot: targetVdot,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String userId,
                required DateTime startsOn,
                required DateTime targetMarathonDate,
                required int totalWeeks,
                required double startVdot,
                required double targetVdot,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => PlansCompanion.insert(
                id: id,
                userId: userId,
                startsOn: startsOn,
                targetMarathonDate: targetMarathonDate,
                totalWeeks: totalWeeks,
                startVdot: startVdot,
                targetVdot: targetVdot,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PlansTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PlansTable,
      PlanRow,
      $$PlansTableFilterComposer,
      $$PlansTableOrderingComposer,
      $$PlansTableAnnotationComposer,
      $$PlansTableCreateCompanionBuilder,
      $$PlansTableUpdateCompanionBuilder,
      (PlanRow, BaseReferences<_$AppDatabase, $PlansTable, PlanRow>),
      PlanRow,
      PrefetchHooks Function()
    >;
typedef $$PlanSessionsTableTableCreateCompanionBuilder =
    PlanSessionsTableCompanion Function({
      required String id,
      required String planId,
      required DateTime scheduledDate,
      required int weekNumber,
      required int dayOfWeek,
      required String type,
      required double prescribedDistanceKm,
      Value<double?> prescribedPaceSecPerKm,
      Value<String?> notes,
      required String status,
      Value<String?> matchedRunId,
      Value<int> rowid,
    });
typedef $$PlanSessionsTableTableUpdateCompanionBuilder =
    PlanSessionsTableCompanion Function({
      Value<String> id,
      Value<String> planId,
      Value<DateTime> scheduledDate,
      Value<int> weekNumber,
      Value<int> dayOfWeek,
      Value<String> type,
      Value<double> prescribedDistanceKm,
      Value<double?> prescribedPaceSecPerKm,
      Value<String?> notes,
      Value<String> status,
      Value<String?> matchedRunId,
      Value<int> rowid,
    });

class $$PlanSessionsTableTableFilterComposer
    extends Composer<_$AppDatabase, $PlanSessionsTableTable> {
  $$PlanSessionsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get planId => $composableBuilder(
    column: $table.planId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get scheduledDate => $composableBuilder(
    column: $table.scheduledDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get weekNumber => $composableBuilder(
    column: $table.weekNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dayOfWeek => $composableBuilder(
    column: $table.dayOfWeek,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get prescribedDistanceKm => $composableBuilder(
    column: $table.prescribedDistanceKm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get prescribedPaceSecPerKm => $composableBuilder(
    column: $table.prescribedPaceSecPerKm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get matchedRunId => $composableBuilder(
    column: $table.matchedRunId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PlanSessionsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $PlanSessionsTableTable> {
  $$PlanSessionsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get planId => $composableBuilder(
    column: $table.planId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get scheduledDate => $composableBuilder(
    column: $table.scheduledDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get weekNumber => $composableBuilder(
    column: $table.weekNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dayOfWeek => $composableBuilder(
    column: $table.dayOfWeek,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get prescribedDistanceKm => $composableBuilder(
    column: $table.prescribedDistanceKm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get prescribedPaceSecPerKm => $composableBuilder(
    column: $table.prescribedPaceSecPerKm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get matchedRunId => $composableBuilder(
    column: $table.matchedRunId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PlanSessionsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlanSessionsTableTable> {
  $$PlanSessionsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get planId =>
      $composableBuilder(column: $table.planId, builder: (column) => column);

  GeneratedColumn<DateTime> get scheduledDate => $composableBuilder(
    column: $table.scheduledDate,
    builder: (column) => column,
  );

  GeneratedColumn<int> get weekNumber => $composableBuilder(
    column: $table.weekNumber,
    builder: (column) => column,
  );

  GeneratedColumn<int> get dayOfWeek =>
      $composableBuilder(column: $table.dayOfWeek, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<double> get prescribedDistanceKm => $composableBuilder(
    column: $table.prescribedDistanceKm,
    builder: (column) => column,
  );

  GeneratedColumn<double> get prescribedPaceSecPerKm => $composableBuilder(
    column: $table.prescribedPaceSecPerKm,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get matchedRunId => $composableBuilder(
    column: $table.matchedRunId,
    builder: (column) => column,
  );
}

class $$PlanSessionsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PlanSessionsTableTable,
          PlanSessionRow,
          $$PlanSessionsTableTableFilterComposer,
          $$PlanSessionsTableTableOrderingComposer,
          $$PlanSessionsTableTableAnnotationComposer,
          $$PlanSessionsTableTableCreateCompanionBuilder,
          $$PlanSessionsTableTableUpdateCompanionBuilder,
          (
            PlanSessionRow,
            BaseReferences<
              _$AppDatabase,
              $PlanSessionsTableTable,
              PlanSessionRow
            >,
          ),
          PlanSessionRow,
          PrefetchHooks Function()
        > {
  $$PlanSessionsTableTableTableManager(
    _$AppDatabase db,
    $PlanSessionsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlanSessionsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlanSessionsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlanSessionsTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> planId = const Value.absent(),
                Value<DateTime> scheduledDate = const Value.absent(),
                Value<int> weekNumber = const Value.absent(),
                Value<int> dayOfWeek = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<double> prescribedDistanceKm = const Value.absent(),
                Value<double?> prescribedPaceSecPerKm = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> matchedRunId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PlanSessionsTableCompanion(
                id: id,
                planId: planId,
                scheduledDate: scheduledDate,
                weekNumber: weekNumber,
                dayOfWeek: dayOfWeek,
                type: type,
                prescribedDistanceKm: prescribedDistanceKm,
                prescribedPaceSecPerKm: prescribedPaceSecPerKm,
                notes: notes,
                status: status,
                matchedRunId: matchedRunId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String planId,
                required DateTime scheduledDate,
                required int weekNumber,
                required int dayOfWeek,
                required String type,
                required double prescribedDistanceKm,
                Value<double?> prescribedPaceSecPerKm = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                required String status,
                Value<String?> matchedRunId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PlanSessionsTableCompanion.insert(
                id: id,
                planId: planId,
                scheduledDate: scheduledDate,
                weekNumber: weekNumber,
                dayOfWeek: dayOfWeek,
                type: type,
                prescribedDistanceKm: prescribedDistanceKm,
                prescribedPaceSecPerKm: prescribedPaceSecPerKm,
                notes: notes,
                status: status,
                matchedRunId: matchedRunId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PlanSessionsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PlanSessionsTableTable,
      PlanSessionRow,
      $$PlanSessionsTableTableFilterComposer,
      $$PlanSessionsTableTableOrderingComposer,
      $$PlanSessionsTableTableAnnotationComposer,
      $$PlanSessionsTableTableCreateCompanionBuilder,
      $$PlanSessionsTableTableUpdateCompanionBuilder,
      (
        PlanSessionRow,
        BaseReferences<_$AppDatabase, $PlanSessionsTableTable, PlanSessionRow>,
      ),
      PlanSessionRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$UserProfilesTableTableManager get userProfiles =>
      $$UserProfilesTableTableManager(_db, _db.userProfiles);
  $$RunsTableTableManager get runs => $$RunsTableTableManager(_db, _db.runs);
  $$RunSamplesTableTableManager get runSamples =>
      $$RunSamplesTableTableManager(_db, _db.runSamples);
  $$PlansTableTableManager get plans =>
      $$PlansTableTableManager(_db, _db.plans);
  $$PlanSessionsTableTableTableManager get planSessionsTable =>
      $$PlanSessionsTableTableTableManager(_db, _db.planSessionsTable);
}
