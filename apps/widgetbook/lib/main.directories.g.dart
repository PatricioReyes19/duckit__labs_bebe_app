// dart format width=80
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_import, prefer_relative_imports, directives_ordering

// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AppGenerator
// **************************************************************************

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:widgetbook/widgetbook.dart' as _widgetbook;
import 'package:widgetbook_app/use_cases/atoms/bebe_avatar_use_cases.dart'
    as _widgetbook_app_use_cases_atoms_bebe_avatar_use_cases;
import 'package:widgetbook_app/use_cases/atoms/bebe_button_use_cases.dart'
    as _widgetbook_app_use_cases_atoms_bebe_button_use_cases;
import 'package:widgetbook_app/use_cases/atoms/bebe_icon_button_use_cases.dart'
    as _widgetbook_app_use_cases_atoms_bebe_icon_button_use_cases;
import 'package:widgetbook_app/use_cases/atoms/bebe_icon_use_cases.dart'
    as _widgetbook_app_use_cases_atoms_bebe_icon_use_cases;
import 'package:widgetbook_app/use_cases/atoms/bebe_status_indicator_use_cases.dart'
    as _widgetbook_app_use_cases_atoms_bebe_status_indicator_use_cases;
import 'package:widgetbook_app/use_cases/atoms/bebe_text_field_use_cases.dart'
    as _widgetbook_app_use_cases_atoms_bebe_text_field_use_cases;
import 'package:widgetbook_app/use_cases/molecules/bebe_baby_selector_use_cases.dart'
    as _widgetbook_app_use_cases_molecules_bebe_baby_selector_use_cases;
import 'package:widgetbook_app/use_cases/molecules/bebe_category_action_tile_use_cases.dart'
    as _widgetbook_app_use_cases_molecules_bebe_category_action_tile_use_cases;
import 'package:widgetbook_app/use_cases/molecules/bebe_segmented_selector_use_cases.dart'
    as _widgetbook_app_use_cases_molecules_bebe_segmented_selector_use_cases;
import 'package:widgetbook_app/use_cases/molecules/bebe_status_banner_use_cases.dart'
    as _widgetbook_app_use_cases_molecules_bebe_status_banner_use_cases;
import 'package:widgetbook_app/use_cases/organisms/bebe_active_baby_header_use_cases.dart'
    as _widgetbook_app_use_cases_organisms_bebe_active_baby_header_use_cases;
import 'package:widgetbook_app/use_cases/organisms/bebe_quick_registration_actions_use_cases.dart'
    as _widgetbook_app_use_cases_organisms_bebe_quick_registration_actions_use_cases;
import 'package:widgetbook_app/use_cases/organisms/bebe_recent_information_use_cases.dart'
    as _widgetbook_app_use_cases_organisms_bebe_recent_information_use_cases;
import 'package:widgetbook_app/use_cases/organisms/bebe_today_summary_use_cases.dart'
    as _widgetbook_app_use_cases_organisms_bebe_today_summary_use_cases;
import 'package:widgetbook_app/use_cases/organisms/bebe_upcoming_health_use_cases.dart'
    as _widgetbook_app_use_cases_organisms_bebe_upcoming_health_use_cases;
import 'package:widgetbook_app/use_cases/templates/bebe_home_template_use_cases.dart'
    as _widgetbook_app_use_cases_templates_bebe_home_template_use_cases;

final directories = <_widgetbook.WidgetbookNode>[
  _widgetbook.WidgetbookCategory(
    name: 'Moléculas',
    children: [
      _widgetbook.WidgetbookFolder(
        name: 'Accesibilidad',
        children: [
          _widgetbook.WidgetbookComponent(
            name: 'BebeBabySelector',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Nombre extenso',
                builder:
                    _widgetbook_app_use_cases_molecules_bebe_baby_selector_use_cases
                        .bebeBabySelectorLongName,
              )
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'BebeSegmentedSelector<String>',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Texto largo',
                builder:
                    _widgetbook_app_use_cases_molecules_bebe_segmented_selector_use_cases
                        .bebeSegmentedLongText,
              )
            ],
          ),
        ],
      ),
      _widgetbook.WidgetbookFolder(
        name: 'Acciones rápidas',
        children: [
          _widgetbook.WidgetbookComponent(
            name: 'CategoryActionTile',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Categorías BebéApp',
                builder:
                    _widgetbook_app_use_cases_molecules_bebe_category_action_tile_use_cases
                        .bebeCategoryTiles,
              ),
              _widgetbook.WidgetbookUseCase(
                name: 'Playground',
                builder:
                    _widgetbook_app_use_cases_molecules_bebe_category_action_tile_use_cases
                        .bebeCategoryTilePlayground,
              ),
            ],
          )
        ],
      ),
      _widgetbook.WidgetbookFolder(
        name: 'Contexto activo',
        children: [
          _widgetbook.WidgetbookComponent(
            name: 'BebeBabySelector',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Playground',
                builder:
                    _widgetbook_app_use_cases_molecules_bebe_baby_selector_use_cases
                        .bebeBabySelectorPlayground,
              )
            ],
          )
        ],
      ),
      _widgetbook.WidgetbookFolder(
        name: 'Feedback',
        children: [
          _widgetbook.WidgetbookComponent(
            name: 'BebeStatusBanner',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Playground',
                builder:
                    _widgetbook_app_use_cases_molecules_bebe_status_banner_use_cases
                        .bebeStatusBannerPlayground,
              )
            ],
          )
        ],
      ),
      _widgetbook.WidgetbookFolder(
        name: 'Offline-first',
        children: [
          _widgetbook.WidgetbookComponent(
            name: 'BebeStatusBanner',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Estados de sincronización',
                builder:
                    _widgetbook_app_use_cases_molecules_bebe_status_banner_use_cases
                        .bebeStatusBannerSyncStates,
              )
            ],
          )
        ],
      ),
      _widgetbook.WidgetbookFolder(
        name: 'Selectores',
        children: [
          _widgetbook.WidgetbookComponent(
            name: 'BebeSegmentedSelector<String>',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Dos opciones',
                builder:
                    _widgetbook_app_use_cases_molecules_bebe_segmented_selector_use_cases
                        .bebeSegmentedTwoOptions,
              )
            ],
          )
        ],
      ),
    ],
  ),
  _widgetbook.WidgetbookCategory(
    name: 'Organismos',
    children: [
      _widgetbook.WidgetbookFolder(
        name: 'Accesibilidad',
        children: [
          _widgetbook.WidgetbookComponent(
            name: 'BebeActiveBabyHeader',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Contenido extenso',
                builder:
                    _widgetbook_app_use_cases_organisms_bebe_active_baby_header_use_cases
                        .activeBabyHeaderLongText,
              )
            ],
          )
        ],
      ),
      _widgetbook.WidgetbookFolder(
        name: 'Home',
        children: [
          _widgetbook.WidgetbookComponent(
            name: 'BebeActiveBabyHeader',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Bebé activo',
                builder:
                    _widgetbook_app_use_cases_organisms_bebe_active_baby_header_use_cases
                        .activeBabyHeaderDefault,
              )
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'BebeQuickRegistrationActions',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Acciones principales',
                builder:
                    _widgetbook_app_use_cases_organisms_bebe_quick_registration_actions_use_cases
                        .quickRegistrationActionsDefault,
              )
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'BebeRecentInformationSection',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Consulta reciente',
                builder:
                    _widgetbook_app_use_cases_organisms_bebe_recent_information_use_cases
                        .recentInformationDefault,
              )
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'BebeTodaySummary',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Resumen completo',
                builder:
                    _widgetbook_app_use_cases_organisms_bebe_today_summary_use_cases
                        .todaySummaryDefault,
              )
            ],
          ),
        ],
      ),
    ],
  ),
  _widgetbook.WidgetbookCategory(
    name: 'Organisms',
    children: [
      _widgetbook.WidgetbookFolder(
        name: 'Home',
        children: [
          _widgetbook.WidgetbookComponent(
            name: 'BebeUpcomingHealthSection',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Mobile',
                builder:
                    _widgetbook_app_use_cases_organisms_bebe_upcoming_health_use_cases
                        .upcomingHealthMobile,
              ),
              _widgetbook.WidgetbookUseCase(
                name: 'Sin acciones inferiores',
                builder:
                    _widgetbook_app_use_cases_organisms_bebe_upcoming_health_use_cases
                        .upcomingHealthWithoutFooter,
              ),
              _widgetbook.WidgetbookUseCase(
                name: 'Sin cuidador',
                builder:
                    _widgetbook_app_use_cases_organisms_bebe_upcoming_health_use_cases
                        .upcomingHealthWithoutCaregiver,
              ),
              _widgetbook.WidgetbookUseCase(
                name: 'Wide',
                builder:
                    _widgetbook_app_use_cases_organisms_bebe_upcoming_health_use_cases
                        .upcomingHealthWide,
              ),
            ],
          )
        ],
      )
    ],
  ),
  _widgetbook.WidgetbookCategory(
    name: 'Templates',
    children: [
      _widgetbook.WidgetbookFolder(
        name: 'Home',
        children: [
          _widgetbook.WidgetbookComponent(
            name: 'BebeHomeTemplate',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Default',
                builder:
                    _widgetbook_app_use_cases_templates_bebe_home_template_use_cases
                        .homeTemplateDefault,
              ),
              _widgetbook.WidgetbookUseCase(
                name: 'Error',
                builder:
                    _widgetbook_app_use_cases_templates_bebe_home_template_use_cases
                        .homeTemplateError,
              ),
              _widgetbook.WidgetbookUseCase(
                name: 'Loading',
                builder:
                    _widgetbook_app_use_cases_templates_bebe_home_template_use_cases
                        .homeTemplateLoading,
              ),
            ],
          )
        ],
      )
    ],
  ),
  _widgetbook.WidgetbookCategory(
    name: 'Átomos',
    children: [
      _widgetbook.WidgetbookFolder(
        name: 'Accesibilidad',
        children: [
          _widgetbook.WidgetbookComponent(
            name: 'BebeButton',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Texto largo y escala',
                builder: _widgetbook_app_use_cases_atoms_bebe_button_use_cases
                    .bebeButtonLongText,
              )
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'BebeIconButton',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Área táctil mínima',
                builder:
                    _widgetbook_app_use_cases_atoms_bebe_icon_button_use_cases
                        .bebeIconButtonTouchTarget,
              )
            ],
          ),
        ],
      ),
      _widgetbook.WidgetbookFolder(
        name: 'Acciones',
        children: [
          _widgetbook.WidgetbookComponent(
            name: 'BebeButton',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Playground',
                builder: _widgetbook_app_use_cases_atoms_bebe_button_use_cases
                    .bebeButtonPlayground,
              ),
              _widgetbook.WidgetbookUseCase(
                name: 'Todas las variantes',
                builder: _widgetbook_app_use_cases_atoms_bebe_button_use_cases
                    .bebeButtonVariants,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'BebeIconButton',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Playground',
                builder:
                    _widgetbook_app_use_cases_atoms_bebe_icon_button_use_cases
                        .bebeIconButtonPlayground,
              )
            ],
          ),
        ],
      ),
      _widgetbook.WidgetbookFolder(
        name: 'Estados',
        children: [
          _widgetbook.WidgetbookComponent(
            name: 'BebeStatusIndicator',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Estados',
                builder:
                    _widgetbook_app_use_cases_atoms_bebe_status_indicator_use_cases
                        .bebeStatusIndicatorStates,
              )
            ],
          )
        ],
      ),
      _widgetbook.WidgetbookFolder(
        name: 'Formularios',
        children: [
          _widgetbook.WidgetbookComponent(
            name: 'BebeTextField',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Estados',
                builder:
                    _widgetbook_app_use_cases_atoms_bebe_text_field_use_cases
                        .bebeTextFieldStates,
              ),
              _widgetbook.WidgetbookUseCase(
                name: 'Playground',
                builder:
                    _widgetbook_app_use_cases_atoms_bebe_text_field_use_cases
                        .bebeTextFieldPlayground,
              ),
            ],
          )
        ],
      ),
      _widgetbook.WidgetbookFolder(
        name: 'Iconografía',
        children: [
          _widgetbook.WidgetbookComponent(
            name: 'BebeIcon',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Escala completa',
                builder: _widgetbook_app_use_cases_atoms_bebe_icon_use_cases
                    .bebeIconSizes,
              ),
              _widgetbook.WidgetbookUseCase(
                name: 'Playground',
                builder: _widgetbook_app_use_cases_atoms_bebe_icon_use_cases
                    .bebeIconPlayground,
              ),
            ],
          )
        ],
      ),
      _widgetbook.WidgetbookFolder(
        name: 'Identidad',
        children: [
          _widgetbook.WidgetbookComponent(
            name: 'BebeAvatar',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Escala completa',
                builder: _widgetbook_app_use_cases_atoms_bebe_avatar_use_cases
                    .bebeAvatarSizes,
              ),
              _widgetbook.WidgetbookUseCase(
                name: 'Fallback',
                builder: _widgetbook_app_use_cases_atoms_bebe_avatar_use_cases
                    .bebeAvatarFallback,
              ),
              _widgetbook.WidgetbookUseCase(
                name: 'Iniciales',
                builder: _widgetbook_app_use_cases_atoms_bebe_avatar_use_cases
                    .bebeAvatarInitials,
              ),
            ],
          )
        ],
      ),
    ],
  ),
];
