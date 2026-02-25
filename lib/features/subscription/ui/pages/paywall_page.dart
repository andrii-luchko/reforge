import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reforge/features/subscription/controllers/subscription_cubit.dart';
import 'package:reforge/features/subscription/ui/widgets/paywall_view.dart';
import 'package:reforge/shared/uikit/default_background.dart';
import 'package:reforge/shared/uikit/screen_loading_indicator.dart';

class PaywallPage extends StatelessWidget {
  const PaywallPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DefaultBackground(
        body: SafeArea(
          bottom: false,
          child: BlocBuilder<SubscriptionCubit, SubscriptionState>(
            buildWhen: (prev, curr) => prev.isPurchasing != curr.isPurchasing,
            builder: (context, state) {
              return Stack(
                children: [
                  const PaywallView(),
                  if (state.isPurchasing)
                    const Positioned.fill(
                      child: ScreenLoadingIndicator(),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
