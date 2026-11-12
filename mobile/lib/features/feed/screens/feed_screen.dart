import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/api_service.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/widgets/circulus_card.dart';
import '../../../core/widgets/circulus_avatar.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  List<dynamic> _posts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchFeed();
  }

  Future<void> _fetchFeed() async {
    setState(() => _isLoading = true);
    try {
      final res = await ApiService().dio.get(ApiConstants.feed);
      if (res.data is List) {
        setState(() => _posts = res.data);
      }
    } catch (_) {
      // Fallback sample post for initial onboarding display
      setState(() {
        _posts = [
          {
            'id': 'demo-post-1',
            'content': 'Welcome to CIRCULUS. An exclusive platform connecting officers and faculty across institutions. Share knowledge, engage with peers, and sharpen your intellect in the Brain Arena.',
            'like_count': 12,
            'comment_count': 3,
            'author': {
              'full_name': 'Prof. Rajesh Sharma',
              'designation': 'Faculty in Public Policy',
            }
          }
        ];
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.midnightNavy,
      appBar: AppBar(
        title: const Row(
          children: [
            Text('CIRCULUS', style: TextStyle(letterSpacing: 2, fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: AppColors.premiumGold),
            onPressed: () => context.push('/notifications'),
          ),
          IconButton(
            icon: const Icon(Icons.leaderboard_outlined, color: AppColors.premiumGold),
            onPressed: () => context.push('/leaderboard'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.premiumGold,
        foregroundColor: AppColors.midnightNavy,
        onPressed: () => context.push('/create-post'),
        child: const Icon(Icons.edit),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.premiumGold))
          : RefreshIndicator(
              onRefresh: _fetchFeed,
              color: AppColors.premiumGold,
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                children: [
                  // Daily Knowledge Drop Banner
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.deepNavy, AppColors.surfaceNavy],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.premiumGold.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.premiumGold.withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.lightbulb_outline, color: AppColors.premiumGold),
                        ),
                        const SizedBox(width: 14),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'DAILY KNOWLEDGE DROP',
                                style: TextStyle(
                                  color: AppColors.premiumGold,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.0,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'The 16th Finance Commission commenced deliberations on state tax sharing formulas.',
                                style: TextStyle(color: AppColors.pureWhite, fontSize: 13, height: 1.4),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Feed Posts
                  if (_posts.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Center(
                        child: Text(
                          'No posts yet. Be the first to share an update with the fraternity.',
                          style: TextStyle(color: AppColors.mutedGrey),
                        ),
                      ),
                    )
                  else
                    ..._posts.map((post) {
                      final author = post['author'] ?? {};
                      final name = author['full_name'] ?? 'Officer';
                      final designation = author['designation'] ?? 'Civil Services';

                      return CirculusCard(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CirculusAvatar(name: name, radius: 20, showBadge: true),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                          color: AppColors.pureWhite,
                                        ),
                                      ),
                                      Text(
                                        designation,
                                        style: const TextStyle(
                                          color: AppColors.mutedGrey,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              post['content'] ?? '',
                              style: const TextStyle(
                                color: AppColors.pureWhite,
                                fontSize: 14,
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Divider(color: AppColors.borderGrey, height: 1),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.favorite_border, size: 20, color: AppColors.mutedGrey),
                                      onPressed: () {},
                                    ),
                                    Text('${post['like_count'] ?? 0}', style: const TextStyle(color: AppColors.mutedGrey, fontSize: 13)),
                                    const SizedBox(width: 16),
                                    IconButton(
                                      icon: const Icon(Icons.chat_bubble_outline, size: 20, color: AppColors.mutedGrey),
                                      onPressed: () {},
                                    ),
                                    Text('${post['comment_count'] ?? 0}', style: const TextStyle(color: AppColors.mutedGrey, fontSize: 13)),
                                  ],
                                ),
                                IconButton(
                                  icon: const Icon(Icons.bookmark_border, size: 20, color: AppColors.mutedGrey),
                                  onPressed: () {},
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                ],
              ),
            ),
    );
  }
}
