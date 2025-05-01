import 'package:bjup_application/common/response_models/attendence_record_model/attendence_record_model.dart';
import 'package:bjup_application/common/response_models/get_beneficiary_response/get_beneficiary_response.dart';
import 'package:bjup_application/common/response_models/get_question_form_response/get_question_form_response.dart';
import 'package:bjup_application/common/response_models/get_question_set_response/get_question_set_response.dart';
import 'package:bjup_application/common/response_models/get_village_list_response/get_village_list_response.dart';
import 'package:bjup_application/common/routes/routes.dart';
import 'package:bjup_application/common/translations/translations_localization.dart';
import 'package:bjup_application/login_page/login_controller.dart';
import 'package:bjup_application/survey_form/survey_form_enum.g.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final dir = await getApplicationDocumentsDirectory();
  await Hive.initFlutter(dir.path);
  Hive.registerAdapter(VillagesListAdapter());
  Hive.registerAdapter(BeneficiaryDataAdapter());
  Hive.registerAdapter(FormQuestionDataAdapter());
  Hive.registerAdapter(QuestionSetListAdapter());
  Hive.registerAdapter(QuestionDropdownOptionAdapter());
  Hive.registerAdapter(QuestionTypeAdapter());
  Hive.registerAdapter(AttendanceRecordAdapter());
  Hive.registerAdapter(CBODataAdapter());
  Get.put(LoginController());

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'BJUP Application',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
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
