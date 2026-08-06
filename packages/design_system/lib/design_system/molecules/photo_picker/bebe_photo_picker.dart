import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// A visual photo supplied to [BebePhotoPicker].
class BebePhotoItem {
  const BebePhotoItem({
    required this.id,
    required this.preview,
    required this.semanticLabel,
  });

  final String id;
  final Widget preview;
  final String semanticLabel;
}

/// Photo preview and add/remove controls without device or permission logic.
class BebePhotoPicker extends StatelessWidget {
  const BebePhotoPicker({
    required this.label,
    required this.items,
    this.onAddPressed,
    this.onRemovePressed,
    this.optional = true,
    this.addLabel = 'Agregar foto',
    super.key,
  });

  final String label;
  final List<BebePhotoItem> items;
  final VoidCallback? onAddPressed;
  final ValueChanged<String>? onRemovePressed;
  final bool optional;
  final String addLabel;

  @override
  Widget build(BuildContext context) {
    final spacing = context.theme.spacing;
    return BebeFormField(
      label: label,
      optional: optional,
      child: Wrap(
        spacing: spacing.spacingM,
        runSpacing: spacing.spacingM,
        children: [
          for (final item in items)
            _PhotoPreview(item: item, onRemovePressed: onRemovePressed),
          _AddPhotoButton(label: addLabel, onPressed: onAddPressed),
        ],
      ),
    );
  }
}

class _PhotoPreview extends StatelessWidget {
  const _PhotoPreview({required this.item, required this.onRemovePressed});

  final BebePhotoItem item;
  final ValueChanged<String>? onRemovePressed;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final size = theme.spacing.spacing8xl + theme.spacing.spacing5xl;
    return Semantics(
      image: true,
      label: item.semanticLabel,
      child: SizedBox.square(
        dimension: size,
        child: Stack(
          children: [
            Positioned.fill(
              child: ClipRRect(
                borderRadius: theme.borderRadius.xl,
                child: ExcludeSemantics(child: item.preview),
              ),
            ),
            if (onRemovePressed != null)
              Positioned(
                top: theme.spacing.spacingS,
                right: theme.spacing.spacingS,
                child: BebeIconButton(
                  icon: const Icon(Icons.close_rounded),
                  semanticLabel: 'Eliminar ${item.semanticLabel}',
                  onPressed: () => onRemovePressed!(item.id),
                  variant: BebeIconButtonVariant.subtle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _AddPhotoButton extends StatelessWidget {
  const _AddPhotoButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final size = theme.spacing.spacing8xl + theme.spacing.spacing5xl;
    return Semantics(
      button: true,
      enabled: onPressed != null,
      label: label,
      child: SizedBox.square(
        dimension: size,
        child: Material(
          color: theme.colors.background.neutralsSurface,
          shape: RoundedRectangleBorder(
            borderRadius: theme.borderRadius.xl,
            side: BorderSide(color: theme.colors.border.neutralDefault),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onPressed,
            child: Padding(
              padding: EdgeInsets.all(theme.spacing.spacingM),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_a_photo_outlined,
                    size: BebeIconSize.lg.value,
                    color: theme.colors.icons.brandDefault,
                  ),
                  SizedBox(height: theme.spacing.spacingM),
                  Text(
                    label,
                    maxLines: 2,
                    textAlign: TextAlign.center,
                    style: theme.typography.styles.label.sm.semibold.copyWith(
                      color: theme.colors.text.brandDefault,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
