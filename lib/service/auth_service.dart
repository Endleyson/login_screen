// ignore_for_file: unnecessary_null_comparison, unused_local_variable

import 'dart:convert';

import 'package:aad_oauth/model/config.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:login_screen/helper_color.dart';
import 'package:login_screen/model/authentication.dart';
import 'package:login_screen/model/azure.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aad_oauth/aad_oauth.dart';

import '../configuration.dart';

final navigatorKey = GlobalKey<NavigatorState>();

class AuthService {
  Future<Authentication> signIn(String? email, String? password) async {
    if (email!.isNotEmpty && password!.isNotEmpty) {
      Map<String, dynamic> body = {
        'email': email,
        'password': password,
        'version': Configuration.version,
      };
      try {
        http.Response response = await http
            .post(Uri.parse('${Configuration.urlApi}/app/login'),
                headers: {'Content-Type': 'application/x-www-form-urlencoded'},
                body: body)
            .timeout(const Duration(seconds: 10));

        try {
          if (response.statusCode == 200 || response.statusCode == 403) {
            var jsonResponse = json.decode(response.body);
            bool status = jsonResponse.containsKey('status')
                ? jsonResponse['status']
                : false;
            if (!status) {
              var msg = jsonResponse['message'];

              return Authentication(status: status, message: msg.toString());
            }
            return Authentication.fromJson(json.decode(response.body));
          }
        } catch (e) {
          debugPrint("+++++ $e");
          return Authentication(status: false);
        }
      } catch (e) {
        debugPrint("+++++ $e");
        return Authentication(status: false);
      }
    }
    return Authentication();
  }

  // Future<ChangePasswordResponseResult> changePassword(int userId,
  //     String password, String newPassword, String confirmPassword) async {
  //   if (userId > 0 &&
  //       password.isNotEmpty &&
  //       newPassword.isNotEmpty &&
  //       confirmPassword.isNotEmpty) {
  //     Map<String, dynamic> body = {
  //       'user_id': userId,
  //       'password': password,
  //       'new_pwd': newPassword,
  //       'confirm_pwd': confirmPassword,
  //       'version': Configuration.version,
  //     };
  //     String bodyString = json.encode(body);

  //     http.Response response = await http.post(
  //         Uri.parse('${Configuration.urlApi}/app/changepwd'),
  //         headers: {'Content-Type': 'application/json'},
  //         body: bodyString);

  //     if (response.statusCode == 200) {
  //       return ChangePasswordResponseResult.fromJson(
  //           json.decode(response.body));
  //     }
  //   }
  //   return ChangePasswordResponseResult();
  // }

  Future<bool> resetPassoword(String email) async {
    if (email == null || email.isEmpty) return false;

    Map<String, dynamic> body = {
      'email': email,
      'version': Configuration.version,
    };
    String bodyString = json.encode(body);
    try {
      http.Response response = await http.post(
          Uri.parse('${Configuration.urlApi}/app/resetpwd'),
          headers: {'Content-Type': 'application/json'},
          body: bodyString);

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = json.decode(response.body);

        bool status =
            jsonResponse.containsKey('status') ? jsonResponse['status'] : false;

        return status;
      }

      return false;
    } catch (e) {
      debugPrint("+++++ $e");
      return false;
    }
  }

  Future<Authentication> signInWithGoogle(String email, String googleId) async {
    if (email == null ||
        email.isEmpty ||
        googleId == null ||
        googleId.isEmpty) {}

    Map<String, dynamic> body = {
      'google_email': email,
      'google_id': googleId,
      'platform': StaticClass.getPlataforma(),
      'version': Configuration.version,
    };

    String bodyString = json.encode(body);

    http.Response response = await http.post(
        Uri.parse('${Configuration.urlApi}/app/googleLogin'),
        headers: {'Content-Type': 'application/json'},
        body: bodyString);

    if (response.statusCode == 200 || response.statusCode == 403) {
      Map<String, dynamic> jsonResponse = json.decode(response.body);
      bool status =
          jsonResponse.containsKey('status') ? jsonResponse['status'] : false;
      if (!status) {
        var msg = jsonResponse['message'];

        return Authentication(status: status, message: msg.toString());
      }
      return Authentication.fromJson(json.decode(response.body));
    }

    return Authentication();
  }

  static const uri_ = 'https://graph.microsoft.com/v1.0/me';

  Future<Authentication> signInWithAzure(String azureId) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    final Config authConfig = Config(
        clientId: azureId,
        scope: 'https://graph.microsoft.com/User.Read',
        navigatorKey: navigatorKey,
        loader: const SizedBox(
          child: Center(child: CircularProgressIndicator()),
        ),
        redirectUri: 'https://login.live.com/oauth20_desktop.srf',
        responseType: 'code',
        responseMode: 'query',
        state: '12345',
        tenant: 'common');
    //
    final AadOAuth oauth = AadOAuth(authConfig);
    await oauth.logout();
    await oauth.login();
    final accessToken = await oauth.getAccessToken();
    var response_ = await http.get(Uri.parse(uri_),
        headers: {'authorization': /* 'bearer' + */ accessToken!});

    Azure azureResponse = Azure.fromJson(json.decode(response_.body));

    Map<String, dynamic> body = {
      'microsoft_email': azureResponse.mail,
      'microsoft_id': azureResponse.id,
      'platform': StaticClass.getPlataforma(),
      'version': Configuration.version,
    };
    String bodyString = json.encode(body);

    http.Response response = await http.post(
        Uri.parse('${Configuration.urlApi}/app/microsoftLogin'),
        headers: {'Content-Type': 'application/json'},
        body: bodyString);

    if (response.statusCode == 200 || response.statusCode == 403) {
      Map<String, dynamic> jsonResponse = json.decode(response.body);
      bool status =
          jsonResponse.containsKey('status') ? jsonResponse['status'] : false;
      if (!status) {
        var msg = jsonResponse['message'];

        return Authentication(status: status, message: msg.toString());
      }
      if (!sharedPreferences.containsKey(Configuration.azureEmail)) {
        sharedPreferences.setString(Configuration.azureEmail, "");
      }
      sharedPreferences.setString(
          Configuration.azureEmail, azureResponse.mail!);
      return Authentication.fromJson(json.decode(response.body));
    }

    return Authentication();
  }
}
