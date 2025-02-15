import 'package:bjup_application/common/color_pallet/color_pallet.dart';
import 'package:bjup_application/login_page/login_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginScreen extends StatelessWidget {
  final LoginController controller = Get.put(LoginController());

  LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Stack(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                    "lib/assets/images/bjup_logo_zoom.png"), // Your logo as background
                fit: BoxFit.fitWidth, // Covers the entire screen
                opacity: 0.3,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Spacer(),
                  Text(
                    'log_in'.tr, // Translatable text
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.black,
                    ),
                  ),
                  const SizedBox(height: 30),
                  TextField(
                    controller: controller.usernameController,
                    decoration: InputDecoration(
                      prefixIcon:
                          const Icon(Icons.person, color: AppColors.black),
                      hintText: 'username'.tr,
                      hintStyle: const TextStyle(color: AppColors.black),
                      enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: AppColors.black),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: AppColors.orange),
                      ),
                    ),
                    style: const TextStyle(color: AppColors.black),
                  ),
                  const SizedBox(height: 20),
                  Obx(() => TextField(
                        controller: controller.passwordController,
                        obscureText: controller.obscureText.value,
                        decoration: InputDecoration(
                          prefixIcon:
                              const Icon(Icons.lock, color: AppColors.black),
                          suffixIcon: IconButton(
                            icon: Icon(
                              controller.obscureText.value
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: AppColors.black,
                            ),
                            onPressed: () =>
                                controller.togglePasswordVisibility(),
                          ),
                          hintText: 'password'.tr, // Translatable text
                          hintStyle: const TextStyle(color: AppColors.black),
                          enabledBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: AppColors.black),
                          ),
                          focusedBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: AppColors.orange),
                          ),
                        ),
                        style: const TextStyle(color: AppColors.black),
                      )),
                  const SizedBox(height: 10),
                  Obx(() => controller.errorText.value.isNotEmpty
                      ? Text(
                          controller.errorText.value,
                          style: const TextStyle(
                              color: AppColors.red, fontSize: 14),
                        )
                      : Container()),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.black,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                      onPressed: () => controller.login(),
                      child: Text(
                        'login'.tr, // Translatable text
                        style: const TextStyle(
                            fontSize: 18, color: AppColors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Spacer(),
                  Center(
                    child: ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor:
                            WidgetStateProperty.all(AppColors.black), // Updated
                      ),
                      onPressed: () {
                        var locale = Get.locale == const Locale('en', 'US')
                            ? const Locale('hi', 'IN')
                            : const Locale('en', 'US');
                        Get.updateLocale(locale);
                      },
                      child: Text(
                        'Switch Language',
                        style: TextStyle(color: AppColors.white),
                      ),
                    ),
                  ),
                  SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
