import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:repooor/domain/repositories/data_export_repository.dart';
import 'package:repooor/domain/usecases/clear_all_data.dart';

class MockDataExportRepository extends Mock implements DataExportRepository {}

void main() {
  late MockDataExportRepository mockRepository;
  late ClearAllData usecase;

  setUp(() {
    mockRepository = MockDataExportRepository();
    usecase = ClearAllData(mockRepository);
  });

  group('ClearAllData', () {
    test('should call repository.clearAll', () async {
      // Arrange
      when(() => mockRepository.clearAll())
          .thenAnswer((_) async {});

      // Act
      await usecase.call();

      // Assert
      verify(() => mockRepository.clearAll()).called(1);
    });

    test('should rethrow when repository throws', () async {
      // Arrange
      when(() => mockRepository.clearAll())
          .thenThrow(Exception('Clear failed'));

      // Act & Assert
      expect(() => usecase.call(), throwsException);
      verify(() => mockRepository.clearAll()).called(1);
    });
  });
}
