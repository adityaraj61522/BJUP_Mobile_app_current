import 'package:bjup_application/common/color_pallet/color_pallet.dart';
import 'package:flutter/material.dart';

class ModuleSelectionView extends StatelessWidget {
  const ModuleSelectionView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard"),
        backgroundColor: AppColors.black,
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildDashboardButton(
              icon: Icons.calendar_month_rounded,
              label: "Field Attendance",
              onTap: () => {},
              // onTap: () => Get.to(() => const FieldAttendanceScreen()),
            ),
            const SizedBox(height: 20),
            _buildDashboardButton(
              icon: Icons.analytics,
              label: "Project Monitoring",
              onTap: () => {},
              // onTap: () => Get.to(() => const ProjectMonitoringScreen()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardButton(
      {required IconData icon,
      required String label,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 250,
        height: 250,
        decoration: BoxDecoration(
          color: AppColors.black,
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
            Icon(icon, color: AppColors.white, size: 40),
            const SizedBox(height: 10),
            Text(
              label,
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
}
