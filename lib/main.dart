import 'package:bjup_application/common/routes/routes.dart';
import 'package:bjup_application/common/translations/translations_localization.dart';
import 'package:bjup_application/login_page/login_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final dir = await getApplicationDocumentsDirectory();
  await Hive.initFlutter(dir.path);
  Get.put(LoginController()); // Initialize controller

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      translations: LocalizationService(), // Set up translations
      locale: Get.deviceLocale, // Detect system language
      fallbackLocale: const Locale('en', 'US'), // Default to English
      initialRoute: AppRoutes.login, // Open LoginScreen first
      getPages: AppRoutes.routes, // Define routes
    );
  }
}
