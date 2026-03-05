import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reforge/app/constants/env.dart';
import 'package:reforge/app/router/routes.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/theme/typography_theme.dart';
import 'package:reforge/app/utils/helpers/launch_url_recognizer.dart';
import 'package:reforge/app/utils/toasts/show_toast.dart';
import 'package:reforge/features/subscription/controllers/subscription_cubit.dart';
import 'package:reforge/features/subscription/domain/entity/subscription_package.dart';
import 'package:reforge/features/subscription/ui/widgets/subscription_lifetime_status_card.dart';
import 'package:reforge/features/subscription/ui/widgets/subscription_packages_list.dart';
import 'package:reforge/features/subscription/ui/widgets/subscription_recurring_status_card.dart';
import 'package:reforge/generated/i18n/translations.g.dart';
import 'package:reforge/shared/uikit/buttons/primary_button.dart';
import 'package:reforge/shared/uikit/buttons/thirty_button.dart';
import 'package:toastification/toastification.dart';

class PaywallView extends StatefulWidget {
  const PaywallView({super.key});

  @override
  State<PaywallView> createState() => _PaywallViewState();
}

class _PaywallViewState extends State<PaywallView> {
  SubscriptionPackage? _selectedPackage;

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
          prev.offerings != curr.offerings ||
          prev.isLoading != curr.isLoading ||
          prev.error != curr.error ||
          prev.currentSubscription != curr.currentSubscription,
      builder: (context, state) {
        if (state.offerings != null && state.offerings!.packages.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            if (state.currentPackage != null) return;
            if (_selectedPackage == null) {
              setState(() => _selectedPackage = state.offerings!.packages.first);
            }
          });
        }

        final hasPurchased = state.hasLifetime || (state.hasActiveSubscription && state.currentPackage != null);

        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  t.subscription.paywallTitle,
                  style: subheadH1Medium.copyWith(
                    fontSize: 32,
                    color: context.appTheme.beige100,
                  ),
                ),
              ),
            ),
            if (hasPurchased)
              ..._buildAfterPurchaseSlivers(context, state)
            else
              ..._buildBeforePurchaseSlivers(context, state),
          ],
        );
      },
    );
  }

  List<Widget> _buildAfterPurchaseSlivers(
    BuildContext context,
    SubscriptionState state,
  ) {
    final slivers = <Widget>[
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        sliver: SliverToBoxAdapter(
          child: state.hasLifetime
              ? const SubscriptionLifetimeStatusCard()
              : SubscriptionRecurringStatusCard(
                  currentPackage: state.currentPackage!,
                  expirationDate: state.currentSubscription!.expirationDate,
                  managementUrl: state.currentSubscription!.managementUrl,
                ),
        ),
      ),
      SliverFillRemaining(
        hasScrollBody: false,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              PrimaryButton(
                text: t.common.continue_button,
                onPressed: () => const HomePageRoute().go(context),
              ),
            ],
          ),
        ),
      ),
    ];
    return slivers;
  }

  List<Widget> _buildBeforePurchaseSlivers(
    BuildContext context,
    SubscriptionState state,
  ) {
    return [
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        sliver: SubscriptionPackagesList(
          state: state,
          selectedPackage: _selectedPackage,
          onPackageSelected: (p) => setState(() => _selectedPackage = p),
        ),
      ),
      SliverFillRemaining(
        hasScrollBody: false,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ThirtyButton(
                text: t.common.skip_button,
                onPressed: () => const HomePageRoute().go(context),
                style: subheadH6Medium,
              ),
              const SizedBox(height: 32),
              PrimaryButton(
                text: t.common.continue_button,
                onPressed: _selectedPackage != null
                    ? () async {
                        await context.read<SubscriptionCubit>().purchase(_selectedPackage!);
                      }
                    : null,
              ),
              const SizedBox(height: 12),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ThirtyButton(
                    text: t.subscription.restorePurchases,
                    onPressed: () => context.read<SubscriptionCubit>().restorePurchases(),
                    style: subheadH6Medium,
                  ),
                  ThirtyButton(
                    text: t.subscription.termsButton,
                    onPressed: () => LaunchUrl.launchAppLink(Env.termsOfUseUrl),
                    style: subheadH6Medium,
                  ),
                  ThirtyButton(
                    text: t.subscription.privacyButton,
                    onPressed: () => LaunchUrl.launchAppLink(Env.privacyPolicyUrl),
                    style: subheadH6Medium,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ];
  }
}
