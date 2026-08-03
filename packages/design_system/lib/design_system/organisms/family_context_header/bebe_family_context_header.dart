import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Encabezado del contexto familiar activo.
///
/// Representa visualmente:
/// - el núcleo familiar seleccionado;
/// - el bebé activo;
/// - información contextual opcional;
/// - una acción para cambiar de contexto;
/// - una acción de configuración opcional.
///
/// No contiene navegación, menús desplegables ni lógica de dominio.
class BebeFamilyContextHeader extends StatelessWidget {
  const BebeFamilyContextHeader({
    required this.familyName,
    required this.babyName,
    required this.avatar,
    this.babyAge,
    this.supportingText,
    this.onContextPressed,
    this.settingsAction,
    this.semanticLabel,
    super.key,
  });

  /// Nombre del núcleo familiar activo.
  ///
  /// Ejemplo: `Familia Reyes González`.
  final String familyName;

  /// Nombre del bebé activo.
  final String babyName;

  /// Avatar visual del bebé activo.
  final Widget avatar;

  /// Edad o información temporal breve.
  ///
  /// Ejemplo: `2 meses`.
  final String? babyAge;

  /// Información contextual adicional.
  ///
  /// Ejemplo: `2 bebés en este núcleo`.
  final String? supportingText;

  /// Acción para cambiar de núcleo o bebé activo.
  ///
  /// Si es nula, el bloque se presenta como contenido informativo.
  final VoidCallback? onContextPressed;

  /// Acción opcional situada en la esquina superior derecha.
  ///
  /// Puede contener un botón de configuración o preferencias.
  final Widget? settingsAction;

  /// Etiqueta accesible completa.
  ///
  /// Cuando no se proporciona, se genera a partir de los textos visibles.
  final String? semanticLabel;

  static const double _avatarSize = 72;
  static const double _contextChevronSize = 24;

  bool get _isInteractive => onContextPressed != null;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final spacing = theme.spacing;
    final colors = theme.colors;
    final radius = theme.borderRadius;
    final elevation = theme.elevation;
    final overlays = theme.overlays;

    final effectiveFamilyName = familyName.trim();
    final effectiveBabyName = babyName.trim();
    final effectiveBabyAge = _normalizeText(babyAge);
    final effectiveSupportingText = _normalizeText(supportingText);
    final effectiveSemanticLabel = _normalizeText(semanticLabel);

    final cardRadius = BorderRadius.circular(radius.radius3xl);

    final content = Padding(
      padding: EdgeInsets.all(spacing.spacingL),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox.square(
            dimension: _avatarSize,
            child: ClipOval(
              child: FittedBox(fit: BoxFit.cover, child: avatar),
            ),
          ),
          SizedBox(width: spacing.spacingL),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  effectiveFamilyName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.typography.styles.label.sm.semibold.copyWith(
                    color: colors.text.brandDefault,
                  ),
                ),
                SizedBox(height: spacing.spacingXs),
                Wrap(
                  spacing: spacing.spacingS,
                  runSpacing: spacing.spacingXs,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      effectiveBabyName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.typography.styles.title.md.semibold.copyWith(
                        color: colors.text.neutralTitle,
                      ),
                    ),
                    if (effectiveBabyAge != null)
                      Text(
                        '· $effectiveBabyAge',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.typography.styles.body.md.regular.copyWith(
                          color: colors.text.neutralBody,
                        ),
                      ),
                  ],
                ),
                if (effectiveSupportingText != null) ...[
                  SizedBox(height: spacing.spacingS),
                  Row(
                    children: [
                      Icon(
                        Icons.groups_2_outlined,
                        size: 20,
                        color: colors.icons.neutralAlternative,
                      ),
                      SizedBox(width: spacing.spacingS),
                      Expanded(
                        child: Text(
                          effectiveSupportingText,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.typography.styles.body.sm.regular
                              .copyWith(color: colors.text.neutralBody),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          if (_isInteractive) ...[
            SizedBox(width: spacing.spacingM),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: _contextChevronSize,
              color: colors.text.brandDefault,
            ),
          ],
        ],
      ),
    );

    final interactiveContent = _isInteractive
        ? InkWell(
            onTap: onContextPressed,
            overlayColor: WidgetStateProperty.resolveWith<Color?>((states) {
              if (states.contains(WidgetState.pressed)) {
                return overlays.interactionPressed;
              }

              if (states.contains(WidgetState.hovered)) {
                return overlays.interactionHover;
              }

              if (states.contains(WidgetState.focused)) {
                return overlays.interactionFocus;
              }

              return null;
            }),
            child: content,
          )
        : content;

    final card = DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: cardRadius,
        boxShadow: elevation.low,
      ),
      child: Material(
        color: colors.background.neutralsSurface,
        shape: RoundedRectangleBorder(
          borderRadius: cardRadius,
          side: BorderSide(color: colors.border.neutralDefault),
        ),
        clipBehavior: Clip.antiAlias,
        child: interactiveContent,
      ),
    );

    final visualContent = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: card),
        if (settingsAction != null) ...[
          SizedBox(width: spacing.spacingM),
          settingsAction!,
        ],
      ],
    );

    final generatedSemanticLabel = [
      effectiveFamilyName,
      effectiveBabyName,
      ?effectiveBabyAge,
      ?effectiveSupportingText,
    ].join('. ');

    final resolvedSemanticLabel =
        effectiveSemanticLabel ?? generatedSemanticLabel;

    if (_isInteractive) {
      return Semantics(
        container: true,
        button: true,
        enabled: true,
        label: resolvedSemanticLabel,
        hint: 'Cambiar contexto familiar',
        child: ExcludeSemantics(child: visualContent),
      );
    }

    return Semantics(
      container: true,
      label: resolvedSemanticLabel,
      child: ExcludeSemantics(child: visualContent),
    );
  }

  static String? _normalizeText(String? value) {
    final normalizedValue = value?.trim();

    if (normalizedValue == null || normalizedValue.isEmpty) {
      return null;
    }

    return normalizedValue;
  }
}
