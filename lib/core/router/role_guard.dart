import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../presentation/blocs/user/user_bloc.dart';
import '../../presentation/views/authentication/signin_view.dart';

class RoleGuard extends StatelessWidget {
  final Widget child;
  final List<String> allowedRoles;

  const RoleGuard({
    super.key,
    required this.child,
    required this.allowedRoles,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserBloc, UserState>(
      builder: (context, state) {
        if (state is UserLoggedOut || state is UserLoggedFail) {
          return const SignInView();
        }

        if (state is! UserLogged) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final DateTime expirationDateUtc = state.user.expiration.toUtc();
        final DateTime nowUtc = DateTime.now().toUtc();
        final bool isExpired = expirationDateUtc.isBefore(nowUtc);

        if (isExpired) {
          // Token bitib → refresh etməyə çalış
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.read<UserBloc>().add(RefreshTokenUser());
          });
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final roles = state.user.roles;
        final hasAccess = roles.any((r) => allowedRoles.contains(r));

        if (!hasAccess) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.read<UserBloc>().add(SignOutUser());
          });
          return const SignInView();
        }

        return child;
      },
    );
  }
}
