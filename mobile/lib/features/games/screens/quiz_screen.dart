import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/circulus_button.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final List<Map<String, dynamic>> _questions = [
    {
      'question': 'Which Article of the Constitution of India provides for the establishment of the Finance Commission?',
      'options': ['Article 280', 'Article 324', 'Article 312', 'Article 368'],
      'answer': 'Article 280',
      'explanation': 'Article 280 requires the President to constitute a Finance Commission every fifth year to recommend tax devolution.',
    },
    {
      'question': 'What is the next number in the series: 2, 6, 12, 20, 30, ?',
      'options': ['40', '42', '44', '46'],
      'answer': '42',
      'explanation': 'Differences increase by 2 each step (+4, +6, +8, +10, +12). 30 + 12 = 42.',
    },
    {
      'question': 'Which Committee recommended the introduction of the Citizens Charter in Indian public governance?',
      'options': ['Chief Ministers Conference 1997', 'Sarkaria Commission', 'Punchhi Commission', 'First ARC'],
      'answer': 'Chief Ministers Conference 1997',
      'explanation': 'The conference of Chief Ministers in 1997 adopted the Action Plan for Effective and Responsive Government.',
    },
  ];

  int _currentIndex = 0;
  String? _selectedOption;
  bool _isAnswered = false;
  int _score = 0;
  int _timeLeft = 30;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timeLeft = 30;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_timeLeft > 0) {
        if (mounted) setState(() => _timeLeft--);
      } else {
        _handleAnswer('');
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _handleAnswer(String option) {
    if (_isAnswered) return;
    _timer?.cancel();

    final correct = _questions[_currentIndex]['answer'];
    final isCorrect = (option == correct);

    setState(() {
      _selectedOption = option;
      _isAnswered = true;
      if (isCorrect) _score += 25;
    });
  }

  void _nextQuestion() {
    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedOption = null;
        _isAnswered = false;
      });
      _startTimer();
    } else {
      // Quiz Finished Dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          backgroundColor: AppColors.deepNavy,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Quiz Concluded', style: TextStyle(color: AppColors.premiumGold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.military_tech, color: AppColors.premiumGold, size: 50),
              const SizedBox(height: 12),
              Text('Your Score: $_score / 75 Points', style: const TextStyle(color: AppColors.pureWhite, fontSize: 16)),
              const SizedBox(height: 6),
              const Text('Leaderboard Updated!', style: TextStyle(color: AppColors.premiumGold, fontWeight: FontWeight.bold)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                context.pop();
              },
              child: const Text('VIEW LEADERBOARD', style: TextStyle(color: AppColors.premiumGold)),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentQ = _questions[_currentIndex];

    return Scaffold(
      backgroundColor: AppColors.midnightNavy,
      appBar: AppBar(
        title: Text('Question ${_currentIndex + 1} of ${_questions.length}'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.surfaceNavy,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.premiumGold),
                ),
                child: Text(
                  '${_timeLeft}s',
                  style: const TextStyle(
                    color: AppColors.premiumGold,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.deepNavy,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.borderGrey),
              ),
              child: Text(
                currentQ['question'],
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.pureWhite,
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: 24),
            ...List.generate(
              (currentQ['options'] as List).length,
              (index) {
                final option = currentQ['options'][index];
                Color borderColor = AppColors.borderGrey;
                Color bgColor = AppColors.deepNavy;

                if (_isAnswered) {
                  if (option == currentQ['answer']) {
                    borderColor = AppColors.success;
                    bgColor = AppColors.success.withOpacity(0.15);
                  } else if (option == _selectedOption) {
                    borderColor = AppColors.error;
                    bgColor = AppColors.error.withOpacity(0.15);
                  }
                }

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: InkWell(
                    onTap: () => _handleAnswer(option),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: bgColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: borderColor, width: 1.5),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.premiumGold),
                            ),
                            child: Center(
                              child: Text(
                                String.fromCharCode(65 + index),
                                style: const TextStyle(
                                  color: AppColors.premiumGold,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              option,
                              style: const TextStyle(color: AppColors.pureWhite, fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            if (_isAnswered) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceNavy,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Explanation: ${currentQ['explanation']}',
                  style: const TextStyle(color: AppColors.mutedGrey, fontSize: 12, height: 1.4),
                ),
              ),
              const Spacer(),
              CirculusButton(
                text: _currentIndex == _questions.length - 1 ? 'FINISH' : 'NEXT QUESTION',
                width: double.infinity,
                onPressed: _nextQuestion,
              ),
            ] else ...[
              const Spacer(),
            ],
          ],
        ),
      ),
    );
  }
}
