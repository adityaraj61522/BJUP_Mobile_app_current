import 'package:bjup_application/common/translations/en_translations.dart';
import 'package:bjup_application/common/translations/hi_translations.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LocalizationService extends Translations {
  static final locales = [
    const Locale('en', 'US'),
    const Locale('hi', 'IN'),
  ];

  @override
  Map<String, Map<String, String>> get keys => {
        'en_US': en,
        'hi_IN': hi,
      };
}
