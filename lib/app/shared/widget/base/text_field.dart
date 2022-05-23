import 'package:altme/theme/theme.dart';
import 'package:flutter/material.dart';

class BaseTextField extends StatelessWidget {
  const BaseTextField({
    Key? key,
    this.label,
    required this.controller,
    this.icon = Icons.edit,
    this.type = TextInputType.text,
    this.textCapitalization = TextCapitalization.none,
    this.error,
    this.prefixIcon,
    this.prefixConstraint,
    this.validator,
    this.focusNode,
  }) : super(key: key);

  final String? label;
  final TextEditingController controller;
  final IconData icon;
  final TextInputType type;
  final TextCapitalization textCapitalization;
  final String? error;
  final Widget? prefixIcon;
  final BoxConstraints? prefixConstraint;
  final String? Function(String?)? validator;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        right: 24,
        left: prefixIcon != null ? 0 : 24,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(color: Theme.of(context).colorScheme.borderColor),
      ),
      child: TextFormField(
        focusNode: focusNode,
        controller: controller,
        cursorColor: Theme.of(context).colorScheme.secondaryContainer,
        keyboardType: type,
        maxLines: 1,
        textCapitalization: textCapitalization,
        style: Theme.of(context).textTheme.bodyText1!.copyWith(fontSize: 17),
        validator: validator,
        decoration: InputDecoration(
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          focusedErrorBorder: InputBorder.none,
          fillColor: Theme.of(context).colorScheme.primary,
          hoverColor: Theme.of(context).colorScheme.primary,
          focusColor: Theme.of(context).colorScheme.primary,
          errorText: error,
          labelText: label,
          labelStyle: Theme.of(context).textTheme.bodyText1,
          prefixIcon: prefixIcon,
          prefixIconConstraints: prefixConstraint,
          suffixIcon: Icon(
            icon,
            color: Theme.of(context).colorScheme.secondaryContainer,
          ),
        ),
      ),
    );
  }
}
