// ignore_for_file: prefer_conditional_assignment

import 'dart:async';
import 'dart:convert';

import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/material.dart';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:login_screen/configuration.dart';
import 'package:login_screen/model/authentication.dart';
import 'package:login_screen/service/auth_service.dart';
import 'package:login_screen/service/connectivity_service.dart';
import 'package:platform/platform.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../validator/login_validator.dart';

// ignore_for_file: unnecessary_null_comparison

enum LoginState {
  idle,
  loading,
  success,
  fail,
  passwordWrong,
  sso,
  recoveryPassError,
  recoveryOK,
  emailEmpty,
  passwordEmpty
}

enum LoginPageState { auth, forgot }

class LoginBloc extends BlocBase with LoginValidator {
  static const googleClientIdAndroid = "inser your googleClientIdAndroid ";
  static const googleClientIdIOS = "inser your googleClientIdIOS ";

  static const azureClientId = "inser your azureClientId ";

  final GoogleSignIn googleSignIn = GoogleSignIn(
    clientId: const LocalPlatform().isIOS ? googleClientIdIOS : null,
    // serverClientId: const LocalPlatform().isIOS ? null : googleClientIdAndroid,
    scopes: ['email'],
  );

  final _emailController = BehaviorSubject<String>();
  final _emailCpfController = BehaviorSubject<String>();
  final _passwordController = BehaviorSubject<String>();
  final _rememberPasswordController = BehaviorSubject<bool>();
  final _stateController = BehaviorSubject<LoginState>();
  final _authenticationController = BehaviorSubject<Authentication>();
  final _pageStateController = BehaviorSubject<LoginPageState>();

  Stream<String> get outEmail =>
      _emailController.stream.transform(emailValidate);

  Stream<String> get outEmailCpf => _emailCpfController.stream;

  Stream<String> get outPassword =>
      _passwordController.stream.transform(passwordValidate);

  Stream<bool> get outRememberPassword => _rememberPasswordController.stream;

  Stream<LoginState> get outState => _stateController.stream;

  Stream<bool> get outSubmitValid =>
      Rx.combineLatest2(outEmailCpf, outPassword, (a, b) => true);

  Function(String) get changeEmail => _emailController.sink.add;

  Function(String) get changeEmailCpf => _emailCpfController.sink.add;

  Function(String) get changePassword => _passwordController.sink.add;

  Function(bool) get changeRememberPassword =>
      _rememberPasswordController.sink.add;

  String get emailCpf => _emailCpfController.value;
  String get password => _passwordController.value;

  Stream<Authentication> get outAuthentication =>
      _authenticationController.stream;

  Stream<LoginPageState> get outPageState => _pageStateController.stream;

  LoginPageState get valuePageState => _pageStateController.value;

  set pageState(LoginPageState value) => _pageStateController.sink.add(value);

  set loginState(LoginState value) => _stateController.sink.add(value);

  void setRememberPasswordController(bool value) {
    _rememberPasswordController.sink.add(value);
  }

  Future<bool> isRememberPasswordEnabled() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    if (!sharedPreferences.containsKey('rememberPassword')) return false;

    try {
      bool? value = sharedPreferences.getBool('rememberPassword');
      _rememberPasswordController.sink.add(value!);
      return value;
    } catch (e) {
      return false;
    }
  }

  void setRememberPassword(bool value) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setBool('rememberPassword', value);
  }

  Future<Authentication?> _loadSavedPassword() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    if (sharedPreferences.containsKey('auth')) {
      final authSaved = sharedPreferences.getString('auth');
      if (authSaved != null && authSaved.isNotEmpty) {
        return Authentication.fromJson(json.decode(authSaved));
      }
    }
    return null;
  }

  void submit(
      {required bool loadPassword,
      required bool withGoogle,
      required bool withAzure}) async {
    String? email;
    String? password;

    _stateController.add(LoginState.loading);

    var hasInternet = await ConnectivityService.instance.hasInternet();
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    final authService = AuthService();
    Authentication authentication = Authentication();

    if (withGoogle) {
      try {
        final user = loadPassword
            ? await googleSignIn.signInSilently()
            : await googleSignIn.signIn();
        if (user != null) {
          email = user.email;
          password = user.id;
          authentication =
              (await authService.signInWithGoogle(user.email, user.id));
        } else {
          authentication.status = false;
          _stateController.add(LoginState.sso);
        }
      } catch (e) {
        debugPrint("-=-=-=-=-=-= $e");
        _stateController.add(LoginState.sso);
      }
    } else if (withAzure) {
      try {
        authentication = (await authService.signInWithAzure(azureClientId));

        if (authentication == null) {
          _stateController.add(LoginState.fail);
        }
        email = sharedPreferences.getString(Configuration.azureEmail);
      } catch (e) {
        debugPrint("+ >>> $e");
        _stateController.add(LoginState.sso);
      }
    } else {
      if (loadPassword) {
        final authentication = await _loadSavedPassword();
        email = authentication!.email;
        password = authentication.password;
      } else {
        email = _emailCpfController.value;
        password = _passwordController.value;
      }

      if (email!.isEmpty) {
        _stateController.add(LoginState.emailEmpty);
        return;
      }

      if (password!.isEmpty) {
        _stateController.add(LoginState.passwordEmpty);
        return;
      }

      if (hasInternet) {
        authentication = (await authService.signIn(email, password));
      } else {
        authentication.status = false;
      }
    }

    if (authentication == null || !authentication.status!) {
      await googleSignIn.signOut();

      setRememberPassword(false);
      _emailCpfController.add("");
      _passwordController.add("");
      if (authentication.message != null &&
          authentication.message!.toLowerCase().contains(
              "invalid authentication credentials / wrong password")) {
        _stateController.add(LoginState.passwordWrong);
      } else if (authentication.message != null &&
          authentication.message!.toLowerCase().contains("user not found")) {
        _stateController.add(LoginState.passwordWrong);
      } else {
        _stateController.add(LoginState.fail);
      }
    } else {
      authentication.email = email!;
      authentication.password = password!;
      await sharedPreferences.setString(
          'auth', json.encode(authentication.toJson()));

      try {
        if (_rememberPasswordController.value) setRememberPassword(true);
      } catch (e) {
        setRememberPassword(false);
      }

      _authenticationController.sink.add(authentication);
      _stateController.add(LoginState.success);
    }
  }

  Future logout() async {
    setRememberPassword(false);
    _stateController.add(LoginState.idle);

    _emailCpfController.add("");
    _passwordController.add("");
    _rememberPasswordController.add(false);

    var isSignedIn = await googleSignIn.isSignedIn();
    if (isSignedIn) await googleSignIn.signOut();
  }

  Future<bool> resetSenha() async {
    String email = _emailCpfController.value;

    _stateController.add(LoginState.loading);
    _pageStateController.add(LoginPageState.forgot);

    if (email.isEmpty || email == null) {
      _stateController.add(LoginState.emailEmpty);
      return false;
    }

    var hasInternet = await ConnectivityService.instance.hasInternet();
    if (hasInternet) {
      final authService = AuthService();
      var result = await authService.resetPassoword(email);
      if (!result) {
        _stateController.add(LoginState.recoveryPassError);
        return false;
      }
      if (result) {
        _stateController.add(
          LoginState.recoveryOK,
        );
        return result;
      }
    }
    _stateController.add(LoginState.fail);
    return false;
  }

  emptyFilds() {
    _emailCpfController.add("");
    _passwordController.add("");
  }

  @override
  void dispose() {
    _emailController.close();
    _emailCpfController.close();
    _passwordController.close();
    _stateController.close();

    _authenticationController.close();
    _rememberPasswordController.close();
    _pageStateController.close();

    super.dispose();
  }
}
