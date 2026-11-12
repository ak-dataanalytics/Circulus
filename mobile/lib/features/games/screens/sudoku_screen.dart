import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/api_service.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/widgets/circulus_button.dart';

class SudokuScreen extends StatefulWidget {
  const SudokuScreen({super.key});

  @override
  State<SudokuScreen> createState() => _SudokuScreenState();
}

class _SudokuScreenState extends State<SudokuScreen> {
  // 9x9 active grid
  List<List<int>> _grid = [
    [5, 3, 0, 0, 7, 0, 0, 0, 0],
    [6, 0, 0, 1, 9, 5, 0, 0, 0],
    [0, 9, 8, 0, 0, 0, 0, 6, 0],
    [8, 0, 0, 0, 6, 0, 0, 0, 3],
    [4, 0, 0, 8, 0, 3, 0, 0, 1],
    [7, 0, 0, 0, 2, 0, 0, 0, 6],
    [0, 6, 0, 0, 0, 0, 2, 8, 0],
    [0, 0, 0, 4, 1, 9, 0, 0, 5],
    [0, 0, 0, 0, 8, 0, 0, 7, 9],
  ];

  late final List<List<bool>> _isGiven;

  int? _selectedRow;
  int? _selectedCol;
  int _mistakes = 0;
  int _secondsElapsed = 0;
  Timer? _timer;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _isGiven = List.generate(
      9,
      (r) => List.generate(9, (c) => _grid[r][c] != 0),
    );
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) setState(() => _secondsElapsed++);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _onCellTap(int row, int col) {
    setState(() {
      _selectedRow = row;
      _selectedCol = col;
    });
  }

  void _inputNumber(int number) {
    if (_selectedRow == null || _selectedCol == null) return;
    if (_isGiven[_selectedRow!][_selectedCol!]) return;

    setState(() {
      _grid[_selectedRow!][_selectedCol!] = number;
    });

    _checkCompletion();
  }

  void _checkCompletion() {
    // Check if fully filled
    bool filled = true;
    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        if (_grid[r][c] == 0) filled = false;
      }
    }
    if (filled) {
      _submitSolution();
    }
  }

  Future<void> _submitSolution() async {
    _timer?.cancel();
    setState(() => _isSubmitting = true);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.deepNavy,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Puzzle Completed!', style: TextStyle(color: AppColors.premiumGold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.stars, color: AppColors.premiumGold, size: 50),
            const SizedBox(height: 12),
            Text('Time: ${_secondsElapsed ~/ 60}m ${_secondsElapsed % 60}s', style: const TextStyle(color: AppColors.pureWhite)),
            const SizedBox(height: 6),
            const Text('+150 Points Earned!', style: TextStyle(color: AppColors.premiumGold, fontWeight: FontWeight.bold)),
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
    final minutes = (_secondsElapsed ~/ 60).toString().padLeft(2, '0');
    final seconds = (_secondsElapsed % 60).toString().padLeft(2, '0');

    return Scaffold(
      backgroundColor: AppColors.midnightNavy,
      appBar: AppBar(
        title: const Text('Sudoku Masters'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: Text(
                '$minutes:$seconds',
                style: const TextStyle(
                  color: AppColors.premiumGold,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Difficulty: Medium', style: TextStyle(color: AppColors.mutedGrey, fontSize: 13)),
                  Text('Mistakes: $_mistakes/3', style: const TextStyle(color: AppColors.mutedGrey, fontSize: 13)),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // 9x9 Sudoku Grid
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: AspectRatio(
                aspectRatio: 1.0,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.deepNavy,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.premiumGold, width: 2),
                  ),
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: 81,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 9,
                    ),
                    itemBuilder: (context, index) {
                      final r = index ~/ 9;
                      final c = index % 9;
                      final val = _grid[r][c];
                      final isGiven = _isGiven[r][c];
                      final isSelected = (_selectedRow == r && _selectedCol == c);

                      // 3x3 box borders
                      final borderRight = (c == 2 || c == 5) ? 2.0 : 0.5;
                      final borderBottom = (r == 2 || r == 5) ? 2.0 : 0.5;

                      return GestureDetector(
                        onTap: () => _onCellTap(r, c),
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.premiumGold.withOpacity(0.3)
                                : Colors.transparent,
                            border: Border(
                              right: BorderSide(
                                color: (c == 2 || c == 5) ? AppColors.premiumGold : AppColors.borderGrey,
                                width: borderRight,
                              ),
                              bottom: BorderSide(
                                color: (r == 2 || r == 5) ? AppColors.premiumGold : AppColors.borderGrey,
                                width: borderBottom,
                              ),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              val == 0 ? '' : val.toString(),
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: isGiven ? FontWeight.w800 : FontWeight.w600,
                                color: isGiven
                                    ? AppColors.pureWhite
                                    : AppColors.premiumGold,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            const Spacer(),

            // Number Input Pad
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(9, (index) {
                  final num = index + 1;
                  return InkWell(
                    onTap: () => _inputNumber(num),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      width: 36,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.deepNavy,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.borderGrey),
                      ),
                      child: Center(
                        child: Text(
                          '$num',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.premiumGold,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
