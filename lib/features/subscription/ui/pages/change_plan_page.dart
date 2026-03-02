import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/theme/typography_theme.dart';
import 'package:reforge/app/utils/toasts/show_toast.dart';
import 'package:reforge/features/subscription/controllers/subscription_cubit.dart';
import 'package:reforge/features/subscription/domain/entity/subscription_package.dart';
import 'package:reforge/features/subscription/ui/widgets/subscription_packages_list_content.dart';
import 'package:reforge/features/subscription/ui/widgets/subscription_packages_skeleton.dart';
import 'package:reforge/generated/i18n/translations.g.dart';
import 'package:reforge/shared/default_sliver_app_bar.dart';
import 'package:reforge/shared/empty_list_message.dart';
import 'package:reforge/shared/uikit/buttons/primary_button.dart';
import 'package:reforge/shared/uikit/default_background.dart';
import 'package:reforge/shared/uikit/screen_loading_indicator.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:toastification/toastification.dart';

class ChangePlanPage extends StatefulWidget {
  const ChangePlanPage({super.key});

  @override
  State<ChangePlanPage> createState() => _ChangePlanPageState();
}

class _ChangePlanPageState extends State<ChangePlanPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: false,
      body: DefaultBackground(
        body: SafeArea(
          top: false,
          bottom: false,
          child: BlocConsumer<SubscriptionCubit, SubscriptionState>(
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
                prev.currentSubscription != curr.currentSubscription ||
                prev.isPurchasing != curr.isPurchasing,
            builder: (context, state) {
              if (state.isPurchasing) {
                return const Stack(
                  children: [
                    _ChangePlanBody(),
                    Positioned.fill(child: ScreenLoadingIndicator()),
                  ],
                );
              }
              return const _ChangePlanBody();
            },
          ),
        ),
      ),
    );
  }
}

class _ChangePlanBody extends StatelessWidget {
  const _ChangePlanBody();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SubscriptionCubit, SubscriptionState>(
      buildWhen: (prev, curr) =>
          prev.offerings != curr.offerings ||
          prev.isLoading != curr.isLoading ||
          prev.currentSubscription != curr.currentSubscription,
      builder: (context, state) {
        final showSkeleton = state.isLoading && state.offerings == null;
        final packages = state.offerings?.packages ?? [];
        final isEmpty = !showSkeleton && packages.isEmpty;

        return CustomScrollView(
          slivers: [
            DefaultSliverAppBar(
              onPressed: () => context.pop(),
              title: t.subscription.changePlan,
            ),
            const SliverPadding(padding: EdgeInsets.all(8)),
            const SliverPadding(padding: EdgeInsets.only(top: 16)),
            SliverPadding(
              padding: DefaultSliverAppBar.horizontalPadding,
              sliver: showSkeleton
                  ? const SliverSkeletonizer(
                      child: SubscriptionPackagesSkeleton(),
                    )
                  : isEmpty
                  ? const SliverEmptyListMessage(
                      title: 'Couldn’t load plans',
                      subtitle: 'We couldn’t load subscription plans. Pull down to refresh or try again later.',
                      icon: Icons.refresh_rounded,
                    )
                  : SliverMainAxisGroup(
                      slivers: [
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Text(
                              'Choose a different plan. Your change will take effect as described in the plan details.',
                              style: subheadH1Medium.copyWith(
                                fontSize: 32,
                                color: context.appTheme.beige100,
                              ),
                            ),
                          ),
                        ),
                        _ChangePlanPackagesList(packages: packages),
                        const SliverPadding(padding: EdgeInsets.only(bottom: 24)),
                      ],
                    ),
            ),
          ],
        );
      },
    );
  }
}

class _ChangePlanPackagesList extends StatefulWidget {
  const _ChangePlanPackagesList({required this.packages});

  final List<SubscriptionPackage> packages;

  @override
  State<_ChangePlanPackagesList> createState() => _ChangePlanPackagesListState();
}

class _ChangePlanPackagesListState extends State<_ChangePlanPackagesList> {
  SubscriptionPackage? _selectedPackage;

  @override
  void initState() {
    super.initState();
    final state = context.read<SubscriptionCubit>().state;
    final current = state.currentPackage;
    if (current != null) {
      _selectedPackage = widget.packages.firstWhereOrNull((p) => p.id == current.id);
    } else if (widget.packages.isNotEmpty) {
      _selectedPackage = widget.packages.first;
    }
  }

  @override
  void didUpdateWidget(covariant _ChangePlanPackagesList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_selectedPackage != null && !widget.packages.any((p) => p.id == _selectedPackage!.id)) {
      _selectedPackage = widget.packages.isNotEmpty ? widget.packages.first : null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<SubscriptionCubit>().state;
    final currentPackage = state.currentPackage;
    final annualSavings = state.getAnnualSavings();
    final canSwitch = _selectedPackage != null && (currentPackage == null || _selectedPackage!.id != currentPackage.id);

    return SliverMainAxisGroup(
      slivers: [
        SubscriptionPackagesListContent(
          packages: widget.packages,
          selectedPackage: _selectedPackage,
          currentPackage: currentPackage,
          annualSavings: annualSavings,
          onPackageSelected: (p) {
            if (currentPackage != null && p.id == currentPackage.id) return;
            setState(() => _selectedPackage = p);
          },
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(top: 24, bottom: 16),
            child: PrimaryButton(
              text: t.subscription.changePlan,
              onPressed: canSwitch
                  ? () async {
                      if (_selectedPackage == null) return;
                      await context.read<SubscriptionCubit>().purchase(_selectedPackage!);
                      if (context.mounted) context.pop();
                    }
                  : null,
            ),
          ),
        ),
      ],
    );
  }
}
