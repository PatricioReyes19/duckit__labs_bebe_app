import 'bebe_brand_mark_variant.dart';

abstract final class BebeBrandAssets {
  static const _basePath = 'assets/branding/brand';

  static String pathFor(BebeBrandMarkVariant variant) {
    return switch (variant) {
      BebeBrandMarkVariant.master =>
        '$_basePath/bebeapp_symbol_master_1024.png',
      BebeBrandMarkVariant.light =>
        '$_basePath/bebeapp_symbol_on_light_1024.png',
      BebeBrandMarkVariant.darkColor =>
        '$_basePath/bebeapp_symbol_color_on_dark_1024.png',
      BebeBrandMarkVariant.monochromeNavy =>
        '$_basePath/bebeapp_symbol_monochrome_navy_1024.png',
      BebeBrandMarkVariant.monochromeWhite =>
        '$_basePath/bebeapp_symbol_monochrome_white_1024.png',
    };
  }

  static const packageName = 'design_system';
}
