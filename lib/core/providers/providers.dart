import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/adherence/adherence_service.dart';
import '../../features/plan/repository/plan_repository.dart';
import '../../features/profile/repository/profile_repository.dart';
import '../../features/recording/service/recording_service.dart';
import '../../features/runs/repository/runs_repository.dart';
import '../database/app_database.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final profileRepositoryProvider = Provider<ProfileRepository>(
  (ref) => ProfileRepository(ref.watch(databaseProvider)),
);

final planRepositoryProvider = Provider<PlanRepository>(
  (ref) => PlanRepository(ref.watch(databaseProvider)),
);

final runsRepositoryProvider = Provider<RunsRepository>(
  (ref) => RunsRepository(ref.watch(databaseProvider)),
);

final adherenceServiceProvider = Provider<AdherenceService>(
  (ref) => AdherenceService(
    ref.watch(planRepositoryProvider),
    ref.watch(runsRepositoryProvider),
  ),
);

final recordingServiceProvider = Provider<RecordingService>(
  (ref) => RecordingService(ref.watch(runsRepositoryProvider)),
);
