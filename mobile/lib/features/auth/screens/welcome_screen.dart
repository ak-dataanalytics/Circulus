import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/circulus_button.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.midnightNavy,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(),
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.premiumGold, width: 2),
                  color: AppColors.deepNavy,
                ),
                child: const Center(
                  child: Text(
                    'C',
                    style: TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                      color: AppColors.premiumGold,
                      fontFamily: 'serif',
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 28),
              const Text(
                'CIRCULUS',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 3.0,
                  color: AppColors.pureWhite,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Exclusive Professional Social Network',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.premiumGold,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'A persistent fraternity connecting Level 7+ Government Officers, Faculty, and Alumni.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.mutedGrey,
                  height: 1.5,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.deepNavy,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.borderGrey),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.lock_outline, color: AppColors.premiumGold, size: 20),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Invitation-only network. Public registrations are strictly closed.',
                        style: TextStyle(fontSize: 12, color: AppColors.mutedGrey),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              CirculusButton(
                text: 'HAVE AN INVITATION? REGISTER',
                width: double.infinity,
                onPressed: () => context.push('/register'),
              ),
              const SizedBox(height: 12),
              CirculusButton(
                text: 'SIGN IN TO YOUR ACCOUNT',
                width: double.infinity,
                isOutlined: true,
                onPressed: () => context.push('/login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
