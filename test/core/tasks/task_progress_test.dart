/// Verify [TaskProgress] sealed hierarchy construction and equality.
library;

import 'package:flutter_starter/core/tasks/task_progress.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('IndeterminateProgress', () {
    test('instances are equal', () {
      const a = IndeterminateProgress();
      const b = IndeterminateProgress();
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('factory constructor creates correct type', () {
      const progress = TaskProgress.indeterminate();
      expect(progress, isA<IndeterminateProgress>());
    });

    test('toString returns readable representation', () {
      expect(
        const IndeterminateProgress().toString(),
        equals('TaskProgress.indeterminate()'),
      );
    });
  });

  group('DeterminateProgress', () {
    test('instances with same fraction are equal', () {
      const a = DeterminateProgress(0.5);
      const b = DeterminateProgress(0.5);
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('instances with different fractions are not equal', () {
      const a = DeterminateProgress(0.5);
      const b = DeterminateProgress(0.7);
      expect(a, isNot(equals(b)));
    });

    test('factory constructor creates correct type', () {
      const progress = TaskProgress.determinate(0.5);
      expect(progress, isA<DeterminateProgress>());
      expect((progress as DeterminateProgress).fraction, equals(0.5));
    });

    test('toString returns readable representation', () {
      expect(
        const DeterminateProgress(0.5).toString(),
        equals('TaskProgress.determinate(0.5)'),
      );
    });

    test('asserts on fraction below 0.0', () {
      expect(
        () => DeterminateProgress(-0.1),
        throwsA(isA<AssertionError>()),
      );
    });

    test('asserts on fraction above 1.0', () {
      expect(
        () => DeterminateProgress(1.1),
        throwsA(isA<AssertionError>()),
      );
    });

    test('accepts boundary values 0.0 and 1.0', () {
      expect(const DeterminateProgress(0.0).fraction, 0.0);
      expect(const DeterminateProgress(1.0).fraction, 1.0);
    });
  });

  group('PhasedProgress', () {
    test('instances with same label and fraction are equal', () {
      const a = PhasedProgress('Compressing', 0.5);
      const b = PhasedProgress('Compressing', 0.5);
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('instances with different labels are not equal', () {
      const a = PhasedProgress('Compressing');
      const b = PhasedProgress('Uploading');
      expect(a, isNot(equals(b)));
    });

    test('instances with same label but different fractions are not equal', () {
      const a = PhasedProgress('Uploading', 0.3);
      const b = PhasedProgress('Uploading', 0.7);
      expect(a, isNot(equals(b)));
    });

    test('instances with null fraction are equal', () {
      const a = PhasedProgress('Compressing');
      const b = PhasedProgress('Compressing');
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('factory constructor creates correct type', () {
      const progress = TaskProgress.phased('Compressing', 0.5);
      expect(progress, isA<PhasedProgress>());
      final phased = progress as PhasedProgress;
      expect(phased.label, equals('Compressing'));
      expect(phased.fraction, equals(0.5));
    });

    test('toString returns readable representation', () {
      expect(
        const PhasedProgress('Uploading', 0.5).toString(),
        equals('TaskProgress.phased(Uploading, 0.5)'),
      );
    });

    test('asserts on fraction below 0.0', () {
      expect(
        () => PhasedProgress('Test', -0.1),
        throwsA(isA<AssertionError>()),
      );
    });

    test('asserts on fraction above 1.0', () {
      expect(
        () => PhasedProgress('Test', 1.1),
        throwsA(isA<AssertionError>()),
      );
    });

    test('accepts null fraction', () {
      expect(const PhasedProgress('Test').fraction, isNull);
    });
  });

  group('cross-type inequality', () {
    test('different progress types are not equal', () {
      const indeterminate = IndeterminateProgress();
      const determinate = DeterminateProgress(0.5);
      const phased = PhasedProgress('Test');

      final TaskProgress a = indeterminate;
      final TaskProgress b = determinate;
      final TaskProgress c = phased;

      expect(a, isNot(equals(b)));
      expect(a, isNot(equals(c)));
      expect(b, isNot(equals(c)));
    });
  });
}
