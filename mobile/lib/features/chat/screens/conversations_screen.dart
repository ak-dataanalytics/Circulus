import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/api_service.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/widgets/circulus_card.dart';
import '../../../core/widgets/circulus_avatar.dart';

class ConversationsScreen extends StatefulWidget {
  const ConversationsScreen({super.key});

  @override
  State<ConversationsScreen> createState() => _ConversationsScreenState();
}

class _ConversationsScreenState extends State<ConversationsScreen> {
  List<dynamic> _conversations = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchConversations();
  }

  Future<void> _fetchConversations() async {
    setState(() => _isLoading = true);
    try {
      final res = await ApiService().dio.get(ApiConstants.conversations);
      if (res.data is List) {
        setState(() => _conversations = res.data);
      }
    } catch (_) {
      // Demo active conversations
      setState(() {
        _conversations = [
          {
            'id': 'conv-1',
            'title': 'Prof. Rajesh Sharma',
            'last_message': 'Looking forward to our discussion on the public finance seminar next week.',
            'time': '10:45 AM',
            'unread': 1,
            'is_group': false,
          },
          {
            'id': 'conv-2',
            'title': 'Batch of 2021 Coordination',
            'last_message': 'Vikram: I have uploaded the draft policy framework document.',
            'time': 'Yesterday',
            'unread': 0,
            'is_group': true,
          },
          {
            'id': 'conv-3',
            'title': 'Ananya Verma',
            'last_message': 'Thanks sir! That clarifies the regulatory provision completely.',
            'time': 'Monday',
            'unread': 0,
            'is_group': false,
          },
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
        title: const Text('Messages'),
        actions: [
          IconButton(
            icon: const Icon(Icons.group_add_outlined, color: AppColors.premiumGold),
            onPressed: () {},
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.premiumGold))
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _conversations.length,
              itemBuilder: (context, index) {
                final conv = _conversations[index];
                final title = conv['title'] ?? 'Direct Chat';
                final lastMsg = conv['last_message'] ?? '';
                final isGroup = conv['is_group'] == true;
                final unread = conv['unread'] ?? 0;

                return CirculusCard(
                  padding: const EdgeInsets.all(14),
                  onTap: () => context.push('/chat/detail', extra: {'title': title}),
                  child: Row(
                    children: [
                      isGroup
                          ? const CircleAvatar(
                              radius: 24,
                              backgroundColor: AppColors.surfaceNavy,
                              child: Icon(Icons.groups, color: AppColors.premiumGold),
                            )
                          : CirculusAvatar(name: title, radius: 24, showBadge: true),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: AppColors.pureWhite,
                                  ),
                                ),
                                Text(
                                  conv['time'] ?? '',
                                  style: const TextStyle(color: AppColors.mutedGrey, fontSize: 11),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              lastMsg,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: AppColors.mutedGrey, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                      if (unread > 0) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: AppColors.premiumGold,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '$unread',
                            style: const TextStyle(
                              color: AppColors.midnightNavy,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
    );
  }
}
