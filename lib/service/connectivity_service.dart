import 'dart:io';

class ConnectivityService {
  static final ConnectivityService instance = ConnectivityService._internal();

  ConnectivityService._internal() : super();

  Future<bool> hasInternet() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      }
      return false;
    } on SocketException catch (_) {
      return false;
    }
  }
}
