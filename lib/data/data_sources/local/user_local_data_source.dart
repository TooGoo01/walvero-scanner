import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/error/exceptions.dart';
import '../../models/user/saved_account_model.dart';
import '../../models/user/user_model.dart';

abstract class UserLocalDataSource {
  Future<String> getToken();
  Future<UserModel> getUser();
  Future<void> saveToken(String token);
  Future<void> saveUser(UserModel user);
  Future<void> clearCache();
  Future<bool> isTokenAvailable();
  Future<void> saveRefreshToken(String refreshToken, DateTime expiration);
  Future<String?> getRefreshToken();
  Future<DateTime?> getRefreshTokenExpiration();
  Future<void> saveSelectedProgramId(int programId);
  Future<int?> getSelectedProgramId();

  // Multi-account
  Future<List<SavedAccount>> getSavedAccounts();
  Future<void> saveCurrentAccountToList();
  Future<void> removeSavedAccount(String userId);
  Future<void> switchToAccount(SavedAccount account);
  Future<void> clearCurrentAccountOnly();
}

const cachedToken = 'TOKEN';
const cachedRefreshToken = 'REFRESH_TOKEN';
const cachedRefreshTokenExpiration = 'REFRESH_TOKEN_EXPIRATION';
const cachedUser = 'USER';
const cachedSavedAccounts = 'SAVED_ACCOUNTS';

class UserLocalDataSourceImpl implements UserLocalDataSource {
  final FlutterSecureStorage secureStorage;
  final SharedPreferences sharedPreferences;
  UserLocalDataSourceImpl(
      {required this.sharedPreferences, required this.secureStorage});

  @override
  Future<String> getToken() async {
    String? token = await secureStorage.read(key: cachedToken);
    if (token != null) {
      return Future.value(token);
    } else {
      throw CacheException();
    }
  }

  @override
  Future<void> saveToken(String token) async {
    await secureStorage.write(key: cachedToken, value: token);
  }

  @override
  Future<void> saveRefreshToken(String refreshToken, DateTime expiration) async {
    await secureStorage.write(key: cachedRefreshToken, value: refreshToken);
    await secureStorage.write(
      key: cachedRefreshTokenExpiration,
      value: expiration.toIso8601String(),
    );
  }

  @override
  Future<String?> getRefreshToken() async {
    return await secureStorage.read(key: cachedRefreshToken);
  }

  @override
  Future<DateTime?> getRefreshTokenExpiration() async {
    final expStr = await secureStorage.read(key: cachedRefreshTokenExpiration);
    if (expStr != null) {
      return DateTime.parse(expStr);
    }
    return null;
  }

  @override
  Future<UserModel> getUser() async {
    if (sharedPreferences.getBool('first_run') ?? true) {
      await secureStorage.deleteAll();
      sharedPreferences.setBool('first_run', false);
    }
    final jsonString = sharedPreferences.getString(cachedUser);
    if (jsonString != null) {
      return Future.value(userModelFromJson(jsonString));
    } else {
      return UserModel.empty();
    }
  }

  @override
  Future<void> saveUser(UserModel user) {
    return sharedPreferences.setString(
      cachedUser,
      userModelToJson(user),
    );
  }

  @override
  Future<bool> isTokenAvailable() async {
    String? token = await secureStorage.read(key: cachedToken);
    return Future.value((token != null));
  }

  @override
  Future<void> saveSelectedProgramId(int programId) async {
    await sharedPreferences.setInt('SELECTED_PROGRAM_ID', programId);
  }

  @override
  Future<int?> getSelectedProgramId() async {
    return sharedPreferences.getInt('SELECTED_PROGRAM_ID');
  }

  @override
  Future<void> clearCache() async {
    debugPrint('[MULTI-ACC] clearCache: FULL CLEAR - deleteAll secure storage + remove user');
    await secureStorage.deleteAll();
    await sharedPreferences.remove(cachedUser);
    await sharedPreferences.remove('SELECTED_PROGRAM_ID');
    // SAVED_ACCOUNTS-a TOXUNMA - multi-account üçün lazımdır
  }

  // ─── Multi-Account ────────────────────────────────────

  @override
  Future<List<SavedAccount>> getSavedAccounts() async {
    final jsonString = sharedPreferences.getString(cachedSavedAccounts);
    debugPrint('[MULTI-ACC] getSavedAccounts: raw=${jsonString != null ? "${jsonString.length} chars" : "NULL"}');
    if (jsonString == null || jsonString.isEmpty) return [];
    try {
      final list = SavedAccount.listFromJson(jsonString);
      debugPrint('[MULTI-ACC] getSavedAccounts: count=${list.length} [${list.map((a) => "${a.userId}:${a.displayName}").join(", ")}]');
      return list;
    } catch (e) {
      debugPrint('[MULTI-ACC] getSavedAccounts: PARSE ERROR: $e');
      return [];
    }
  }

  @override
  Future<void> saveCurrentAccountToList() async {
    final token = await secureStorage.read(key: cachedToken);
    final refreshToken = await secureStorage.read(key: cachedRefreshToken);
    final refreshExpStr = await secureStorage.read(key: cachedRefreshTokenExpiration);
    final userJson = sharedPreferences.getString(cachedUser);

    debugPrint('[MULTI-ACC] saveCurrentAccountToList: token=${token != null ? "YES" : "NULL"}, userJson=${userJson != null ? "YES" : "NULL"}');

    if (token == null || userJson == null) {
      debugPrint('[MULTI-ACC] saveCurrentAccountToList: SKIP - token or user null');
      return;
    }

    final user = userModelFromJson(userJson);
    debugPrint('[MULTI-ACC] saveCurrentAccountToList: saving user=${user.id} (${user.firstName} ${user.lastName})');

    final selectedProgramId = sharedPreferences.getInt('SELECTED_PROGRAM_ID') ?? user.programId;

    final account = SavedAccount(
      userId: user.id,
      userName: user.userName,
      firstName: user.firstName,
      lastName: user.lastName,
      email: user.email,
      image: user.image,
      token: token,
      refreshToken: refreshToken,
      refreshTokenExpiration:
          refreshExpStr != null ? DateTime.tryParse(refreshExpStr) : null,
      roles: user.roles,
      tenantId: user.tenantId,
      programId: selectedProgramId,
    );

    final accounts = await getSavedAccounts();
    debugPrint('[MULTI-ACC] saveCurrentAccountToList: existing accounts=${accounts.length} [${accounts.map((a) => a.userId).join(", ")}]');
    // Remove if already exists, then add updated version
    accounts.removeWhere((a) => a.userId == account.userId);
    accounts.add(account);

    debugPrint('[MULTI-ACC] saveCurrentAccountToList: after add=${accounts.length} [${accounts.map((a) => a.userId).join(", ")}]');

    await sharedPreferences.setString(
      cachedSavedAccounts,
      SavedAccount.listToJson(accounts),
    );
  }

  @override
  Future<void> removeSavedAccount(String userId) async {
    final accounts = await getSavedAccounts();
    accounts.removeWhere((a) => a.userId == userId);
    await sharedPreferences.setString(
      cachedSavedAccounts,
      SavedAccount.listToJson(accounts),
    );
    // Also remove stored tokens for this account
    await secureStorage.delete(key: 'TOKEN_$userId');
    await secureStorage.delete(key: 'REFRESH_TOKEN_$userId');
  }

  @override
  Future<void> switchToAccount(SavedAccount account) async {
    // Save current account first (only if token exists)
    final currentToken = await secureStorage.read(key: cachedToken);
    if (currentToken != null) {
      try {
        await saveCurrentAccountToList();
      } catch (_) {}
    }

    // Set new active token
    await secureStorage.write(key: cachedToken, value: account.token);
    if (account.refreshToken != null) {
      await secureStorage.write(key: cachedRefreshToken, value: account.refreshToken!);
    }
    if (account.refreshTokenExpiration != null) {
      await secureStorage.write(
        key: cachedRefreshTokenExpiration,
        value: account.refreshTokenExpiration!.toIso8601String(),
      );
    }

    // Set new active user in SharedPreferences
    final userModel = UserModel(
      id: account.userId,
      userName: account.userName,
      firstName: account.firstName,
      lastName: account.lastName,
      email: account.email ?? '',
      expiration: DateTime.now().add(const Duration(hours: 1)),
      roles: account.roles,
      tenantId: account.tenantId,
      programId: account.programId,
      image: account.image,
    );
    await sharedPreferences.setString(cachedUser, userModelToJson(userModel));

    // Restore selected program ID from saved account
    if (account.programId != null) {
      await sharedPreferences.setInt('SELECTED_PROGRAM_ID', account.programId!);
    } else {
      await sharedPreferences.remove('SELECTED_PROGRAM_ID');
    }
  }

  @override
  Future<void> clearCurrentAccountOnly() async {
    debugPrint('[MULTI-ACC] clearCurrentAccountOnly: clearing active session only');
    final savedBefore = sharedPreferences.getString(cachedSavedAccounts);
    debugPrint('[MULTI-ACC] clearCurrentAccountOnly: savedAccounts BEFORE=${savedBefore != null ? "${savedBefore.length} chars" : "NULL"}');
    // Yalnız aktiv sessiya silinir, saved accounts listinə TOXUNMUR
    await secureStorage.delete(key: cachedToken);
    await secureStorage.delete(key: cachedRefreshToken);
    await secureStorage.delete(key: cachedRefreshTokenExpiration);
    await sharedPreferences.remove(cachedUser);
    await sharedPreferences.remove('SELECTED_PROGRAM_ID');
    final savedAfter = sharedPreferences.getString(cachedSavedAccounts);
    debugPrint('[MULTI-ACC] clearCurrentAccountOnly: savedAccounts AFTER=${savedAfter != null ? "${savedAfter.length} chars" : "NULL"}');
  }

}
