import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/providers.dart';
import '../models/user_profile.dart';

final profileProvider = StreamProvider<UserProfile?>(
  (ref) => ref.watch(profileRepositoryProvider).watch(),
);
