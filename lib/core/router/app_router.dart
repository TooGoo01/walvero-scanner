
import 'package:flutter/material.dart';

import '../../domain/entities/user/user.dart';
import '../../presentation/views/authentication/signin_view.dart';
import '../../presentation/views/authentication/signup_view.dart';
import '../../presentation/views/main/main_view.dart';
import '../../presentation/views/main/other/about/about_view.dart';

import '../../presentation/views/main/other/other_view.dart';
import '../../presentation/views/main/other/profile/profile_screen.dart';
import '../../presentation/views/main/other/settings/settings_view.dart';

import '../../presentation/views/scan/scan_barcode_page.dart';
import '../error/exceptions.dart';
import 'role_guard.dart';

class AppRouter {
  //main menu
  static const String home = '/';
  //authentication
  static const String signIn = '/sign-in';
  static const String signUp = '/sign-up';
  static const String scanBarcode = '/scan-barcode';
  //products
  static const String productDetails = '/product-details';
  //other
  static const String userProfile = '/user-profile';
  static const String orderCheckout = '/order-checkout';
  static const String deliveryDetails = '/delivery-details';
  static const String orders = '/orders';
  static const String settings = '/settings';
  static const String notifications = '/notifications';
  static const String about = '/about';
  static const String filter = '/filter';
  static const String other = '/other';


  static Route<dynamic> onGenerateRoute(RouteSettings routeSettings) {
    switch (routeSettings.name) {
      case home:
        return MaterialPageRoute(
          builder: (_) => RoleGuard(
            allowedRoles: const [
              'Super Admin',
              'Tenant Admin',
              'Moderator',
            ],
            child: const MainView(),
          ),
        );
      case signIn:
        return MaterialPageRoute(builder: (_) => const SignInView());
      case other:
        return MaterialPageRoute(builder: (_) => const OtherView());
      case signUp:
        return MaterialPageRoute(builder: (_) => const SignUpScreen());
      case scanBarcode:
        return MaterialPageRoute(builder: (_) => const ScanBarcodePage());
     
      case userProfile:
        User user = routeSettings.arguments as User;
        return MaterialPageRoute(
            builder: (_) => UserProfileScreen(
                  user: user,
                ));
    
      case settings:
        return MaterialPageRoute(builder: (_) => const SettingsView());
      case about:
        return MaterialPageRoute(builder: (_) => const AboutView());
     
      default:
        throw const RouteException('Route not found!');
    }
  }
}
