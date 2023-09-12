import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController? controller;
  final IconData? icon;
  final String? lableText;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final bool isObscure;
  final bool enabled;

  const CustomTextField({
    Key? key,
    @required this.controller,
    @required this.icon,
    @required this.lableText,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.isObscure = false,
    this.enabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        obscureText: isObscure,
        enabled: enabled,
        decoration: InputDecoration(
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(5),
            ),
          ),
          labelText: lableText,
          prefixIcon: Icon(
            icon,
            color: Colors.cyan,
          ),
        ),
      ),
    );
  }
}
