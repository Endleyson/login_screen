import 'dart:async';

import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:login_screen/app_localizations.dart';
import 'package:provider/provider.dart' as provider;
import 'package:login_screen/app_language.dart';
import 'package:login_screen/service/auth_service.dart';
import 'package:login_screen/service/router_service.dart';
import 'bloc/login_bloc.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AppLanguage appLanguage = AppLanguage();
  await appLanguage.fetchLocale();

  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

  runApp(App(
    appLanguage: appLanguage,
  ));
}

class App extends StatelessWidget {
  final AppLanguage? appLanguage;

  const App({super.key, this.appLanguage});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        blocs: [
          Bloc((i) => LoginBloc()),
        ],
        dependencies: const [],
        child: provider.ChangeNotifierProvider<AppLanguage>(
          create: (_) => appLanguage!,
          builder: (context, model) {
            return MaterialApp(
              navigatorKey: navigatorKey,
              debugShowCheckedModeBanner: false,
              title: 'Login with bloc',
              initialRoute: RouterService.firstPage,
              localizationsDelegates: const [
                S.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: const [
                Locale('en'),
                Locale('pt'),
                Locale('es'),
                Locale('fr')
              ],
              onGenerateRoute: RouterService.generateRoute,
              theme: Theme.of(context).copyWith(
                appBarTheme: Theme.of(context).appBarTheme.copyWith(
                      systemOverlayStyle: SystemUiOverlayStyle.dark,
                    ),
                visualDensity: VisualDensity.adaptivePlatformDensity,
                primaryColor: Colors.blue.shade800,
                bottomAppBarTheme:
                    BottomAppBarTheme(color: Colors.blue.shade800),
                elevatedButtonTheme: ElevatedButtonThemeData(
                    style: TextButton.styleFrom(
                        minimumSize: const Size(150, 50),
                        backgroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: const BorderRadius.all(
                              Radius.circular(20),
                            ),
                            side: BorderSide(
                              color: Colors.blue.shade800.withOpacity(0.7),
                              width: 2.5,
                            )))),
                inputDecorationTheme: const InputDecorationTheme(
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.blueGrey,
                        width: 2,
                      ),
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.blueGrey,
                        width: 1,
                      ),
                    )),
              ),
            );
          },
        ));
  }
}
