import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/api_service.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/widgets/circulus_avatar.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, dynamic>> _topMembers = [
    {
      'rank': 1,
      'name': 'Ananya Verma',
      'designation': 'Deputy Secretary',
      'points': 820,
      'badge': 'Gold',
    },
    {
      'rank': 2,
      'name': 'Vikram Singh',
      'designation': 'Joint Director',
      'points': 750,
      'badge': 'Silver',
    },
    {
      'rank': 3,
      'name': 'Prof. Rajesh Sharma',
      'designation': 'Faculty in Public Policy',
      'points': 690,
      'badge': 'Bronze',
    },
    {
      'rank': 4,
      'name': 'Siddharth Rao',
      'designation': 'Under Secretary',
      'points': 520,
    },
    {
      'rank': 5,
      'name': 'Kavita Menon',
      'designation': 'Director, E-Gov',
      'points': 480,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.midnightNavy,
      appBar: AppBar(
        title: const Text('Leaderboard & Podium'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.premiumGold,
          labelColor: AppColors.premiumGold,
          unselectedLabelColor: AppColors.mutedGrey,
          tabs: const [
            Tab(text: 'Weekly'),
            Tab(text: 'Daily'),
            Tab(text: 'Lifetime'),
            Tab(text: 'Podium'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildWeeklyView(),
          _buildRankList('Daily Active Ranks'),
          _buildRankList('All-Time Lifetime Ranks'),
          _buildPodiumHistory(),
        ],
      ),
    );
  }

  Widget _buildWeeklyView() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Podium Widget for Top 3
        Container(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.deepNavy, AppColors.surfaceNavy],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.premiumGold.withOpacity(0.4)),
          ),
          child: Column(
            children: [
              const Text(
                'CURRENT WEEK PODIUM',
                style: TextStyle(
                  color: AppColors.premiumGold,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Rank 2: Silver
                  _PodiumColumn(
                    rank: 2,
                    name: 'Vikram S.',
                    points: '750 PTS',
                    height: 90,
                    color: AppColors.silverMedal,
                  ),
                  // Rank 1: Gold
                  _PodiumColumn(
                    rank: 1,
                    name: 'Ananya V.',
                    points: '820 PTS',
                    height: 120,
                    color: AppColors.goldMedal,
                    isFirst: true,
                  ),
                  // Rank 3: Bronze
                  _PodiumColumn(
                    rank: 3,
                    name: 'Prof. Sharma',
                    points: '690 PTS',
                    height: 70,
                    color: AppColors.bronzeMedal,
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Rankings',
          style: TextStyle(color: AppColors.pureWhite, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ..._topMembers.map((m) => _buildMemberTile(m)).toList(),
      ],
    );
  }

  Widget _buildRankList(String subtitle) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(subtitle, style: const TextStyle(color: AppColors.mutedGrey, fontSize: 13)),
        ),
        ..._topMembers.map((m) => _buildMemberTile(m)).toList(),
      ],
    );
  }

  Widget _buildPodiumHistory() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Permanent Podium Archives',
          style: TextStyle(color: AppColors.pureWhite, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 6),
        const Text(
          'Weekly top performers retain permanent podium badges on their profiles.',
          style: TextStyle(color: AppColors.mutedGrey, fontSize: 13),
        ),
        const SizedBox(height: 16),
        _buildPodiumRecord('Week 44 (Nov 03 - Nov 09)', 'Ananya Verma', 'Vikram Singh', 'Prof. Rajesh Sharma'),
        _buildPodiumRecord('Week 43 (Oct 27 - Nov 02)', 'Vikram Singh', 'Dr. Sunil Mehta', 'Ananya Verma'),
      ],
    );
  }

  Widget _buildPodiumRecord(String period, String gold, String silver, String bronze) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.deepNavy,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderGrey),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(period, style: const TextStyle(color: AppColors.premiumGold, fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.military_tech, color: AppColors.goldMedal, size: 20),
              const SizedBox(width: 8),
              Text('Gold: $gold', style: const TextStyle(color: AppColors.pureWhite, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.military_tech, color: AppColors.silverMedal, size: 20),
              const SizedBox(width: 8),
              Text('Silver: $silver', style: const TextStyle(color: AppColors.pureWhite, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.military_tech, color: AppColors.bronzeMedal, size: 20),
              const SizedBox(width: 8),
              Text('Bronze: $bronze', style: const TextStyle(color: AppColors.pureWhite, fontSize: 13)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMemberTile(Map<String, dynamic> m) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.deepNavy,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderGrey),
      ),
      child: Row(
        children: [
          Container(
            width: 30,
            alignment: Alignment.center,
            child: Text(
              '#${m['rank']}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: m['rank'] <= 3 ? AppColors.premiumGold : AppColors.mutedGrey,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 8),
          CirculusAvatar(name: m['name'], radius: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(m['name'], style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.pureWhite, fontSize: 14)),
                Text(m['designation'], style: const TextStyle(color: AppColors.mutedGrey, fontSize: 12)),
              ],
            ),
          ),
          Text(
            '${m['points']} pts',
            style: const TextStyle(color: AppColors.premiumGold, fontWeight: FontWeight.bold, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _PodiumColumn extends StatelessWidget {
  final int rank;
  final String name;
  final String points;
  final double height;
  final Color color;
  final bool isFirst;

  const _PodiumColumn({
    required this.rank,
    required this.name,
    required this.points,
    required this.height,
    required this.color,
    this.isFirst = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(Icons.military_tech, color: color, size: isFirst ? 36 : 28),
        const SizedBox(height: 4),
        Text(name, style: const TextStyle(color: AppColors.pureWhite, fontWeight: FontWeight.bold, fontSize: 12)),
        Text(points, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Container(
          width: 75,
          height: height,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            border: Border.all(color: color.withOpacity(0.6)),
          ),
          child: Center(
            child: Text(
              '$rank',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: color,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
