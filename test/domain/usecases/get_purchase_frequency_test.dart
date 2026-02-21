import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:repooor/domain/entities/purchase.dart';
import 'package:repooor/domain/repositories/purchase_repository.dart';
import 'package:repooor/domain/usecases/get_purchase_frequency.dart';

class MockPurchaseRepository extends Mock implements PurchaseRepository {}

void main() {
  late MockPurchaseRepository mockRepository;
  late GetPurchaseFrequency usecase;

  final startDate = DateTime(2026, 1, 1);
  final endDate = DateTime(2026, 6, 30);

  setUp(() {
    mockRepository = MockPurchaseRepository();
    usecase = GetPurchaseFrequency(mockRepository);
  });

  group('GetPurchaseFrequency', () {
    test('should return empty map when there are no purchases', () async {
      // Arrange
      when(() => mockRepository.getByDateRange(startDate, endDate))
          .thenAnswer((_) async => []);

      // Act
      final result = await usecase.call(startDate, endDate);

      // Assert
      expect(result, isEmpty);
      verify(() => mockRepository.getByDateRange(startDate, endDate)).called(1);
    });

    test('should count correctly by month in YYYY-MM format', () async {
      // Arrange
      final purchases = [
        Purchase(
          id: 'p-1',
          date: DateTime(2026, 1, 10),
          type: PurchaseType.main,
        ),
        Purchase(
          id: 'p-2',
          date: DateTime(2026, 3, 5),
          type: PurchaseType.midMonth,
        ),
      ];
      when(() => mockRepository.getByDateRange(startDate, endDate))
          .thenAnswer((_) async => purchases);

      // Act
      final result = await usecase.call(startDate, endDate);

      // Assert
      expect(result.length, 2);
      expect(result['2026-01'], 1);
      expect(result['2026-03'], 1);
    });

    test('should group purchases of the same month', () async {
      // Arrange
      final purchases = [
        Purchase(
          id: 'p-1',
          date: DateTime(2026, 2, 1),
          type: PurchaseType.main,
        ),
        Purchase(
          id: 'p-2',
          date: DateTime(2026, 2, 15),
          type: PurchaseType.midMonth,
        ),
        Purchase(
          id: 'p-3',
          date: DateTime(2026, 2, 28),
          type: PurchaseType.main,
        ),
        Purchase(
          id: 'p-4',
          date: DateTime(2026, 4, 10),
          type: PurchaseType.main,
        ),
      ];
      when(() => mockRepository.getByDateRange(startDate, endDate))
          .thenAnswer((_) async => purchases);

      // Act
      final result = await usecase.call(startDate, endDate);

      // Assert
      expect(result.length, 2);
      expect(result['2026-02'], 3);
      expect(result['2026-04'], 1);
    });

    test('should pad single-digit months with leading zero', () async {
      // Arrange
      final purchases = [
        Purchase(
          id: 'p-1',
          date: DateTime(2026, 1, 5),
          type: PurchaseType.main,
        ),
        Purchase(
          id: 'p-2',
          date: DateTime(2026, 12, 20),
          type: PurchaseType.main,
        ),
      ];
      when(() => mockRepository.getByDateRange(startDate, endDate))
          .thenAnswer((_) async => purchases);

      // Act
      final result = await usecase.call(startDate, endDate);

      // Assert
      expect(result.containsKey('2026-01'), isTrue);
      expect(result.containsKey('2026-12'), isTrue);
      expect(result.containsKey('2026-1'), isFalse);
    });
  });
}
