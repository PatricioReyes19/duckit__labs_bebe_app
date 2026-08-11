import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:register/models/register_event_kind.dart';

/// Stateless composition shared by the six register event forms.
///
/// Values and callbacks are controlled by the caller so each form can later be
/// connected to its own Cubit without coupling UI to feature state.
class RegisterEventView extends StatelessWidget {
  const RegisterEventView({
    required this.title,
    required this.selectedKind,
    required this.onKindChanged,
    required this.form,
    required this.onSavePressed,
    required this.onCancelPressed,
    this.babyName = 'Tu bebé',
    this.babyAge = 'Perfil activo',
    this.familyContextLabel = 'Tu familia',
    this.babyAvatar,
    this.onBackPressed,
    this.onNotificationsPressed,
    this.onBabyPressed,
    this.subcategories = const [],
    this.selectedSubcategory,
    this.onSubcategoryChanged,
    this.contextTitle,
    this.contextDescription,
    this.contextLeading,
    this.contextTrailing,
    this.bottomNavigationBar,
    this.showEventContext = true,
    this.useFormSurface = true,
    this.isSaving = false,
    this.saveLabel = 'Guardar registro',
    this.errorMessage,
    this.scrollController,
    super.key,
  }) : assert(
          subcategories.length == 0 || selectedSubcategory != null,
          'selectedSubcategory is required when subcategories are provided.',
        );

  final String title;
  final RegisterEventKind selectedKind;
  final ValueChanged<RegisterEventKind>? onKindChanged;
  final Widget form;
  final VoidCallback? onSavePressed;
  final VoidCallback? onCancelPressed;
  final String babyName;
  final String babyAge;
  final String familyContextLabel;
  final BebeAvatar? babyAvatar;
  final VoidCallback? onBackPressed;
  final VoidCallback? onNotificationsPressed;
  final VoidCallback? onBabyPressed;
  final List<BebeSegmentedItem<String>> subcategories;
  final String? selectedSubcategory;
  final ValueChanged<String>? onSubcategoryChanged;
  final String? contextTitle;
  final String? contextDescription;
  final Widget? contextLeading;
  final Widget? contextTrailing;
  final Widget? bottomNavigationBar;
  final bool showEventContext;
  final bool useFormSurface;
  final bool isSaving;
  final String saveLabel;
  final String? errorMessage;
  final ScrollController? scrollController;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final formContent = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (errorMessage != null) ...[
          BebeStatusBanner(
            title: errorMessage!,
            type: BebeStatusBannerType.error,
            leading: const Icon(Icons.error_outline_rounded),
          ),
          SizedBox(height: theme.spacing.spacingXl),
        ],
        form,
        SizedBox(height: theme.spacing.spacing2xl),
        BebeRegisterActionBar(
          onSavePressed: onSavePressed,
          onCancelPressed: onCancelPressed,
          isSaving: isSaving,
          saveLabel: saveLabel,
        ),
      ],
    );
    return BebeRegisterEventTemplate(
      controller: scrollController,
      header: BebePageHeader(
        title: title,
        leading: BebeIconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          semanticLabel: 'Volver',
          onPressed: onBackPressed,
        ),
        trailing: onNotificationsPressed == null
            ? null
            : BebeIconButton(
                icon: const Icon(Icons.notifications_none_rounded),
                semanticLabel: 'Notificaciones',
                onPressed: onNotificationsPressed,
              ),
      ),
      babySelector: showEventContext
          ? BebeBabySelector(
              name: babyName,
              ageLabel: babyAge,
              avatar: babyAvatar ??
                  BebeAvatar.initials(
                    initials: babyName,
                    size: BebeAvatarSize.lg,
                    semanticLabel: 'Avatar de $babyName',
                    borderColor: theme.colors.border.brandAlternative,
                  ),
              contextLabel: familyContextLabel,
              isSelected: true,
              onPressed: onBabyPressed,
            )
          : null,
      categorySelector: showEventContext
          ? BebeRegisterCategorySelector<RegisterEventKind>(
              items: _categories,
              selectedValue: selectedKind,
              onChanged: onKindChanged,
              contentPadding: EdgeInsets.symmetric(
                horizontal: theme.spacing.spacingXl,
              ),
            )
          : null,
      fullBleedCategorySelector: true,
      subcategorySelector: subcategories.isEmpty
          ? null
          : BebeRegisterSubcategorySelector<String>(
              items: subcategories,
              selectedValue: selectedSubcategory!,
              onChanged: onSubcategoryChanged,
              semanticLabel: 'Tipo de ${_kindLabel(selectedKind)}',
            ),
      contextBanner: contextTitle == null
          ? null
          : BebeStatusBanner(
              title: contextTitle!,
              description: contextDescription,
              type: BebeStatusBannerType.information,
              leading: contextLeading ?? const Icon(Icons.schedule_outlined),
              trailing: contextTrailing,
              compact: true,
            ),
      bottomNavigationBar: bottomNavigationBar,
      form: useFormSurface
          ? BebeRegisterFormSection(child: formContent)
          : formContent,
    );
  }

  static const _categories = <BebeRegisterCategoryItem<RegisterEventKind>>[
    BebeRegisterCategoryItem(
      value: RegisterEventKind.feeding,
      label: 'Alimentación',
      icon: Icon(Icons.local_drink_outlined),
      variant: BebeCategoryActionTileVariant.feeding,
    ),
    BebeRegisterCategoryItem(
      value: RegisterEventKind.sleep,
      label: 'Sueño',
      icon: Icon(Icons.bedtime_outlined),
      variant: BebeCategoryActionTileVariant.sleep,
    ),
    BebeRegisterCategoryItem(
      value: RegisterEventKind.diaper,
      label: 'Pañal',
      icon: Icon(Icons.child_friendly_outlined),
      variant: BebeCategoryActionTileVariant.diaper,
    ),
    BebeRegisterCategoryItem(
      value: RegisterEventKind.observation,
      label: 'Observación',
      icon: Icon(Icons.edit_outlined),
      variant: BebeCategoryActionTileVariant.observation,
    ),
    BebeRegisterCategoryItem(
      value: RegisterEventKind.medication,
      label: 'Medicina',
      icon: Icon(Icons.medication_outlined),
      variant: BebeCategoryActionTileVariant.medication,
    ),
    BebeRegisterCategoryItem(
      value: RegisterEventKind.measurement,
      label: 'Medición',
      icon: Icon(Icons.straighten_outlined),
      variant: BebeCategoryActionTileVariant.measurement,
    ),
  ];

  static String _kindLabel(RegisterEventKind kind) => switch (kind) {
        RegisterEventKind.feeding => 'alimentación',
        RegisterEventKind.sleep => 'sueño',
        RegisterEventKind.diaper => 'pañal',
        RegisterEventKind.observation => 'observación',
        RegisterEventKind.medication => 'medicina',
        RegisterEventKind.measurement => 'medición',
      };
}
