import 'dart:async';

mixin LoginValidator {
  final emailValidate =
      StreamTransformer<String, String>.fromHandlers(handleData: (email, sink) {
    if (email.contains('@')) {
      sink.add(email);
    } else {
      sink.addError('informe_email_valido');
    }
  });

  final passwordValidate = StreamTransformer<String, String>.fromHandlers(
      handleData: (password, sink) {
    sink.add(password);
  });
}
