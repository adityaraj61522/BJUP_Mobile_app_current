import 'package:bjup_application/common/color_pallet/color_pallet.dart';
import 'package:bjup_application/login_page/login_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginScreen extends GetView<LoginController> {
  final _formKey = GlobalKey<FormState>();

  LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        toolbarHeight: 0,
        backgroundColor: AppColors.white,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          _buildBackgroundImage(
              "lib/assets/images/village_img.png", Alignment.bottomCenter),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                _buildLogoAndLanguageSwitcher(),
                Expanded(
                  flex: 2,
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24.0),
                      child: Form(
                        key: _formKey,
                        child: _buildLoginForm(),
                      ),
                    ),
                  ),
                ),
                Spacer(),
                const SizedBox(height: 50), // Added spacing at the bottom
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundImage(String imagePath, Alignment alignment) {
    return Positioned.fill(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(imagePath),
            fit: BoxFit.fill,
            opacity: 0.7,
            alignment: alignment,
          ),
        ),
      ),
    );
  }

  Widget _buildLogoAndLanguageSwitcher() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLogo("lib/assets/images/bjup_logo_zoom.png"),
        _buildLanguageSwitcher(),
      ],
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

  Widget _buildLanguageSwitcher() {
    return InkWell(
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

  Widget _buildLoginForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'log_in'.tr,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.black,
          ),
        ),
        const SizedBox(height: 30),
        TextFormField(
          controller: controller.usernameController,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.person, color: AppColors.black),
            labelText: 'username'.tr,
            labelStyle: const TextStyle(color: AppColors.black),
            border: const OutlineInputBorder(),
            hintStyle: const TextStyle(color: AppColors.black),
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.black),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.green),
            ),
          ),
          style: const TextStyle(color: AppColors.black),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'username_required'.tr;
            }
            return null;
          },
        ),
        const SizedBox(height: 20),
        Obx(() => TextFormField(
              controller: controller.passwordController,
              obscureText: controller.obscureText.value,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.lock, color: AppColors.black),
                suffixIcon: IconButton(
                  icon: Icon(
                    controller.obscureText.value
                        ? Icons.visibility_off
                        : Icons.visibility,
                    color: AppColors.black,
                  ),
                  onPressed: () => controller.togglePasswordVisibility(),
                ),
                labelText: 'password'.tr,
                labelStyle: const TextStyle(color: AppColors.black),
                border: const OutlineInputBorder(),
                enabledBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.black),
                ),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.green),
                ),
              ),
              style: const TextStyle(color: AppColors.black),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'password_required'.tr;
                }
                if (value.length < 6) {
                  return 'password_length'.tr;
                }
                return null;
              },
            )),
        const SizedBox(height: 10),
        Obx(() => controller.errorText.value.isNotEmpty
            ? Text(
                controller.errorText.value,
                style: const TextStyle(color: AppColors.red, fontSize: 14),
              )
            : Container()),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.green,
              padding: const EdgeInsets.symmetric(vertical: 15),
            ),
            onPressed: _handleLogin,
            child: Obx(() => controller.isLoading.value
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: AppColors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    'login'.tr,
                    style:
                        const TextStyle(fontSize: 18, color: AppColors.white),
                  )),
          ),
        ),
      ],
    );
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        await controller.login();
      } catch (e) {
        Get.snackbar(
          'login_failed'.tr,
          'something_went_wrong'.tr,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.red,
          colorText: AppColors.white,
        );
      }
    }
  }
}
