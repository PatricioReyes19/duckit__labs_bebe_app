import 'package:app_layout/app_layout.dart';
import 'package:flutter/material.dart';

const appLayoutTabs = <AppLayoutTabConfig>[
  AppLayoutTabConfig(
    id: 'home',
    label: 'Inicio',
    route: '/home',
    icon: Icon(Icons.home_outlined),
    selectedIcon: Icon(Icons.home_rounded),
    branchIndex: 0,
    order: 0,
  ),
  AppLayoutTabConfig(
    id: 'agenda',
    label: 'Agenda',
    route: '/agenda',
    icon: Icon(Icons.calendar_today_outlined),
    selectedIcon: Icon(Icons.calendar_month_rounded),
    branchIndex: 1,
    order: 1,
  ),
  AppLayoutTabConfig(
    id: 'health',
    label: 'Salud',
    route: '/health',
    icon: Icon(Icons.health_and_safety_outlined),
    selectedIcon: Icon(Icons.health_and_safety_rounded),
    branchIndex: 2,
    order: 2,
  ),
  AppLayoutTabConfig(
    id: 'family',
    label: 'Familia',
    route: '/family',
    icon: Icon(Icons.groups_outlined),
    selectedIcon: Icon(Icons.groups_rounded),
    branchIndex: 3,
    order: 3,
  ),
];

const appLayoutVisibilityPolicy = AppLayoutVisibilityPolicy(
  fallback: AppLayoutChromeConfig.subview(title: 'Detalle'),
  rules: [
    AppLayoutVisibilityRule.exact(
      path: '/home',
      chrome: AppLayoutChromeConfig(
        title: 'BebéApp',
        showBrandMark: true,
      ),
    ),
    AppLayoutVisibilityRule.exact(
      path: '/home/history',
      chrome: AppLayoutChromeConfig(
        title: 'Historial de hoy',
        showBottomBar: false,
        showPrimaryAction: false,
        showBrandMark: false,
        showBackButton: true,
      ),
    ),
    AppLayoutVisibilityRule.exact(
      path: '/agenda',
      chrome: AppLayoutChromeConfig(
        title: 'Agenda de salud',
        showBrandMark: false,
      ),
    ),
    AppLayoutVisibilityRule.exact(
      path: '/agenda/reminders/settings',
      chrome: AppLayoutChromeConfig.subview(
        title: 'Configurar recordatorios',
      ),
    ),
    AppLayoutVisibilityRule.exact(
      path: '/agenda/reminders/new',
      chrome: AppLayoutChromeConfig.subview(title: 'Nuevo recordatorio'),
    ),
    AppLayoutVisibilityRule.prefix(
      path: '/agenda/events',
      chrome: AppLayoutChromeConfig.subview(title: 'Detalle del evento'),
    ),
    AppLayoutVisibilityRule.exact(
      path: '/health',
      chrome: AppLayoutChromeConfig(
        title: 'Salud',
        showBrandMark: false,
      ),
    ),
    AppLayoutVisibilityRule.exact(
      path: '/health/vaccines',
      chrome: AppLayoutChromeConfig.subview(title: 'Vacunas'),
    ),
    AppLayoutVisibilityRule.exact(
      path: '/health/controls',
      chrome: AppLayoutChromeConfig.subview(title: 'Controles'),
    ),
    AppLayoutVisibilityRule.exact(
      path: '/health/growth',
      chrome: AppLayoutChromeConfig.subview(title: 'Crecimiento'),
    ),
    AppLayoutVisibilityRule.exact(
      path: '/health/consultations',
      chrome: AppLayoutChromeConfig.subview(title: 'Consultas'),
    ),
    AppLayoutVisibilityRule.exact(
      path: '/health/pediatric-care',
      chrome: AppLayoutChromeConfig.subview(title: 'Atención pediátrica'),
    ),
    AppLayoutVisibilityRule.exact(
      path: '/health/clinical-history',
      chrome: AppLayoutChromeConfig.subview(title: 'Historial clínico'),
    ),
    AppLayoutVisibilityRule.exact(
      path: '/family',
      chrome: AppLayoutChromeConfig(
        title: 'BebéApp',
        showBrandMark: false,
      ),
    ),
    AppLayoutVisibilityRule.exact(
      path: '/family/babies',
      chrome: AppLayoutChromeConfig.subview(title: 'Seleccionar bebé'),
    ),
    AppLayoutVisibilityRule.exact(
      path: '/family/babies/new',
      chrome: AppLayoutChromeConfig.subview(title: 'Agregar bebé'),
    ),
    AppLayoutVisibilityRule.prefix(
      path: '/family/babies/',
      chrome: AppLayoutChromeConfig.subview(title: 'Perfil del bebé'),
    ),
    AppLayoutVisibilityRule.exact(
      path: '/family/care-circle',
      chrome: AppLayoutChromeConfig.subview(title: 'Círculo de cuidado'),
    ),
    AppLayoutVisibilityRule.exact(
      path: '/family/care-circle/invite',
      chrome: AppLayoutChromeConfig.subview(title: 'Invitar cuidador'),
    ),
    AppLayoutVisibilityRule.prefix(
      path: '/family/members',
      chrome: AppLayoutChromeConfig.subview(title: 'Detalle del cuidador'),
    ),
    AppLayoutVisibilityRule.exact(
      path: '/family/family-configuration',
      chrome: AppLayoutChromeConfig.subview(title: 'Configuración familiar'),
    ),
    AppLayoutVisibilityRule.prefix(
      path: '/register',
      chrome: AppLayoutChromeConfig(
        showHeader: false,
        showBottomBar: false,
        showPrimaryAction: false,
      ),
    ),
    AppLayoutVisibilityRule.exact(
      path: '/family/settings',
      chrome: AppLayoutChromeConfig.subview(title: 'Cuenta y preferencias'),
    ),
    AppLayoutVisibilityRule.exact(
      path: '/family/settings/account',
      chrome: AppLayoutChromeConfig.subview(title: 'Mi cuenta'),
    ),
    AppLayoutVisibilityRule.exact(
      path: '/family/settings/appearance',
      chrome: AppLayoutChromeConfig.subview(title: 'Apariencia'),
    ),
    AppLayoutVisibilityRule.exact(
      path: '/family/settings/security',
      chrome: AppLayoutChromeConfig.subview(title: 'Seguridad'),
    ),
    AppLayoutVisibilityRule.exact(
      path: '/family/settings/privacy',
      chrome: AppLayoutChromeConfig.subview(title: 'Privacidad'),
    ),
    AppLayoutVisibilityRule.prefix(
      path: '/family/settings/',
      chrome: AppLayoutChromeConfig.subview(title: 'Preferencias'),
    ),
    AppLayoutVisibilityRule.prefix(
      path: '/notifications',
      chrome: AppLayoutChromeConfig(
        showHeader: true,
        showBottomBar: false,
        showPrimaryAction: false,
        showBackButton: true,
        title: 'Notificaciones',
      ),
    ),
  ],
);
