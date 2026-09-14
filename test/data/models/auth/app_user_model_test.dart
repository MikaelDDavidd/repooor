import 'package:flutter_test/flutter_test.dart';
import 'package:repooor/data/models/auth/app_user_model.dart';
import 'package:repooor/domain/entities/auth/app_user.dart';

void main() {
  const entity = AppUser(
    id: 'user-1',
    email: 'mikael@exemplo.com',
    name: 'Mikael',
  );

  group('AppUserModel', () {
    test('should survive a full entity to map and back round trip', () {
      final model = AppUserModel.fromEntity(entity);
      final restored = AppUserModel.fromMap(model.toMap()).toEntity();

      expect(restored, entity);
    });

    test('should expose the entity fields in toMap', () {
      final map = AppUserModel.fromEntity(entity).toMap();

      expect(map, {
        'id': 'user-1',
        'email': 'mikael@exemplo.com',
        'name': 'Mikael',
      });
    });
  });
}
