import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/circulus_card.dart';

class BrainArenaScreen extends StatelessWidget {
  const BrainArenaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.midnightNavy,
      appBar: AppBar(
        title: const Text('Brain Arena'),
        actions: [
          IconButton(
            icon: const Icon(Icons.emoji_events_outlined, color: AppColors.premiumGold),
            onPressed: () => context.push('/leaderboard'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Daily Challenge Hero Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1F314F), Color(0xFF121E30)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.premiumGold, width: 1.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.premiumGold,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'DAILY CHALLENGE',
                        style: TextStyle(
                          color: AppColors.midnightNavy,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ),
                    const Row(
                      children: [
                        Icon(Icons.stars, color: AppColors.premiumGold, size: 16),
                        SizedBox(width: 4),
                        Text(
                          '+250 PTS',
                          style: TextStyle(
                            color: AppColors.premiumGold,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                const Text(
                  'The Executive Tri-Challenge',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.pureWhite,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Solve today\'s curated Sudoku + 5 Constitutional Law analytical questions.',
                  style: TextStyle(fontSize: 13, color: AppColors.mutedGrey),
                ),
                const SizedBox(height: 18),
                ElevatedButton(
                  onPressed: () => context.push('/games/sudoku'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.premiumGold,
                    foregroundColor: AppColors.midnightNavy,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('BEGIN DAILY CHALLENGE', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Intellectual Arenas',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.pureWhite),
          ),
          const SizedBox(height: 14),

          // Game 1: Sudoku
          _GameCard(
            title: 'Sudoku Masters',
            subtitle: 'Easy, Medium & Hard mathematical logic grids',
            points: 'Up to 150 Pts',
            icon: Icons.grid_4x4,
            onTap: () => context.push('/games/sudoku'),
          ),

          // Game 2: General Knowledge & Governance
          _GameCard(
            title: 'Governance & GK Quiz',
            subtitle: 'Constitutional law, economics, and administrative theory',
            points: 'Up to 120 Pts',
            icon: Icons.quiz_outlined,
            onTap: () => context.push('/games/quiz'),
          ),

          // Game 3: Memory Recall
          _GameCard(
            title: 'Executive Memory Matrix',
            subtitle: 'Grid sequence memory and rapid visual recall',
            points: 'Up to 100 Pts',
            icon: Icons.memory,
            onTap: () => context.push('/games/memory'),
          ),

          // Game 4: Logical Reasoning
          _GameCard(
            title: 'Logical Reasoning Series',
            subtitle: 'Number sequences, deductive analogies, pattern puzzles',
            points: 'Up to 100 Pts',
            icon: Icons.insights_outlined,
            onTap: () => context.push('/games/quiz'),
          ),
        ],
      ),
    );
  }
}

class _GameCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String points;
  final IconData icon;
  final VoidCallback onTap;

  const _GameCard({
    required this.title,
    required this.subtitle,
    required this.points,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: CirculusCard(
        onTap: onTap,
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceNavy,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderGrey),
              ),
              child: Icon(icon, color: AppColors.premiumGold, size: 28),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.pureWhite,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 12, color: AppColors.mutedGrey),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  points,
                  style: const TextStyle(
                    color: AppColors.premiumGold,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.mutedGrey),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
