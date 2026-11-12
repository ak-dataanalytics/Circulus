import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/circulus_card.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notifications = [
      {
        'title': 'Weekly Podium Recognition',
        'body': 'Congratulations! You secured Silver on the Week 44 Podium (+100 Achievement Pts).',
        'time': '2 hours ago',
        'icon': Icons.military_tech,
      },
      {
        'title': 'Faculty Announcement',
        'body': 'Prof. Rajesh Sharma scheduled an Executive Webinar on Capital Devolution.',
        'time': '5 hours ago',
        'icon': Icons.campaign_outlined,
      },
      {
        'title': 'Direct Message',
        'body': 'Vikram Singh sent you an attachment in Batch of 2021 Coordination.',
        'time': 'Yesterday',
        'icon': Icons.chat_bubble_outline,
      },
    ];

    return Scaffold(
      backgroundColor: AppColors.midnightNavy,
      appBar: AppBar(
        title: const Text('Notifications'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final n = notifications[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: CirculusCard(
              padding: const EdgeInsets.all(14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceNavy,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(n['icon'] as IconData, color: AppColors.premiumGold, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          n['title'] as String,
                          style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.pureWhite, fontSize: 14),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          n['body'] as String,
                          style: const TextStyle(color: AppColors.mutedGrey, fontSize: 12, height: 1.4),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          n['time'] as String,
                          style: const TextStyle(color: AppColors.premiumGold, fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
