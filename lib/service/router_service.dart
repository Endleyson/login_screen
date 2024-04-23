import 'package:flutter/material.dart';
import 'package:login_screen/ui/Login_page.dart';
import 'package:login_screen/ui/user_page.dart';

class RouterService {
  static const String loginRoute = '/loginRoute';
  static const String userPage = '/userPage';

  static const String alterarSenhaRoute = '/alterarSenha';

  static const String firstPage = '/';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case loginRoute:
        return MaterialPageRoute(builder: (_) => const LoginPage());

      case userPage:
        return MaterialPageRoute(builder: (_) => const UserPage());

      //   case alterarSenhaRoute:
      //     return MaterialPageRoute(builder: (_) => const AlterarSenhaPage());
      default:
        return MaterialPageRoute(builder: (_) => const LoginPage());
    }
  }
}
