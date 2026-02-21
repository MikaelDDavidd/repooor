import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:repooor/domain/repositories/data_export_repository.dart';
import 'package:repooor/domain/usecases/export_data.dart';

class MockDataExportRepository extends Mock implements DataExportRepository {}

void main() {
  late MockDataExportRepository mockRepository;
  late ExportData usecase;

  setUp(() {
    mockRepository = MockDataExportRepository();
    usecase = ExportData(mockRepository);
  });

  group('ExportData', () {
    test('should call repository.exportAll and return result', () async {
      // Arrange
      final exportedData = <String, dynamic>{
        'products': [],
        'categories': [],
        'pantry_items': [],
        'purchases': [],
      };
      when(() => mockRepository.exportAll())
          .thenAnswer((_) async => exportedData);

      // Act
      final result = await usecase.call();

      // Assert
      expect(result, exportedData);
      verify(() => mockRepository.exportAll()).called(1);
    });

    test('should return map with expected structure when repo has data',
        () async {
      // Arrange
      final exportedData = <String, dynamic>{
        'products': [
          {'id': 'p1', 'name': 'Arroz', 'categoryId': 'cat-1', 'unit': 'kg'},
        ],
        'categories': [
          {'id': 'cat-1', 'name': 'Graos', 'icon': '0xe318', 'color': 'FF53B175'},
        ],
        'pantry_items': [
          {'id': 'pi-1', 'productId': 'p1', 'currentQuantity': 2.0, 'idealQuantity': 5.0},
        ],
        'purchases': [],
      };
      when(() => mockRepository.exportAll())
          .thenAnswer((_) async => exportedData);

      // Act
      final result = await usecase.call();

      // Assert
      expect(result.containsKey('products'), isTrue);
      expect(result.containsKey('categories'), isTrue);
      expect(result.containsKey('pantry_items'), isTrue);
      expect(result.containsKey('purchases'), isTrue);
      expect((result['products'] as List).length, 1);
      verify(() => mockRepository.exportAll()).called(1);
    });

    test('should rethrow when repository throws', () async {
      // Arrange
      when(() => mockRepository.exportAll())
          .thenThrow(Exception('Database error'));

      // Act & Assert
      expect(() => usecase.call(), throwsException);
      verify(() => mockRepository.exportAll()).called(1);
    });
  });
}
