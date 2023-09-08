import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../config/extensions.dart';

class CustomTextFormField extends StatelessWidget {
  final bool? enabled;
  final bool readOnly; // = false;
  final bool autofocus; // = false;
  final bool obscureText; // = false;
  final int maxLines; // = 1;
  final int? minLines;
  final int? maxLength;
  final FocusNode? focusNode;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final VoidCallback? onTap;
  final VoidCallback? onEditingComplete;
  final void Function(String)? onChanged;
  final void Function(String)? onFieldSubmitted;
  final void Function(String?)? onSaved;
  final String? Function(String?)? validator;
  final Color? fillColor;
  final BorderRadius? borderRadius;
  final Widget? prefixIcon;
  final String? prefixText;
  final String? hintText;
  final String? helperText;
  final String? errorText;
  final String? initialValue;
  final TextStyle? textStyle;
  // final String? validateMessage;
  final AutovalidateMode? autoValidateMode;
  final Widget? Function(BuildContext,
      {required int currentLength,
      required bool isFocused,
      required int? maxLength})? buildCounter;

  const CustomTextFormField(
      {Key? key,
      this.enabled,
      this.readOnly = false,
      this.autofocus = false,
      this.obscureText = false,
      this.maxLines = 1,
      this.minLines,
      this.maxLength,
      this.focusNode,
      this.controller,
      this.keyboardType,
      this.textInputAction,
      this.inputFormatters,
      this.onTap,
      this.onEditingComplete,
      this.onChanged,
      this.onFieldSubmitted,
      this.onSaved,
      this.validator,
      this.prefixIcon,
      this.prefixText,
      this.initialValue,
      this.hintText,
      // this.validateMessage,
      this.fillColor,
      this.borderRadius,
      this.helperText,
      this.errorText,
      this.textStyle,
      this.autoValidateMode = AutovalidateMode.onUserInteraction,
      this.buildCounter})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    BorderRadius defaultRadius =
    BorderRadius.all(Radius.circular(context.dp(10)));

    return TextFormField(
      initialValue: initialValue,
      controller: controller,
      enabled: enabled,
      readOnly: readOnly,
      autofocus: autofocus,
      obscureText: obscureText,
      focusNode: focusNode,
      maxLines: maxLines,
      minLines: minLines,
      maxLength: maxLength,
      onTap: onTap,
      onChanged: onChanged,
      onFieldSubmitted: onFieldSubmitted,
      onEditingComplete: onEditingComplete,
      onSaved: onSaved,
      validator: validator,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      inputFormatters: inputFormatters,
      autovalidateMode: autoValidateMode,
      style: textStyle ?? context.text.bodyMedium,
      buildCounter: buildCounter,
      decoration: InputDecoration(
        hintText: hintText,
        helperText: helperText,
        errorText: errorText,
        fillColor: fillColor,
        semanticCounterText: 'counter text',
        enabledBorder: OutlineInputBorder(
          borderRadius: borderRadius ?? defaultRadius,
          borderSide: BorderSide(color: context.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: borderRadius ?? defaultRadius,
          borderSide: BorderSide(color: context.secondaryColor),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: borderRadius ?? defaultRadius,
          borderSide: BorderSide(color: context.errorColor),
        ),
        prefixIcon: (prefixIcon == null)
            ? ((prefixText != null)
                ? SizedBox(
                    width:
                        (!context.isMobile) ? context.dp(36) : context.dp(47),
                    child: Center(
                      child: Text(
                        prefixText!,
                        style: context.text.labelLarge?.copyWith(
                          color: context.onBackground,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  )
                : null)
            : (!context.isMobile)
                ? SizedBox(
                    width: context.dp(36),
                    child: Transform.scale(scale: 1.6, child: prefixIcon),
                  )
                : prefixIcon,
        contentPadding: EdgeInsets.all(
            (!context.isMobile) ? context.dp(8) : context.dp(16)),
      ),
    );
  }
}
