import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:oktoast/oktoast.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import 'core/constant/strings.dart';
import 'core/router/app_router.dart';
import 'core/services/locale_provider.dart';
import 'core/theme/app_theme.dart';
import 'l10n/app_localizations.dart';

import 'core/services/services_locator.dart' as di;
import 'presentation/blocs/home/navbar_cubit.dart';

import 'presentation/blocs/redeem/redeem_bloc.dart';
import 'presentation/blocs/user/user_bloc.dart';

late LocaleProvider localeProvider;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();

  final prefs = await SharedPreferences.getInstance();
  localeProvider = LocaleProvider(prefs);

  runApp(const MyApp());
  configLoading();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => NavbarCubit(),
        ),
        BlocProvider(
          create: (context) => di.sl<UserBloc>()..add(CheckUser()),
        ),
        BlocProvider(
          create: (context) => di.sl<RedeemBloc>(),
        ),
      ],
      child: OKToast(
        child: Sizer(builder: (context, orientation, deviceType) {
          return ListenableBuilder(
            listenable: localeProvider,
            builder: (context, _) {
              return MaterialApp(
                debugShowCheckedModeBanner: false,
                initialRoute: AppRouter.home,
                onGenerateRoute: AppRouter.onGenerateRoute,
                title: appTitle,
                theme: AppTheme.lightTheme,
                locale: localeProvider.locale,
                supportedLocales: LocaleProvider.supportedLocales,
                localizationsDelegates: const [
                  AppLocalizations.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                builder: EasyLoading.init(),
              );
            },
          );
        }),
      ),
    );
  }
}

void configLoading() {
  EasyLoading.instance
    ..displayDuration = const Duration(milliseconds: 2500)
    ..indicatorType = EasyLoadingIndicatorType.fadingCircle
    ..loadingStyle = EasyLoadingStyle.custom
    ..indicatorSize = 45.0
    ..radius = 10.0
    ..progressColor = Colors.white
    ..backgroundColor = Colors.black
    ..indicatorColor = Colors.white
    ..textColor = Colors.white
    ..userInteractions = false
    ..maskType = EasyLoadingMaskType.black
    ..dismissOnTap = false;
}
