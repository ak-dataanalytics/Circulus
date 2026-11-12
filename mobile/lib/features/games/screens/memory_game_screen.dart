import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/circulus_button.dart';

class MemoryGameScreen extends StatefulWidget {
  const MemoryGameScreen({super.key});

  @override
  State<MemoryGameScreen> createState() => _MemoryGameScreenState();
}

class _MemoryGameScreenState extends State<MemoryGameScreen> {
  // 4x4 Grid (8 pairs of governance & intellect icons)
  final List<IconData> _symbols = [
    Icons.gavel,
    Icons.account_balance,
    Icons.security,
    Icons.public,
    Icons.military_tech,
    Icons.psychology,
    Icons.auto_stories,
    Icons.balance,
  ];

  late List<IconData> _cards;
  late List<bool> _isFlipped;
  late List<bool> _isMatched;

  int? _firstChoiceIndex;
  bool _isBusy = false;
  int _pairsFound = 0;
  int _moves = 0;

  @override
  void initState() {
    super.initState();
    _initGame();
  }

  void _initGame() {
    _cards = [..._symbols, ..._symbols]..shuffle();
    _isFlipped = List.generate(16, (_) => false);
    _isMatched = List.generate(16, (_) => false);
    _firstChoiceIndex = null;
    _isBusy = false;
    _pairsFound = 0;
    _moves = 0;
  }

  void _onCardTap(int index) {
    if (_isBusy || _isFlipped[index] || _isMatched[index]) return;

    setState(() {
      _isFlipped[index] = true;
    });

    if (_firstChoiceIndex == null) {
      _firstChoiceIndex = index;
    } else {
      _moves++;
      final prevIndex = _firstChoiceIndex!;
      _firstChoiceIndex = null;

      if (_cards[prevIndex] == _cards[index]) {
        // Matched!
        setState(() {
          _isMatched[prevIndex] = true;
          _isMatched[index] = true;
          _pairsFound++;
        });

        if (_pairsFound == 8) {
          _showWinDialog();
        }
      } else {
        // Not matched, flip back after delay
        _isBusy = true;
        Future.delayed(const Duration(milliseconds: 700), () {
          if (mounted) {
            setState(() {
              _isFlipped[prevIndex] = false;
              _isFlipped[index] = false;
              _isBusy = false;
            });
          }
        });
      }
    }
  }

  void _showWinDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.deepNavy,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Memory Challenge Cleared!', style: TextStyle(color: AppColors.premiumGold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.psychology, color: AppColors.premiumGold, size: 50),
            const SizedBox(height: 12),
            Text('Moves: $_moves', style: const TextStyle(color: AppColors.pureWhite)),
            const SizedBox(height: 6),
            const Text('+100 Points Awarded', style: TextStyle(color: AppColors.premiumGold, fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.pop();
            },
            child: const Text('CONTINUE', style: TextStyle(color: AppColors.premiumGold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.midnightNavy,
      appBar: AppBar(
        title: const Text('Memory Matrix'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: Text(
                'Moves: $_moves',
                style: const TextStyle(color: AppColors.premiumGold, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Pairs: $_pairsFound / 8', style: const TextStyle(color: AppColors.mutedGrey)),
                  IconButton(
                    icon: const Icon(Icons.refresh, color: AppColors.premiumGold),
                    onPressed: () => setState(_initGame),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: GridView.builder(
                  itemCount: 16,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemBuilder: (context, index) {
                    final flipped = _isFlipped[index] || _isMatched[index];

                    return GestureDetector(
                      onTap: () => _onCardTap(index),
                      child: Container(
                        decoration: BoxDecoration(
                          color: flipped ? AppColors.surfaceNavy : AppColors.deepNavy,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: flipped ? AppColors.premiumGold : AppColors.borderGrey,
                            width: 1.5,
                          ),
                        ),
                        child: Center(
                          child: flipped
                              ? Icon(_cards[index], color: AppColors.premiumGold, size: 28)
                              : const Text(
                                  'C',
                                  style: TextStyle(
                                    color: AppColors.mutedGrey,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
