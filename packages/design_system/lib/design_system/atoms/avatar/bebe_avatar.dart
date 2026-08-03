import 'package:flutter/material.dart';

enum BebeAvatarSize {
  xs(24),
  sm(32),
  md(40),
  lg(48),
  xl(64),
  hero(80);

  const BebeAvatarSize(this.value);

  final double value;
}

class BebeAvatar extends StatelessWidget {
  const BebeAvatar.image({
    required this.image,
    required this.size,
    this.semanticLabel,
    this.borderColor,
    super.key,
  }) : initials = null,
       fallbackIcon = null;

  const BebeAvatar.initials({
    required this.initials,
    required this.size,
    this.semanticLabel,
    this.borderColor,
    super.key,
  }) : image = null,
       fallbackIcon = null;

  const BebeAvatar.fallback({
    required this.size,
    this.fallbackIcon,
    this.semanticLabel,
    this.borderColor,
    super.key,
  }) : image = null,
       initials = null;

  final ImageProvider? image;
  final String? initials;
  final IconData? fallbackIcon;
  final BebeAvatarSize size;
  final String? semanticLabel;
  final Color? borderColor;

  String get _safeInitials {
    final normalized = initials?.trim() ?? '';
    if (normalized.isEmpty) return '?';

    final parts = normalized.split(RegExp(r'\s+'));
    if (parts.length == 1) {
      return parts.first.characters.first.toUpperCase();
    }

    return '${parts.first.characters.first}${parts.last.characters.first}'
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    Widget child;
    if (image != null) {
      child = Image(
        image: image!,
        fit: BoxFit.cover,
        width: size.value,
        height: size.value,
        errorBuilder: (_, _, _) =>
            _FallbackIcon(icon: fallbackIcon, color: colors.primary),
      );
    } else if (initials != null) {
      child = Center(
        child: Text(
          _safeInitials,
          maxLines: 1,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: colors.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    } else {
      child = _FallbackIcon(icon: fallbackIcon, color: colors.primary);
    }

    return Semantics(
      image: true,
      label: semanticLabel,
      child: Container(
        width: size.value,
        height: size.value,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: colors.primaryContainer,
          border: Border.all(color: borderColor ?? colors.outlineVariant),
        ),
        child: child,
      ),
    );
  }
}

class _FallbackIcon extends StatelessWidget {
  const _FallbackIcon({required this.color, this.icon});

  final IconData? icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Center(child: Icon(icon ?? Icons.person_rounded, color: color));
  }
}
