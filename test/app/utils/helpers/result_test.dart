import 'package:flutter_test/flutter_test.dart';
import 'package:reforge/app/utils/helpers/result.dart';

void main() {
  group('Result', () {
    group('Result.success', () {
      test('creates Success with value', () {
        final result = Result<int>.success(42);
        expect(result, isA<Success<int>>());
        expect((result as Success<int>).value, 42);
      });

      test('Success toString returns expected format', () {
        final result = Result<String>.success('hello');
        expect(result.toString(), 'Result<String>.success(hello)');
      });
    });

    group('Result.error', () {
      test('creates ErrorR with error', () {
        final exception = Exception('test error');
        final result = Result<int>.error(exception);
        expect(result, isA<ErrorR<int>>());
        expect((result as ErrorR<int>).error, exception);
      });

      test('ErrorR stores optional stackTrace', () {
        final exception = Exception('test');
        final stackTrace = StackTrace.current;
        final result = Result<int>.error(exception, stackTrace);
        expect((result as ErrorR<int>).stackTrace, stackTrace);
      });

      test('ErrorR toString returns expected format', () {
        final exception = Exception('failed');
        final result = Result<int>.error(exception);
        expect(result.toString(), 'Result<int>.error(Exception: failed)');
      });
    });
  });
}
