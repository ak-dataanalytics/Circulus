import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/api_service.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/widgets/circulus_card.dart';
import '../../../core/widgets/circulus_avatar.dart';

class DirectoryScreen extends StatefulWidget {
  const DirectoryScreen({super.key});

  @override
  State<DirectoryScreen> createState() => _DirectoryScreenState();
}

class _DirectoryScreenState extends State<DirectoryScreen> {
  final _searchController = TextEditingController();
  List<dynamic> _members = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchDirectory();
  }

  Future<void> _fetchDirectory([String? query]) async {
    setState(() => _isLoading = true);
    try {
      final res = await ApiService().dio.get(
        ApiConstants.directory,
        queryParameters: query != null && query.isNotEmpty ? {'query': query} : null,
      );
      if (res.data is List) {
        setState(() => _members = res.data);
      }
    } catch (_) {
      // Demo members for preview
      setState(() {
        _members = [
          {
            'id': 'm1',
            'full_name': 'Prof. Rajesh Sharma',
            'designation': 'Professor of Public Policy',
            'current_posting': 'National Academy of Administration',
            'is_verified': true,
          },
          {
            'id': 'm2',
            'full_name': 'Ananya Verma',
            'designation': 'Deputy Secretary (Level 12)',
            'current_posting': 'Ministry of Finance, New Delhi',
            'is_verified': true,
          },
          {
            'id': 'm3',
            'full_name': 'Vikram Singh',
            'designation': 'Joint Director (Level 11)',
            'current_posting': 'State Secretariat, Mumbai',
            'is_verified': true,
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
        title: const Text('Member Directory'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
              controller: _searchController,
              onSubmitted: _fetchDirectory,
              style: const TextStyle(color: AppColors.pureWhite),
              decoration: InputDecoration(
                hintText: 'Search by officer name, batch, designation...',
                prefixIcon: const Icon(Icons.search, color: AppColors.premiumGold),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.filter_list, color: AppColors.mutedGrey),
                  onPressed: () {},
                ),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.premiumGold))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: _members.length,
                    itemBuilder: (context, index) {
                      final member = _members[index];
                      final name = member['full_name'] ?? 'Officer';
                      final designation = member['designation'] ?? 'Civil Services';
                      final posting = member['current_posting'] ?? 'Government of India';

                      return CirculusCard(
                        padding: const EdgeInsets.all(14),
                        onTap: () {},
                        child: Row(
                          children: [
                            CirculusAvatar(name: name, radius: 24, showBadge: true),
                            const SizedBox(width: 14),
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
                                  const SizedBox(height: 2),
                                  Text(
                                    designation,
                                    style: const TextStyle(
                                      color: AppColors.premiumGold,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    posting,
                                    style: const TextStyle(
                                      color: AppColors.mutedGrey,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.mail_outline, color: AppColors.premiumGold, size: 20),
                              onPressed: () => context.push('/chat'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
