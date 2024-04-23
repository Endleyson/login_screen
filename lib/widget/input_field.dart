import 'package:flutter/material.dart';

import '../helper_color.dart';

class InputField extends StatelessWidget {
  final TextInputType? keyboardType;
  final IconData? icon;
  final String? labelText;
  final bool? obscure;
  final Stream<String>? stream;
  final Function(String)? onChanged;
  final int? minLines;
  final int? maxLines;

  const InputField(
      {super.key,
      this.keyboardType,
      this.icon,
      this.labelText,
      this.obscure,
      this.stream,
      this.minLines,
      this.maxLines,
      this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextField(
      minLines: minLines ?? 1,
      maxLines: maxLines ?? 1,
      keyboardType: keyboardType ?? TextInputType.text,
      obscureText: obscure!,
      onChanged: onChanged,
      decoration: InputDecoration(
        filled: true,
        fillColor: StaticClass.buttonLightColor,
        errorStyle: TextStyle(
            fontFamily: "Roboto",
            fontSize: MediaQuery.of(context).size.height * 0.02,
            color: Colors.red[200]),
        prefixIcon: Icon(
          icon,
          color: StaticClass.fontColor,
          size: MediaQuery.of(context).size.height * 0.025,
        ),
        hintStyle:
            TextStyle(fontFamily: "Roboto", color: StaticClass.fontColor),
        hintText: labelText,
        border: const OutlineInputBorder(),
        enabledBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(20),
            ),
            borderSide: BorderSide(
              color: Colors.transparent,
            )),
        focusedBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(20),
            ),
            borderSide: BorderSide(
              color: Colors.transparent,
            )),
      ),
      style: TextStyle(
        fontFamily: "Roboto",
        color: StaticClass.fontColor,
        fontSize: MediaQuery.of(context).size.height * 0.02,
      ),
    );
  }
}
