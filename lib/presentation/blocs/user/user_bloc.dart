import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/cupertino.dart';
import 'package:walveroScanner/domain/usecases/user/refresh_token_usecase.dart';
import 'package:walveroScanner/domain/usecases/user/sign_out_usecase.dart' show SignOutUseCase;
import 'package:walveroScanner/domain/usecases/user/sign_up_usecase.dart' show SignUpParams, SignUpUseCase;

import '../../../core/error/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../../../data/models/user/saved_account_model.dart' show SavedAccount, SavedAccountToUser;
import '../../../domain/entities/user/user.dart';
import '../../../data/data_sources/local/user_local_data_source.dart';
import '../../../domain/usecases/user/get_local_user_usecase.dart';
import '../../../domain/usecases/user/sign_in_usecase.dart';

part 'user_event.dart';
part 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final GetLocalUserUseCase _getCachedUserUseCase;
  final SignInUseCase _signInUseCase;
  final SignUpUseCase _signUpUseCase;
  final SignOutUseCase _signOutUseCase;
  final RefreshTokenUseCase _refreshTokenUseCase;
  final UserLocalDataSource _localDataSource;

  UserBloc(
    this._signInUseCase,
    this._getCachedUserUseCase,
    this._signOutUseCase,
    this._signUpUseCase,
    this._refreshTokenUseCase,
    this._localDataSource,
  ) : super(UserInitial()) {
    on<SignInUser>(_onSignIn);
    on<SignUpUser>(_onSignUp);
    on<CheckUser>(_onCheckUser);
    on<SignOutUser>(_onSignOut);
    on<RefreshTokenUser>(_onRefreshToken);
    on<SwitchAccount>(_onSwitchAccount);
    on<LoadSavedAccounts>(_onLoadSavedAccounts);
    on<RemoveSavedAccount>(_onRemoveSavedAccount);
    on<SaveAndAddAccount>(_onSaveAndAddAccount);
    on<SaveCurrentAccount>(_onSaveCurrentAccount);
  }

  Future<void> _onSignIn(SignInUser event, Emitter<UserState> emit) async {
    try {
      // Login-dən ƏVVƏL mövcud hesabı save et (token hələ override olmayıb)
      try {
        final hasToken = await _localDataSource.isTokenAvailable();
        debugPrint('[BLOC] _onSignIn: hasToken=$hasToken');
        if (hasToken) {
          debugPrint('[BLOC] _onSignIn: saving current account BEFORE login...');
          await _localDataSource.saveCurrentAccountToList();
        }
      } catch (e) {
        debugPrint('[BLOC] _onSignIn: save before login ERROR: $e');
      }

      emit(UserLoading());
      final result = await _signInUseCase(event.params);
      if (result.isLeft()) {
        debugPrint('[BLOC] _onSignIn: login FAILED');
        result.fold(
          (failure) => emit(UserLoggedFail(failure)),
          (_) {},
        );
      } else {
        final user = result.getOrElse(() => throw Exception());
        debugPrint('[BLOC] _onSignIn: login SUCCESS user=${user.id} (${user.firstName})');
        // Yeni hesabı da listə save et
        try {
          debugPrint('[BLOC] _onSignIn: saving NEW account to list...');
          await _localDataSource.saveCurrentAccountToList();
        } catch (e) {
          debugPrint('[BLOC] _onSignIn: save after login ERROR: $e');
        }
        final accounts = await _localDataSource.getSavedAccounts();
        debugPrint('[BLOC] _onSignIn: emitting UserLogged with ${accounts.length} saved accounts');
        emit(UserLogged(user, savedAccounts: accounts));
      }
    } catch (e) {
      debugPrint('[BLOC] _onSignIn: EXCEPTION: $e');
      emit(UserLoggedFail(ExceptionFailure()));
    }
  }

  Future<void> _onCheckUser(CheckUser event, Emitter<UserState> emit) async {
    try {
      emit(UserLoading());
      final result = await _getCachedUserUseCase(NoParams());
      if (result.isLeft()) {
        result.fold(
          (failure) => emit(UserLoggedFail(failure)),
          (_) {},
        );
      } else {
        final user = result.getOrElse(() => throw Exception());
        final isExpired =
            user.expiration.toUtc().isBefore(DateTime.now().toUtc());
        if (isExpired && user.id.isNotEmpty) {
          add(RefreshTokenUser());
        } else {
          final accounts = await _localDataSource.getSavedAccounts();
          emit(UserLogged(user, savedAccounts: accounts));
        }
      }
    } catch (e) {
      emit(UserLoggedFail(ExceptionFailure()));
    }
  }

  FutureOr<void> _onSignUp(SignUpUser event, Emitter<UserState> emit) async {
    try {
      emit(UserLoading());
      final result = await _signUpUseCase(event.params);
      if (result.isLeft()) {
        result.fold(
          (failure) => emit(UserLoggedFail(failure)),
          (_) {},
        );
      } else {
        final user = result.getOrElse(() => throw Exception());
        final accounts = await _localDataSource.getSavedAccounts();
        emit(UserLogged(user, savedAccounts: accounts));
      }
    } catch (e) {
      emit(UserLoggedFail(ExceptionFailure()));
    }
  }

  Future<void> _onSignOut(SignOutUser event, Emitter<UserState> emit) async {
    try {
      emit(UserLoading());
      // Get current user ID before clearing
      final currentUser = await _localDataSource.getUser();
      final currentUserId = currentUser.id;

      // Remove this account from saved list
      if (currentUserId.isNotEmpty) {
        await _localDataSource.removeSavedAccount(currentUserId);
      }

      // Clear active session
      await _localDataSource.clearCurrentAccountOnly();

      // Check if there are other saved accounts to switch to
      final remaining = await _localDataSource.getSavedAccounts();
      if (remaining.isNotEmpty) {
        await _localDataSource.switchToAccount(remaining.first);
        add(RefreshTokenUser());
      } else {
        emit(UserLoggedOut());
      }
    } catch (e) {
      emit(UserLoggedOut());
    }
  }

  FutureOr<void> _onRefreshToken(
      RefreshTokenUser event, Emitter<UserState> emit) async {
    try {
      final result = await _refreshTokenUseCase(NoParams());
      if (result.isLeft()) {
        emit(UserLoggedOut());
      } else {
        final user = result.getOrElse(() => throw Exception());
        final accounts = await _localDataSource.getSavedAccounts();
        emit(UserLogged(user, savedAccounts: accounts));
      }
    } catch (e) {
      emit(UserLoggedOut());
    }
  }

  Future<void> _onSwitchAccount(
      SwitchAccount event, Emitter<UserState> emit) async {
    try {
      // UserLoading emit etmirik - UI-da logout kimi görünməsin
      final accounts = await _localDataSource.getSavedAccounts();
      final target = accounts.firstWhere(
        (a) => a.userId == event.userId,
        orElse: () => throw Exception('Account not found'),
      );
      await _localDataSource.switchToAccount(target);

      // Birbaşa refresh et - arada UserLoggedOut emit etmə
      final result = await _refreshTokenUseCase(NoParams());
      if (result.isRight()) {
        final user = result.getOrElse(() => throw Exception());
        final updatedAccounts = await _localDataSource.getSavedAccounts();
        emit(UserLogged(user, savedAccounts: updatedAccounts));
      } else {
        // Refresh fail olsa da saved user datası ilə göstər
        final updatedAccounts = await _localDataSource.getSavedAccounts();
        emit(UserLogged(target.toUser(), savedAccounts: updatedAccounts));
      }
    } catch (e) {
      debugPrint('[BLOC] _onSwitchAccount ERROR: $e');
      // Switch fail olsa mövcud state-ə qayıt
      final currentState = state;
      if (currentState is UserLogged) {
        emit(UserLogged(currentState.user, savedAccounts: currentState.savedAccounts));
      }
    }
  }

  Future<void> _onLoadSavedAccounts(
      LoadSavedAccounts event, Emitter<UserState> emit) async {
    final currentState = state;
    if (currentState is UserLogged) {
      final accounts = await _localDataSource.getSavedAccounts();
      emit(UserLogged(currentState.user, savedAccounts: accounts));
    }
  }

  Future<void> _onRemoveSavedAccount(
      RemoveSavedAccount event, Emitter<UserState> emit) async {
    await _localDataSource.removeSavedAccount(event.userId);
    final currentState = state;
    if (currentState is UserLogged) {
      final accounts = await _localDataSource.getSavedAccounts();
      emit(UserLogged(currentState.user, savedAccounts: accounts));
    }
  }

  Future<void> _onSaveAndAddAccount(
      SaveAndAddAccount event, Emitter<UserState> emit) async {
    debugPrint('[BLOC] _onSaveAndAddAccount: START');
    // Mövcud hesabı save et, sonra yalnız aktiv sessiyadan çıx (saved accounts silinməsin)
    try {
      await _localDataSource.saveCurrentAccountToList();
      debugPrint('[BLOC] _onSaveAndAddAccount: save OK');
    } catch (e) {
      debugPrint('[BLOC] _onSaveAndAddAccount: save ERROR: $e');
    }
    // clearCache çağırma - saved accounts silinər!
    // Yalnız aktiv token/user sil
    debugPrint('[BLOC] _onSaveAndAddAccount: clearing current account only...');
    await _localDataSource.clearCurrentAccountOnly();
    final afterAccounts = await _localDataSource.getSavedAccounts();
    debugPrint('[BLOC] _onSaveAndAddAccount: after clear, saved=${afterAccounts.length}');
    emit(UserLoggedOut());
  }

  Future<void> _onSaveCurrentAccount(
      SaveCurrentAccount event, Emitter<UserState> emit) async {
    // Yalnız save et, state dəyişdirmə - UI navigate edəcək
    try {
      await _localDataSource.saveCurrentAccountToList();
    } catch (_) {}
  }
}
