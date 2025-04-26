import 'package:bjup_application/common/color_pallet/color_pallet.dart';
import 'package:bjup_application/common/routes/routes.dart';
import 'package:bjup_application/common/session/session_manager.dart';
import 'package:bjup_application/module_selection_page/module_selection_view_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ModuleSelectionView extends GetView<ModuleSelectionController> {
  final sessionManager = SessionManager();

  ModuleSelectionView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            _buildLogoAndLanguageSwitcher(),
            Spacer(),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildDashboardButton(
                    icon: Icons.calendar_month_rounded,
                    label: "Attendance".tr,
                    onTap: () => Get.toNamed(AppRoutes.attendenceList),
                    tileColor: AppColors.blue,
                  ),
                  const SizedBox(height: 20),
                  _buildDashboardButton(
                    icon: Icons.screenshot_monitor_rounded,
                    label: "Monitoring".tr,
                    onTap: () => Get.toNamed(AppRoutes.projectList),
                    tileColor: const Color.fromARGB(255, 25, 107, 25),
                  ),
                ],
              ),
            ),
            Spacer(),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      toolbarHeight: 0,
      backgroundColor: AppColors.white,
      centerTitle: true,
    );
  }

  Widget _buildLogoAndLanguageSwitcher() {
    return Padding(
      padding: const EdgeInsets.only(top: 12.0, bottom: 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLogo("lib/assets/images/bjup_logo_zoom.png"),
          _buildLanguageSwitcher(),
        ],
      ),
    );
  }

  Widget _buildLogo(String logoPath) {
    return Container(
      height: 150,
      width: 150,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(logoPath),
          alignment: Alignment.topLeft,
        ),
      ),
    );
  }

  Widget _buildDashboardButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color tileColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 250,
        height: 250,
        decoration: BoxDecoration(
          color: tileColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              blurRadius: 5,
              spreadRadius: 2,
              offset: const Offset(2, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.white, size: 70),
            const SizedBox(height: 10),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageSwitcher() {
    return Align(
      alignment: Alignment.topRight,
      child: InkWell(
        onTap: () {
          final isEnglish = Get.locale?.languageCode == 'en';
          Get.updateLocale(
              isEnglish ? const Locale('hi', 'IN') : const Locale('en', 'US'));
        },
        child: Container(
          height: 50,
          width: 150,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: AppColors.black),
          ),
          child: Row(
            children: [
              _buildLanguageButton("English", 'en'),
              _buildLanguageButton("Hindi", 'hi'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageButton(String text, String languageCode) {
    final isSelected = Get.locale?.languageCode == languageCode;
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? AppColors.black : AppColors.white,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: isSelected ? AppColors.white : AppColors.black,
            ),
          ),
        ),
      ),
    );
  }
}
