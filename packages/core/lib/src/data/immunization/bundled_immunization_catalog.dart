import 'dart:convert';

import 'package:flutter/services.dart';

import '../../domain/entities/immunization/immunization.dart';

/// Loads the MVP catalogue from a versioned bundled asset. Future signed
/// remote catalogues can implement the same decoding contract.
abstract final class BundledImmunizationCatalog {
  static const assetPath = 'packages/core/assets/catalogs/pni_2026.json';
  static Future<ImmunizationCatalog>? _cached;

  static Future<ImmunizationCatalog> load() => _cached ??= _load();

  static Future<ImmunizationCatalog> _load() async {
    final json = jsonDecode(await rootBundle.loadString(assetPath));
    if (json is! Map<String, dynamic>) {
      throw const FormatException('Invalid bundled immunization catalogue.');
    }
    final rawItems = json['items'];
    if (rawItems is! List) {
      throw const FormatException('Catalogue items are required.');
    }
    return ImmunizationCatalog(
      version: _text(json, 'version'),
      sourceName: _text(json, 'sourceName'),
      items: List.unmodifiable(
        rawItems.map((value) {
          if (value is! Map) {
            throw const FormatException('Invalid catalogue item.');
          }
          return _item(Map<String, dynamic>.from(value));
        }),
      ),
    );
  }

  static ImmunizationCatalogItem _item(Map<String, dynamic> json) {
    final targetAge = json['targetAge'];
    if (targetAge is! Map) {
      throw const FormatException('Catalogue target age is required.');
    }
    return ImmunizationCatalogItem(
      id: _text(json, 'id'),
      displayName: _text(json, 'displayName'),
      itemType: _enumByName(
        ImmunizationItemType.values,
        _text(json, 'itemType'),
      ),
      sourceType: _enumByName(
        ImmunizationSourceType.values,
        _text(json, 'sourceType'),
      ),
      targetAge: ImmunizationTargetAge(
        days: (targetAge['days'] as num?)?.toInt() ?? 0,
        months: (targetAge['months'] as num?)?.toInt() ?? 0,
      ),
      doseLabel: _text(json, 'doseLabel'),
      eligibilityRule: _enumByName(
        ImmunizationEligibilityRule.values,
        _text(json, 'eligibilityRule'),
      ),
      effectiveFrom: _date(json['effectiveFrom']),
      effectiveTo: _date(json['effectiveTo']),
      sourceVersion: _text(json, 'sourceVersion'),
      sourceName: _text(json, 'sourceName'),
      minimumBirthDate: _date(json['minimumBirthDate']),
      maximumBirthDate: _date(json['maximumBirthDate']),
      campaignStart: _date(json['campaignStart']),
      campaignEnd: _date(json['campaignEnd']),
      campaignOffsetDays: (json['campaignOffsetDays'] as num?)?.toInt() ?? 0,
      minimumAgeMonths: (json['minimumAgeMonths'] as num?)?.toInt(),
      maximumAgeMonths: (json['maximumAgeMonths'] as num?)?.toInt(),
      administrationGroup: json['administrationGroup'] as String?,
      administrationPriority:
          (json['administrationPriority'] as num?)?.toInt() ?? 0,
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  static String _text(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is! String || value.trim().isEmpty) {
      throw FormatException('Catalogue field "$key" is required.');
    }
    return value.trim();
  }

  static DateTime? _date(Object? value) {
    if (value == null) return null;
    if (value is! String)
      throw const FormatException('Invalid catalogue date.');
    return DateTime.parse(value).toLocal();
  }

  static T _enumByName<T extends Enum>(List<T> values, String name) =>
      values.firstWhere(
        (value) => value.name == name,
        orElse: () =>
            throw FormatException('Unsupported catalogue value: $name'),
      );
}
