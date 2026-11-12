import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/api_service.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/widgets/circulus_avatar.dart';
import '../../../core/widgets/circulus_card.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic> _profile = {
    'full_name': 'Ananya Verma',
    'designation': 'Deputy Secretary (Level 12)',
    'department': 'Department of Revenue & Public Finance',
    'current_posting': 'Ministry of Finance, New Delhi',
    'batch': 'Batch of 2021 (Foundational)',
    'institution': 'National Academy of Administration',
    'bio': 'Civil servant dedicated to fiscal federalism, transparent capital allocation, and public infrastructure financing.',
    'points': 820,
    'podium_gold': 2,
    'podium_silver': 1,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.midnightNavy,
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: AppColors.premiumGold),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Profile Header Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.deepNavy,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.borderGrey),
            ),
            child: Column(
              children: [
                CirculusAvatar(name: _profile['full_name'], radius: 44, showBadge: true),
                const SizedBox(height: 14),
                Text(
                  _profile['full_name'],
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.pureWhite),
                ),
                const SizedBox(height: 4),
                Text(
                  _profile['designation'],
                  style: const TextStyle(color: AppColors.premiumGold, fontWeight: FontWeight.w600, fontSize: 13),
                ),
                const SizedBox(height: 4),
                Text(
                  _profile['current_posting'],
                  style: const TextStyle(color: AppColors.mutedGrey, fontSize: 12),
                ),
                const SizedBox(height: 16),
                // Points & Badges Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _MetricColumn(label: 'WEEKLY POINTS', value: '${_profile['points']}'),
                    Container(height: 24, width: 1, color: AppColors.borderGrey),
                    _MetricColumn(label: 'GOLD PODIUMS', value: '${_profile['podium_gold']} 🥇'),
                    Container(height: 24, width: 1, color: AppColors.borderGrey),
                    _MetricColumn(label: 'SILVER PODIUMS', value: '${_profile['podium_silver']} 🥈'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Institutional Details
          CirculusCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Institutional Credentials', style: TextStyle(color: AppColors.premiumGold, fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 12),
                _InfoRow(label: 'Cadre / Batch', value: _profile['batch']),
                const SizedBox(height: 8),
                _InfoRow(label: 'Training Institution', value: _profile['institution']),
                const SizedBox(height: 8),
                _InfoRow(label: 'Department', value: _profile['department']),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Biography
          CirculusCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Professional Introduction', style: TextStyle(color: AppColors.premiumGold, fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 8),
                Text(
                  _profile['bio'],
                  style: const TextStyle(color: AppColors.pureWhite, fontSize: 13, height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricColumn extends StatelessWidget {
  final String label;
  final String value;
  const _MetricColumn({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: const TextStyle(color: AppColors.pureWhite, fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: AppColors.mutedGrey, fontSize: 10, letterSpacing: 0.5)),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 130, child: Text(label, style: const TextStyle(color: AppColors.mutedGrey, fontSize: 12))),
        Expanded(child: Text(value, style: const TextStyle(color: AppColors.pureWhite, fontSize: 13, fontWeight: FontWeight.w500))),
      ],
    );
  }
}
