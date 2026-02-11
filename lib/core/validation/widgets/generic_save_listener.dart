import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reforge/app/utils/toasts/show_toast.dart';
import 'package:reforge/core/validation/generic_validation_cubit.dart';
import 'package:reforge/generated/i18n/translations.g.dart';
import 'package:toastification/toastification.dart';

class GenericSaveListener<T> extends StatelessWidget {
  const GenericSaveListener({
    required this.child,
    this.onSuccess,
    this.onError,
    super.key,
  });

  final Widget child;

  final VoidCallback? onSuccess;
  final void Function(String message)? onError;

  @override
  Widget build(BuildContext context) {
    return BlocListener<GenericValidationCubit<T>, GenericValidationState<T>>(
      listenWhen: (previous, current) => current is GenericValidationSuccess<T> || current is GenericExternalError<T>,
      listener: (context, state) {
        switch (state) {
          case GenericValidationSuccess():
            if (onSuccess != null) {
              onSuccess!();
            } else {
              toastification.showSimpleToast(t.common.saved_successfully, alignment: .center);
            }

          case GenericExternalError(error: final msg):
            if (onError != null) {
              onError!(msg ?? 'Error');
            } else {
              toastification.showErrorToast(msg ?? 'Server Error', context);
            }

          default:
            break;
        }
      },
      child: child,
    );
  }
}
