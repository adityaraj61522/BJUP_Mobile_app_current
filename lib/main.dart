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
  const MyApp({super.key}); // Add constructor with key

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'BJUP Application', // Add app title
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Add theme configuration
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      translations: LocalizationService(),
      locale: Get.deviceLocale,
      fallbackLocale: const Locale('en', 'US'),
      initialRoute: AppRoutes.login,
      getPages: AppRoutes.routes,
    );
  }
}
