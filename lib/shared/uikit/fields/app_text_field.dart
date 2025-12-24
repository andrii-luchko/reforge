import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/theme/typography_theme.dart';
import 'package:reforge/generated/flutter_gen/assets.gen.dart';

class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,

    this.errorText,
    this.hintText,
    this.controller,
    this.focusNode,
    this.suffixIcon,
    this.prefixIcon,
    this.onChanged,
  }) : _isPasswordField = false,
       isObscured = false;

  const AppTextField.password({
    super.key,
    this.errorText,
    this.hintText,
    this.controller,
    this.focusNode,
    this.prefixIcon,
    this.onChanged,
  }) : suffixIcon = null,
       isObscured = true,
       _isPasswordField = true;

  final String? errorText;
  final String? hintText;
  final TextEditingController? controller;
  final FocusNode? focusNode;

  final ValueChanged<String>? onChanged;

  final bool isObscured;
  final bool _isPasswordField;

  final Widget? suffixIcon;
  final Widget? prefixIcon;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _obscureText = widget.isObscured;

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(50);

    final contentStyle = bodyLRegular.copyWith(color: context.appTheme.beige100);
    final hintStyle = bodyLRegular.copyWith(color: context.appTheme.beige600);

    final errorTextStyle = bodySRegular.copyWith(color: context.appTheme.red400);

    final hasError = widget.errorText != null && widget.errorText!.isNotEmpty;

    final suffixIcon = widget._isPasswordField
        ? _PasswordIcon(
            key: ValueKey(_obscureText),
            isObscured: _obscureText,
            onPressed: _togglePasswordVisibility,
          )
        : widget.suffixIcon;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: widget.controller,
          focusNode: widget.focusNode,
          onChanged: widget.onChanged,
          onTapOutside: (_) => FocusScope.of(context).unfocus(),
          style: contentStyle,
          cursorHeight: 15,
          cursorWidth: 1,
          cursorColor: context.appTheme.beige100,
          cursorErrorColor: context.appTheme.red400,
          obscureText: _obscureText,
          obscuringCharacter: '*',

          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: hintStyle,

            prefixIcon: widget.prefixIcon,
            suffixIcon: suffixIcon,

            contentPadding: const .symmetric(horizontal: 16, vertical: 17),
            filled: true,
            fillColor: context.appTheme.beige900,

            disabledBorder: OutlineInputBorder(
              borderRadius: borderRadius,
              borderSide: BorderSide(
                color: context.appTheme.strokeCard,
              ),
            ),

            enabledBorder: OutlineInputBorder(
              borderRadius: borderRadius,
              borderSide: BorderSide(
                color: hasError ? context.appTheme.red400 : context.appTheme.strokeCard,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: borderRadius,
              borderSide: BorderSide(
                color: hasError ? context.appTheme.red400 : context.appTheme.strokeCard,
              ),
            ),
          ),
        ),

        if (hasError)
          AnimatedPadding(
            duration: Durations.medium1,
            padding: const .only(top: 4),
            child: Text(
              widget.errorText!,
              style: errorTextStyle,
            ),
          ),
      ],
    );
  }
}

class _PasswordIcon extends StatelessWidget {
  const _PasswordIcon({
    required this.isObscured,
    required this.onPressed,
    super.key,
  });

  final bool isObscured;
  final VoidCallback onPressed;
  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: SvgPicture.asset(
        isObscured ? Assets.images.icons.eyeSlash : Assets.images.icons.eye,
        height: 20,
        width: 20,
        colorFilter: ColorFilter.mode(context.appTheme.beige100, BlendMode.srcIn),
      ),

      onPressed: onPressed,
      highlightColor: Colors.transparent,
    );
  }
}
