
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../presentation/blocs/user/user_bloc.dart';
import '../../presentation/views/authentication/access_denied.dart';
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
        // 1) Login olmayıbsa → login səhifəsi
        if (state is! UserLogged) {
          return const SignInView();
        }
       final DateTime expirationDateUtc = state.user.expiration!.toUtc(); // Assuming state.user.expiration is a DateTime


     final DateTime nowUtc = DateTime.now().toUtc(); 


      final bool isExpired = expirationDateUtc.isBefore(nowUtc);

        // 2) Login olub → rollara baxırıq
        final roles = state.user.roles;
        final hasAccess =
            roles.any((r) => allowedRoles.contains(r)); // kəsişmə varsa

        if (!hasAccess || isExpired ) {
           context.read<UserBloc>().add(SignOutUser());
        }

        // 3) Hamısı qaydasındadır → əsl səhifəni göstər
        return child;
      },
    );
  }
}
