import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../theme/app_colors.dart';

class CirculusAvatar extends StatelessWidget {
  final String? imageUrl;
  final String name;
  final double radius;
  final bool showBadge;

  const CirculusAvatar({
    super.key,
    this.imageUrl,
    required this.name,
    this.radius = 24,
    this.showBadge = false,
  });

  String get _initials {
    if (name.isEmpty) return 'C';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    Widget avatar;
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      avatar = CircleAvatar(
        radius: radius,
        backgroundColor: AppColors.surfaceNavy,
        backgroundImage: CachedNetworkImageProvider(imageUrl!),
      );
    } else {
      avatar = CircleAvatar(
        radius: radius,
        backgroundColor: AppColors.surfaceNavy,
        child: Text(
          _initials,
          style: TextStyle(
            color: AppColors.premiumGold,
            fontWeight: FontWeight.bold,
            fontSize: radius * 0.7,
          ),
        ),
      );
    }

    if (!showBadge) return avatar;

    return Stack(
      children: [
        avatar,
        Positioned(
          right: 0,
          bottom: 0,
          child: Container(
            padding: const EdgeInsets.all(2),
            decoration: const BoxDecoration(
              color: AppColors.midnightNavy,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.verified,
              color: AppColors.premiumGold,
              size: 16,
            ),
          ),
        ),
      ],
    );
  }
}
