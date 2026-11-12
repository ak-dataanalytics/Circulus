import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/api_service.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/widgets/circulus_button.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _contentController = TextEditingController();
  bool _isPublishing = false;

  Future<void> _publishPost() async {
    final text = _contentController.text.trim();
    if (text.isEmpty) return;

    setState(() => _isPublishing = true);
    try {
      await ApiService().dio.post(
        ApiConstants.createPost,
        data: {'content': text},
      );
      if (mounted) context.pop();
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to publish post. Please retry.')),
      );
    } finally {
      if (mounted) setState(() => _isPublishing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.midnightNavy,
      appBar: AppBar(
        title: const Text('New Post'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0, top: 10, bottom: 10),
            child: CirculusButton(
              text: 'SHARE',
              isLoading: _isPublishing,
              onPressed: _publishPost,
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: TextField(
          controller: _contentController,
          maxLines: 15,
          style: const TextStyle(color: AppColors.pureWhite, fontSize: 16),
          decoration: const InputDecoration(
            hintText: 'Share professional updates, research, or observations with verified peers...',
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            filled: false,
          ),
        ),
      ),
    );
  }
}
