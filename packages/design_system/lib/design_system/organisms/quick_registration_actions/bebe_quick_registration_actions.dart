import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

class BebeQuickActionData {
  const BebeQuickActionData({
    required this.id,
    required this.type,
    required this.label,
    required this.icon,
    this.semanticLabel,
  });

  final String id;
  final BebeQuickActionType type;
  final String label;
  final Widget icon;
  final String? semanticLabel;
}

class BebeQuickRegistrationActions extends StatelessWidget {
  const BebeQuickRegistrationActions({
    required this.items,
    required this.onItemPressed,
    this.title = 'Registrar ahora',
    this.helperLabel = 'Desliza para ver más',
    super.key,
  });

  final List<BebeQuickActionData> items;
  final ValueChanged<String> onItemPressed;
  final String title;
  final String helperLabel;

  static const int _maximumVisibleItems = 5;

  @override
  Widget build(BuildContext context) {
    assert(
      items.isNotEmpty,
      'BebeQuickRegistrationActions requires '
      'at least one item.',
    );

    final theme = context.theme;
    final spacing = theme.spacing;
    final colors = theme.colors;

    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          BebeTitleSection(
            title: title,
            trailing: BebeSectionHint(
              label: helperLabel,
              icon: Icon(
                Icons.chevron_right_rounded,
                size: 8,
                color: colors.icons.neutralAlternative,
              ),
            ),
          ),
          SizedBox(height: spacing.spacingM),
          LayoutBuilder(
            builder: (context, constraints) {
              final visibleItems = items.length.clamp(1, _maximumVisibleItems);

              final gap = spacing.spacingS;

              final totalSpacing = gap * (visibleItems - 1);

              final tileWidth =
                  (constraints.maxWidth - totalSpacing) / visibleItems;

              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (var index = 0; index < items.length; index++) ...[
                      SizedBox(
                        width: tileWidth,
                        child: _buildTile(items[index]),
                      ),
                      if (index < items.length - 1) SizedBox(width: gap),
                    ],
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTile(BebeQuickActionData item) {
    return CategoryActionTile(
      variant: item.type.toTitleVariant(),
      label: item.label,
      icon: item.icon,
      semanticLabel: item.semanticLabel,
      onPressed: () {
        onItemPressed(item.id);
      },
    );
  }
}
