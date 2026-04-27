import 'package:flutter_test/flutter_test.dart';

import 'package:marathon_app/features/fitness/predictor.dart';

void main() {
  test('Riegel sanity: marathon time roughly 2x half marathon at same VDOT',
      () {
    const vdot = 45.0;
    final half = predictRaceTime(vdot, kHalfMarathon);
    final full = predictRaceTime(vdot, kMarathon);
    // Riegel exponent 1.06 means full > 2 * half by ~4-5%.
    expect(full.inSeconds > half.inSeconds * 2, true);
    expect(full.inSeconds < half.inSeconds * 2.2, true);
  });

  test('VDOT from race: faster time = higher VDOT', () {
    final slowMarathon = vdotFromRace(kMarathon, const Duration(hours: 5));
    final fastMarathon =
        vdotFromRace(kMarathon, const Duration(hours: 3, minutes: 30));
    expect(fastMarathon > slowMarathon, true);
  });
}
