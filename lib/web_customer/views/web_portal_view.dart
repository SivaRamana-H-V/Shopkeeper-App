import 'package:flutter/material.dart';
import 'package:shopkeeper_app/core/theme/app_colors.dart';

class WebPortalView extends StatelessWidget {
  const WebPortalView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.link_off, size: 64, color: AppColors.textSecondary),
            SizedBox(height: 16),
            Text(
              "Customer Portal",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              "Please open the link shared by your shopkeeper.",
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
