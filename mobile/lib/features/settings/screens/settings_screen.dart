import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/api_service.dart';
import '../../../core/widgets/circulus_card.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.midnightNavy,
      appBar: AppBar(
        title: const Text('Settings & Privacy'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          CirculusCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.notifications_outlined, color: AppColors.premiumGold),
                  title: const Text('Notification Preferences', style: TextStyle(color: AppColors.pureWhite, fontSize: 14)),
                  trailing: const Icon(Icons.chevron_right, color: AppColors.mutedGrey),
                  onTap: () {},
                ),
                const Divider(height: 1, color: AppColors.borderGrey),
                ListTile(
                  leading: const Icon(Icons.lock_outline, color: AppColors.premiumGold),
                  title: const Text('Security & Password', style: TextStyle(color: AppColors.pureWhite, fontSize: 14)),
                  trailing: const Icon(Icons.chevron_right, color: AppColors.mutedGrey),
                  onTap: () {},
                ),
                const Divider(height: 1, color: AppColors.borderGrey),
                ListTile(
                  leading: const Icon(Icons.visibility_outlined, color: AppColors.premiumGold),
                  title: const Text('Profile Visibility', style: TextStyle(color: AppColors.pureWhite, fontSize: 14)),
                  trailing: const Icon(Icons.chevron_right, color: AppColors.mutedGrey),
                  onTap: () {},
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          CirculusCard(
            padding: EdgeInsets.zero,
            child: ListTile(
              leading: const Icon(Icons.logout, color: AppColors.error),
              title: const Text('Sign Out', style: TextStyle(color: AppColors.error, fontSize: 14, fontWeight: FontWeight.bold)),
              onTap: () async {
                await ApiService().clearToken();
                if (context.mounted) context.go('/welcome');
              },
            ),
          ),
        ],
      ),
    );
  }
}
