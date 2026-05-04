import 'package:flutter_test/flutter_test.dart';

import 'package:daloy/core/math/splits.dart';

void main() {
  group('bestSplitSec', () {
    test('returns null when there are too few samples', () {
      expect(
        bestSplitSec(samples: const [], targetDistanceM: 1000),
        isNull,
      );
      expect(
        bestSplitSec(
          samples: const [(lat: 0, lon: 0, tOffsetMs: 0)],
          targetDistanceM: 1000,
        ),
        isNull,
      );
    });

    test('returns null when run is shorter than target distance', () {
      // Two points 100m apart; asking for a 1km split.
      const samples = [
        (lat: 0.0, lon: 0.0, tOffsetMs: 0),
        (lat: 0.0009, lon: 0.0, tOffsetMs: 60000), // ~100m at 0,0
      ];
      expect(
        bestSplitSec(samples: samples, targetDistanceM: 1000),
        isNull,
      );
    });

    test('finds the fastest 1km window in a steady run', () {
      // 10 samples spaced ~200m apart at the equator (1 deg lat ≈ 111km).
      // Step is 0.001797 deg lat ≈ 200m. Each step takes 60s = constant
      // 200m / 60s = 3.33 m/s = 5 min/km pace. The fastest 1km should
      // be ~300s (5 minutes) — there's no faster window in a steady run.
      final samples = <({double lat, double lon, int tOffsetMs})>[
        for (int i = 0; i < 10; i++)
          (lat: i * 0.001797, lon: 0, tOffsetMs: i * 60000),
      ];
      final t = bestSplitSec(samples: samples, targetDistanceM: 1000);
      expect(t, isNotNull);
      // Allow ±10s slack for sample-boundary imprecision.
      expect(t!, inInclusiveRange(290, 320));
    });

    test('picks the faster window when pace varies', () {
      // First half at 4 min/km, second half at 6 min/km.
      // Best 1km should match the first half (~240s), not the slower one.
      final fast = <({double lat, double lon, int tOffsetMs})>[
        for (int i = 0; i < 6; i++)
          (lat: i * 0.001797, lon: 0, tOffsetMs: i * 48000),
      ];
      final slow = <({double lat, double lon, int tOffsetMs})>[
        for (int i = 1; i < 6; i++)
          (
            lat: 5 * 0.001797 + i * 0.001797,
            lon: 0,
            tOffsetMs: 5 * 48000 + i * 72000,
          ),
      ];
      final samples = [...fast, ...slow];
      final t = bestSplitSec(samples: samples, targetDistanceM: 1000);
      expect(t, isNotNull);
      // Best 1k should be near the fast pace (~240s), not the slow one (~360s).
      expect(t!, lessThan(290));
    });
  });

  group('bestSplits', () {
    test('returns null entries for distances the run did not cover', () {
      // 2km run at 5 min/km. Best 1k should be set, others null.
      final samples = <({double lat, double lon, int tOffsetMs})>[
        for (int i = 0; i < 11; i++)
          (lat: i * 0.001797, lon: 0, tOffsetMs: i * 60000),
      ];
      final out = bestSplits(samples);
      expect(out[1000], isNotNull);
      // 2km exactly — the 5K/10K/Half/Marathon entries should all be null
      // because the run isn't long enough.
      expect(out[5000], isNull);
      expect(out[10000], isNull);
      expect(out[21098], isNull);
      expect(out[42195], isNull);
    });
  });
}
