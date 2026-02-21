import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:repooor/domain/repositories/data_export_repository.dart';
import 'package:repooor/domain/usecases/import_data.dart';

class MockDataExportRepository extends Mock implements DataExportRepository {}

void main() {
  late MockDataExportRepository mockRepository;
  late ImportData usecase;

  setUp(() {
    mockRepository = MockDataExportRepository();
    usecase = ImportData(mockRepository);
  });

  group('ImportData', () {
    test('should call repository.importAll with the given data', () async {
      // Arrange
      final data = <String, dynamic>{
        'products': [
          {'id': 'p1', 'name': 'Arroz', 'categoryId': 'cat-1', 'unit': 'kg'},
        ],
        'categories': [
          {'id': 'cat-1', 'name': 'Graos', 'icon': '0xe318', 'color': 'FF53B175'},
        ],
        'pantry_items': [],
        'purchases': [],
      };
      when(() => mockRepository.importAll(data))
          .thenAnswer((_) async {});

      // Act
      await usecase.call(data);

      // Assert
      verify(() => mockRepository.importAll(data)).called(1);
    });

    test('should pass empty map correctly to repository', () async {
      // Arrange
      final data = <String, dynamic>{};
      when(() => mockRepository.importAll(data))
          .thenAnswer((_) async {});

      // Act
      await usecase.call(data);

      // Assert
      verify(() => mockRepository.importAll(data)).called(1);
    });

    test('should rethrow when repository throws', () async {
      // Arrange
      final data = <String, dynamic>{'products': []};
      when(() => mockRepository.importAll(data))
          .thenThrow(Exception('Import failed'));

      // Act & Assert
      expect(() => usecase.call(data), throwsException);
      verify(() => mockRepository.importAll(data)).called(1);
    });
  });
}
