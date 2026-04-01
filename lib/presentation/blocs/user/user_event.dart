part of 'user_bloc.dart';

@immutable
abstract class UserEvent {}

class SignInUser extends UserEvent {
  final SignInParams params;
  SignInUser(this.params);
}

class SignUpUser extends UserEvent {
  final SignUpParams params;
  SignUpUser(this.params);
}

class SignOutUser extends UserEvent {}

class CheckUser extends UserEvent {}

class RefreshTokenUser extends UserEvent {}

class SwitchAccount extends UserEvent {
  final String userId;
  SwitchAccount(this.userId);
}

class LoadSavedAccounts extends UserEvent {}

class RemoveSavedAccount extends UserEvent {
  final String userId;
  RemoveSavedAccount(this.userId);
}

class SaveAndAddAccount extends UserEvent {}

class SaveCurrentAccount extends UserEvent {}
