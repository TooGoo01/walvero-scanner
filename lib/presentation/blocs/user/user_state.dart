part of 'user_bloc.dart';

@immutable
abstract class UserState extends Equatable {}

class UserInitial extends UserState {
  @override
  List<Object> get props => [];
}

class UserLoading extends UserState {
  @override
  List<Object> get props => [];
}

class UserLogged extends UserState {
  final User user;
  final List<SavedAccount> savedAccounts;
  final int switchTimestamp;
  UserLogged(this.user, {this.savedAccounts = const [], int? switchTimestamp})
      : switchTimestamp = switchTimestamp ?? DateTime.now().millisecondsSinceEpoch;
  @override
  List<Object> get props => [user, savedAccounts, switchTimestamp];
}

class UserLoggedFail extends UserState {
  final Failure failure;
  UserLoggedFail(this.failure);
  @override
  List<Object> get props => [failure];
}

class UserLoggedOut extends UserState {
  @override
  List<Object> get props => [];
}
