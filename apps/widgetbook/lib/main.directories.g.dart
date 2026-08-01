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
import 'package:widgetbook_app/use_cases/atoms/indicator_dot_use_cases.dart'
    as _widgetbook_app_use_cases_atoms_indicator_dot_use_cases;
import 'package:widgetbook_app/use_cases/molecules/bebe_baby_selector_use_cases.dart'
    as _widgetbook_app_use_cases_molecules_bebe_baby_selector_use_cases;
import 'package:widgetbook_app/use_cases/molecules/bebe_category_action_tile_use_cases.dart'
    as _widgetbook_app_use_cases_molecules_bebe_category_action_tile_use_cases;
import 'package:widgetbook_app/use_cases/molecules/bebe_segmented_selector_use_cases.dart'
    as _widgetbook_app_use_cases_molecules_bebe_segmented_selector_use_cases;
import 'package:widgetbook_app/use_cases/molecules/bebe_status_banner_use_cases.dart'
    as _widgetbook_app_use_cases_molecules_bebe_status_banner_use_cases;
import 'package:widgetbook_app/use_cases/molecules/caregiver_badge.dart'
    as _widgetbook_app_use_cases_molecules_caregiver_badge;
import 'package:widgetbook_app/use_cases/molecules/filter_chip_use_cases.dart'
    as _widgetbook_app_use_cases_molecules_filter_chip_use_cases;
import 'package:widgetbook_app/use_cases/molecules/info_banner.dart'
    as _widgetbook_app_use_cases_molecules_info_banner;
import 'package:widgetbook_app/use_cases/molecules/selectable_date_cell_use_cases.dart'
    as _widgetbook_app_use_cases_molecules_selectable_date_cell_use_cases;
import 'package:widgetbook_app/use_cases/molecules/time_block_uses_cases.dart'
    as _widgetbook_app_use_cases_molecules_time_block_uses_cases;
import 'package:widgetbook_app/use_cases/templates/agenda_template.dart'
    as _widgetbook_app_use_cases_templates_agenda_template;
import 'package:widgetbook_app/use_cases/templates/bebe_home_template_use_cases.dart'
    as _widgetbook_app_use_cases_templates_bebe_home_template_use_cases;
import 'package:widgetbook_app/use_cases/templates/salud_template.dart'
    as _widgetbook_app_use_cases_templates_salud_template;

final directories = <_widgetbook.WidgetbookNode>[
  _widgetbook.WidgetbookCategory(
    name: 'Atoms',
    children: [
      _widgetbook.WidgetbookFolder(
        name: 'Indicators',
        children: [
          _widgetbook.WidgetbookComponent(
            name: 'BebeIndicatorDot',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Tamaños',
                builder: _widgetbook_app_use_cases_atoms_indicator_dot_use_cases
                    .indicatorDotSizes,
              ),
              _widgetbook.WidgetbookUseCase(
                name: 'Variantes',
                builder: _widgetbook_app_use_cases_atoms_indicator_dot_use_cases
                    .indicatorDotVariants,
              ),
            ],
          )
        ],
      )
    ],
  ),
  _widgetbook.WidgetbookCategory(
    name: 'Moleculas',
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
    name: 'Molecules',
    children: [
      _widgetbook.WidgetbookFolder(
        name: 'Cards',
        children: [
          _widgetbook.WidgetbookComponent(
            name: 'BebeDetailActionCard',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Contenido extenso',
                builder: _widgetbook_app_use_cases_templates_salud_template
                    .bebeDetailActionCardLongContent,
              ),
              _widgetbook.WidgetbookUseCase(
                name: 'Informativa sin chevron',
                builder: _widgetbook_app_use_cases_templates_salud_template
                    .bebeDetailActionCardInformative,
              ),
              _widgetbook.WidgetbookUseCase(
                name: 'Interactiva',
                builder: _widgetbook_app_use_cases_templates_salud_template
                    .bebeDetailActionCardInteractive,
              ),
              _widgetbook.WidgetbookUseCase(
                name: 'Variantes',
                builder: _widgetbook_app_use_cases_templates_salud_template
                    .bebeDetailActionCardVariants,
              ),
            ],
          )
        ],
      ),
      _widgetbook.WidgetbookFolder(
        name: 'Feedback',
        children: [
          _widgetbook.WidgetbookComponent(
            name: 'BebeInfoBanner',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Ancho compacto',
                builder: _widgetbook_app_use_cases_molecules_info_banner
                    .bebeInfoBannerCompact,
              ),
              _widgetbook.WidgetbookUseCase(
                name: 'Con acción',
                builder: _widgetbook_app_use_cases_molecules_info_banner
                    .bebeInfoBannerWithAction,
              ),
              _widgetbook.WidgetbookUseCase(
                name: 'Solo descripción',
                builder: _widgetbook_app_use_cases_molecules_info_banner
                    .bebeInfoBannerDescriptionOnly,
              ),
              _widgetbook.WidgetbookUseCase(
                name: 'Variantes',
                builder: _widgetbook_app_use_cases_molecules_info_banner
                    .bebeInfoBannerVariants,
              ),
            ],
          )
        ],
      ),
      _widgetbook.WidgetbookFolder(
        name: 'Filters',
        children: [
          _widgetbook.WidgetbookComponent(
            name: 'BebeFilterChip',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Contenido largo',
                builder:
                    _widgetbook_app_use_cases_molecules_filter_chip_use_cases
                        .filterChipLongContent,
              ),
              _widgetbook.WidgetbookUseCase(
                name: 'Estados',
                builder:
                    _widgetbook_app_use_cases_molecules_filter_chip_use_cases
                        .filterChipStates,
              ),
              _widgetbook.WidgetbookUseCase(
                name: 'Seleccionados',
                builder:
                    _widgetbook_app_use_cases_molecules_filter_chip_use_cases
                        .filterChipSelected,
              ),
              _widgetbook.WidgetbookUseCase(
                name: 'Variantes',
                builder:
                    _widgetbook_app_use_cases_molecules_filter_chip_use_cases
                        .filterChipVariants,
              ),
            ],
          )
        ],
      ),
      _widgetbook.WidgetbookFolder(
        name: 'Identity',
        children: [
          _widgetbook.WidgetbookComponent(
            name: 'BebeCaregiverBadge',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Estados',
                builder: _widgetbook_app_use_cases_molecules_caregiver_badge
                    .bebeCaregiverBadgeStates,
              ),
              _widgetbook.WidgetbookUseCase(
                name: 'Tamaños',
                builder: _widgetbook_app_use_cases_molecules_caregiver_badge
                    .bebeCaregiverBadgeSizes,
              ),
              _widgetbook.WidgetbookUseCase(
                name: 'Variantes',
                builder: _widgetbook_app_use_cases_molecules_caregiver_badge
                    .bebeCaregiverBadgeVariants,
              ),
            ],
          )
        ],
      ),
      _widgetbook.WidgetbookFolder(
        name: 'Information',
        children: [
          _widgetbook.WidgetbookComponent(
            name: 'BebeDetailSummaryCard',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Resumen de consulta',
                builder: _widgetbook_app_use_cases_templates_salud_template
                    .bebeDetailSummaryCardDefault,
              ),
              _widgetbook.WidgetbookUseCase(
                name: 'Valores extensos',
                builder: _widgetbook_app_use_cases_templates_salud_template
                    .bebeDetailSummaryCardLongValues,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'BebeTimeBlock',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Composiciones',
                builder:
                    _widgetbook_app_use_cases_molecules_time_block_uses_cases
                        .bebeTimeBlockCompositions,
              ),
              _widgetbook.WidgetbookUseCase(
                name: 'Tamaños y alineación',
                builder:
                    _widgetbook_app_use_cases_molecules_time_block_uses_cases
                        .bebeTimeBlockSizes,
              ),
              _widgetbook.WidgetbookUseCase(
                name: 'Variantes',
                builder:
                    _widgetbook_app_use_cases_molecules_time_block_uses_cases
                        .bebeTimeBlockVariants,
              ),
            ],
          ),
        ],
      ),
      _widgetbook.WidgetbookFolder(
        name: 'Selection',
        children: [
          _widgetbook.WidgetbookComponent(
            name: 'BebeSelectableDateCell',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Estados',
                builder:
                    _widgetbook_app_use_cases_molecules_selectable_date_cell_use_cases
                        .selectableDateCellStates,
              ),
              _widgetbook.WidgetbookUseCase(
                name: 'Indicadores',
                builder:
                    _widgetbook_app_use_cases_molecules_selectable_date_cell_use_cases
                        .selectableDateCellIndicators,
              ),
              _widgetbook.WidgetbookUseCase(
                name: 'Variantes visuales',
                builder:
                    _widgetbook_app_use_cases_molecules_selectable_date_cell_use_cases
                        .selectableDateCellVariants,
              ),
            ],
          )
        ],
      ),
    ],
  ),
  _widgetbook.WidgetbookCategory(
    name: 'Templates',
    children: [
      _widgetbook.WidgetbookFolder(
        name: 'Agenda',
        children: [
          _widgetbook.WidgetbookComponent(
            name: 'BebeAgendaTemplate',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Agenda vacía',
                builder: _widgetbook_app_use_cases_templates_agenda_template
                    .bebeAgendaTemplateEmptyUseCase,
              ),
              _widgetbook.WidgetbookUseCase(
                name: 'Cargando',
                builder: _widgetbook_app_use_cases_templates_agenda_template
                    .bebeAgendaTemplateLoadingUseCase,
              ),
              _widgetbook.WidgetbookUseCase(
                name: 'Contenido completo',
                builder: _widgetbook_app_use_cases_templates_agenda_template
                    .bebeAgendaTemplateContentUseCase,
              ),
              _widgetbook.WidgetbookUseCase(
                name: 'Error',
                builder: _widgetbook_app_use_cases_templates_agenda_template
                    .bebeAgendaTemplateErrorUseCase,
              ),
              _widgetbook.WidgetbookUseCase(
                name: 'Offline con contenido local',
                builder: _widgetbook_app_use_cases_templates_agenda_template
                    .bebeAgendaTemplateOfflineUseCase,
              ),
            ],
          )
        ],
      ),
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
      ),
      _widgetbook.WidgetbookFolder(
        name: 'Salud',
        children: [
          _widgetbook.WidgetbookComponent(
            name: 'BebeConsultationDetailTemplate',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Ancho móvil',
                builder: _widgetbook_app_use_cases_templates_salud_template
                    .bebeConsultationDetailTemplateMobile,
              ),
              _widgetbook.WidgetbookUseCase(
                name: 'Consulta completa',
                builder: _widgetbook_app_use_cases_templates_salud_template
                    .bebeConsultationDetailTemplateComplete,
              ),
              _widgetbook.WidgetbookUseCase(
                name: 'Contenido extenso',
                builder: _widgetbook_app_use_cases_templates_salud_template
                    .bebeConsultationDetailTemplateLongContent,
              ),
              _widgetbook.WidgetbookUseCase(
                name: 'Solo información',
                builder: _widgetbook_app_use_cases_templates_salud_template
                    .bebeConsultationDetailTemplateReadOnly,
              ),
            ],
          )
        ],
      ),
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
