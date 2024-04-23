import 'package:flutter/material.dart';
import 'package:platform/platform.dart';

class StaticClass {
  static String getPlataforma() {
    const platform = LocalPlatform();
    String plataforma = '';
    if (platform.isAndroid) {
      plataforma = 'android';
    } else if (platform.isIOS) {
      plataforma = 'ios';
    }
    return plataforma;
  }

  static Color get primaryColor {
    return const Color(0xFF5265FF);
  }

  static Color get fontDarkColor {
    return const Color(0xFF4F4F4F);
  }

  static Color get fontColor {
    return const Color(0xFF828282);
  }

  static Color get buttonColor {
    return const Color(0xFF3A4EEA);
  }

  static Color get buttonDarkColor {
    return const Color(0xFF243090);
  }

  static Color get buttonLightColor {
    return const Color(0xFFF4F6FF);
  }

  static Color get boderColor {
    return const Color(0xFF5262E4);
  }

  static Color get backGroundLight {
    return const Color(0xFFF5F5F5);
  }

  static Color get fontAppBarDarkColor {
    return const Color(0xFF333333);
  }

  static Color get secondaryColor {
    return const Color.fromRGBO(10, 135, 80, 1.0);
  }
}
