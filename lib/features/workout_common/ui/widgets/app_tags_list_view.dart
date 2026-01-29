import 'package:flutter/material.dart';
import 'package:reforge/shared/uikit/app_tag.dart';
import 'package:skeletonizer/skeletonizer.dart';

class AppTagsListView extends StatelessWidget {
  const AppTagsListView({required this.tags, super.key});

  final List<String> tags;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,

      child: Row(
        children: [
          for (int i = 0; i < tags.length; i++) ...[
            Skeleton.leaf(child: AppTag(text: tags[i])),
            if (i != tags.length - 1) const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }
}
