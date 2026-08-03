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
  rules: [
    AppLayoutVisibilityRule.prefix(
      path: '/register',
      chrome: AppLayoutChromeConfig(
        showHeader: false,
        showBottomBar: false,
        showPrimaryAction: false,
      ),
    ),
    AppLayoutVisibilityRule.prefix(
      path: '/settings',
      chrome: AppLayoutChromeConfig(
        showHeader: true,
        showBottomBar: false,
        showPrimaryAction: false,
        showBackButton: true,
        title: 'Configuración',
      ),
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
