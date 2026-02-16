import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reforge/app/utils/toasts/show_toast.dart';
import 'package:reforge/features/settings/domain/enum/workout_settings.dart';
import 'package:reforge/features/settings/ui/page/base_edit_page.dart';
import 'package:reforge/features/settings/ui/page/settings_content/subscription_content_body.dart';
import 'package:reforge/features/subscription/controllers/subscription_cubit.dart';
import 'package:reforge/features/subscription/domain/entity/subscription_package.dart';
import 'package:reforge/generated/i18n/translations.g.dart';
import 'package:reforge/shared/uikit/screen_loading_indicator.dart';
import 'package:toastification/toastification.dart';

class SubscriptionPage extends StatelessWidget {
  const SubscriptionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SubscriptionCubit, SubscriptionState>(
      buildWhen: (prev, curr) => prev.isPurchasing != curr.isPurchasing,
      builder: (context, state) {
        return BaseSettingsEditPage(
          title: WorkoutSettings.subscription.title(t),
          body: const SubscriptionsContent(),
          onRefresh: () => context.read<SubscriptionCubit>().loadOfferings(),
          overlay: state.isPurchasing ? const ScreenLoadingIndicator() : null,
        );
      },
    );
  }
}

class SubscriptionsContent extends StatefulWidget {
  const SubscriptionsContent({super.key});

  @override
  State<SubscriptionsContent> createState() => _SubscriptionsContentState();
}

class _SubscriptionsContentState extends State<SubscriptionsContent> {
  // late final _subscriptionCubit = context.read<SubscriptionCubit>();
  SubscriptionPackage? _selectedPackage;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SubscriptionCubit, SubscriptionState>(
      listenWhen: (prev, curr) => prev.error != curr.error && curr.error != null,
      listener: (context, state) {
        final error = state.error;
        if (error == null) return;
        toastification.showErrorToast(error, context);
        context.read<SubscriptionCubit>().clearError();
      },
      buildWhen: (prev, curr) =>
          prev.offerings != curr.offerings || prev.isLoading != curr.isLoading || prev.error != curr.error,
      builder: (context, state) {
        if (state.offerings != null && state.offerings!.packages.isNotEmpty && _selectedPackage == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && _selectedPackage == null) {
              setState(() => _selectedPackage = state.offerings!.packages.first);
            }
          });
        }
        return SubscriptionContentBody(
          state: state,
          selectedPackage: _selectedPackage,
          onPackageSelected: (p) => setState(() => _selectedPackage = p),
          onPurchase: () {
            if (_selectedPackage != null) {
              context.read<SubscriptionCubit>().purchase(_selectedPackage!);
            }
          },
        );
      },
    );
  }
}
