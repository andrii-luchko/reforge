import 'package:flutter/material.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/theme/typography_theme.dart';
import 'package:reforge/features/achievements/domain/enums/forge_attribute.dart';
import 'package:reforge/generated/i18n/translations.g.dart';
import 'package:reforge/shared/dialogs/default_dialog_header.dart';

class ForgeSystemGuideSheet extends StatelessWidget {
  const ForgeSystemGuideSheet._();

  static Future<void> showForgeSystemGuide(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.7),
      useRootNavigator: true,
      builder: (context) => const ForgeSystemGuideSheet._(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;

    return DraggableScrollableSheet(
      initialChildSize: 1,
      minChildSize: 1,

      builder: (_, scrollController) {
        return DecoratedBox(
          decoration: BoxDecoration(
            color: theme.beige900,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border(
              top: BorderSide(color: theme.strokeCard),
            ),
          ),
          child: Column(
            children: [
              // const SizedBox(height: 12),
              // Container(
              //   width: 40,
              //   height: 4,
              //   decoration: BoxDecoration(
              //     color: theme.beige600,
              //     borderRadius: BorderRadius.circular(2),
              //   ),
              // ),
              // const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                child: DefaultDialogHeader(title: t.achievements.attributeMasteryGuide),
              ),
              // Text('THE FIVE-FORGE SYSTEM', style: subheadH1Medium.copyWith(color: theme.beige100)),
              // const SizedBox(height: 4),
              // Text(
              //   'Attribute Mastery Guide',
              //   style: subheadH3Medium.copyWith(
              //     color: theme.beige700,
              //   ),
              // ),
              const SizedBox(height: 24),

              Expanded(
                child: ListView.separated(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
                  itemCount: forgeAttributesDisplayOrder.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 24),
                  itemBuilder: (context, index) {
                    final attr = forgeAttributesDisplayOrder[index];
                    return _AttributeDescriptionItem(attribute: attr);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _AttributeDescriptionItem extends StatelessWidget {
  const _AttributeDescriptionItem({required this.attribute});
  final ForgeAttribute attribute;

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.strokeCard),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: attribute.title(t),
                  style: subheadH3Medium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.orange500,
                  ),
                ),

                const TextSpan(text: '  '),

                TextSpan(
                  text: attribute.subtitle(t),
                  style: subheadH6Regular.copyWith(
                    fontStyle: FontStyle.italic,
                    color: theme.beige700,
                  ),
                ),
              ],
            ),

            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
          const SizedBox(height: 8),

          Text(
            attribute.description(t),
            style: subheadH5Medium.copyWith(
              color: theme.beige100,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
