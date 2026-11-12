import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/api_service.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/widgets/circulus_button.dart';
import '../../../core/widgets/circulus_text_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _codeController = TextEditingController();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _designationController = TextEditingController();
  final _postingController = TextEditingController();

  bool _isVerifyingCode = false;
  bool _codeVerified = false;
  String? _invitationRole;
  bool _isRegistering = false;
  String? _errorMessage;

  Future<void> _verifyCode() async {
    final code = _codeController.text.trim();
    if (code.isEmpty) return;

    setState(() {
      _isVerifyingCode = true;
      _errorMessage = null;
    });

    try {
      final res = await ApiService().dio.post(
        ApiConstants.verifyInvitation,
        data: {'invitation_code': code},
      );
      if (res.data['valid'] == true) {
        setState(() {
          _codeVerified = true;
          _invitationRole = res.data['role'] ?? 'Officer';
          _emailController.text = res.data['email'] ?? '';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Invalid or expired invitation code.';
      });
    } finally {
      setState(() => _isVerifyingCode = false);
    }
  }

  Future<void> _handleRegister() async {
    setState(() {
      _isRegistering = true;
      _errorMessage = null;
    });

    try {
      final res = await ApiService().dio.post(
        ApiConstants.register,
        data: {
          'invitation_code': _codeController.text.trim(),
          'full_name': _nameController.text.trim(),
          'email': _emailController.text.trim(),
          'username': _usernameController.text.trim(),
          'password': 'SecureOfficerPassword123!',
          'designation': _designationController.text.trim(),
          'current_posting': _postingController.text.trim(),
        },
      );

      final token = res.data['access_token'];
      if (token != null) {
        await ApiService().saveToken(token);
        if (mounted) {
          context.go('/verification-pending');
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Registration could not be completed. Please verify all fields.';
      });
    } finally {
      if (mounted) setState(() => _isRegistering = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.midnightNavy,
      appBar: AppBar(
        title: const Text('Invitation Registration'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.error),
                  ),
                  child: Text(_errorMessage!, style: const TextStyle(color: AppColors.error)),
                ),
                const SizedBox(height: 16),
              ],
              if (!_codeVerified) ...[
                const Text(
                  'Enter Invitation Key',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.pureWhite),
                ),
                const SizedBox(height: 8),
                const Text(
                  'CIRCULUS credentials are distributed directly through authorized sponsors.',
                  style: TextStyle(color: AppColors.mutedGrey, fontSize: 13),
                ),
                const SizedBox(height: 24),
                CirculusTextField(
                  controller: _codeController,
                  label: 'Invitation Code',
                  hint: 'e.g. CIRCULUS2026',
                  prefixIcon: const Icon(Icons.vpn_key_outlined, color: AppColors.premiumGold),
                ),
                const SizedBox(height: 24),
                CirculusButton(
                  text: 'VALIDATE CODE',
                  width: double.infinity,
                  isLoading: _isVerifyingCode,
                  onPressed: _verifyCode,
                ),
              ] else ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.deepNavy,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.premiumGold.withOpacity(0.5)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle, color: AppColors.premiumGold),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Invitation Validated', style: TextStyle(color: AppColors.premiumGold, fontWeight: FontWeight.bold)),
                            Text('Eligible Role: ${_invitationRole?.toUpperCase()}', style: const TextStyle(color: AppColors.mutedGrey, fontSize: 12)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                CirculusTextField(controller: _nameController, label: 'Full Legal Name', hint: 'e.g. Vikram Singh'),
                const SizedBox(height: 14),
                CirculusTextField(controller: _usernameController, label: 'Username', hint: 'e.g. vikram_s'),
                const SizedBox(height: 14),
                CirculusTextField(controller: _emailController, label: 'Email', hint: 'officer@gov.in'),
                const SizedBox(height: 14),
                CirculusTextField(controller: _designationController, label: 'Designation / Rank', hint: 'e.g. Deputy Secretary / Director'),
                const SizedBox(height: 14),
                CirculusTextField(controller: _postingController, label: 'Current Posting', hint: 'e.g. Ministry of External Affairs'),
                const SizedBox(height: 28),
                CirculusButton(
                  text: 'COMPLETE REGISTRATION',
                  width: double.infinity,
                  isLoading: _isRegistering,
                  onPressed: _handleRegister,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
