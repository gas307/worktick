import 'package:easy_localization/easy_localization.dart';

/// Mapuje kody z bazy ('office' | 'remote' | 'field') na Twoje klucze app.*
String trWorkType(String code) {
  switch (code) {
    case 'office':
      return 'app.office'.tr();
    case 'remote':
      return 'app.remote'.tr();
    case 'field':
      return 'app.field'.tr();
    default:
      return code; // fallback
  }
}
