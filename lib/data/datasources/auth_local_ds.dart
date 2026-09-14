import 'package:shared_preferences/shared_preferences.dart';
import '../models/auth/app_user_model.dart';

class AuthLocalDs {
  static const _idKey = 'auth_user_id';
  static const _emailKey = 'auth_user_email';
  static const _nameKey = 'auth_user_name';

  Future<AppUserModel?> getCachedUser() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString(_idKey);
    if (id == null) return null;
    return AppUserModel(
      id: id,
      email: prefs.getString(_emailKey) ?? '',
      name: prefs.getString(_nameKey) ?? '',
    );
  }

  Future<void> cacheUser(AppUserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_idKey, user.id);
    await prefs.setString(_emailKey, user.email);
    await prefs.setString(_nameKey, user.name);
  }

  Future<void> clearCachedUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_idKey);
    await prefs.remove(_emailKey);
    await prefs.remove(_nameKey);
  }
}
