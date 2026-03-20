import 'package:sports_config_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/colors.dart';
import '../providers/auth_provider.dart';
import 'auth_ui.dart';
import 'login_screen.dart';
import 'phone_auth_screen.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({
    super.key,
    this.popCountAfterSuccess = 1,
  });

  final int popCountAfterSuccess;

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _loading = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  int get _phonePopCountAfterOtp =>
      widget.popCountAfterSuccess == 2 ? 4 : 3;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    await ref.read(authProvider.notifier).login();
    if (mounted) {
      setState(() => _loading = false);
      final nav = Navigator.of(context);
      var n = widget.popCountAfterSuccess;
      while (n > 0 && nav.canPop()) {
        nav.pop();
        n--;
      }
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  void _openPhone() {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => PhoneAuthScreen(
          popCountAfterOtp: _phonePopCountAfterOtp,
          isSignUp: true,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: authSignupFormBackground,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AuthHeroHeader(
            title: l10n.auth_create_account_title,
            subtitle: l10n.auth_create_account_subtitle,
          ),
          Expanded(
            child: Container(
              color: authSignupFormBackground,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _firstNameController,
                              textInputAction: TextInputAction.next,
                              textCapitalization: TextCapitalization.words,
                              decoration: authModernFieldDecoration(
                                hint: l10n.auth_first_name,
                              ),
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) {
                                  return l10n.auth_please_enter_first_name;
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _lastNameController,
                              textInputAction: TextInputAction.next,
                              textCapitalization: TextCapitalization.words,
                              decoration: authModernFieldDecoration(
                                hint: l10n.auth_last_name,
                              ),
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) {
                                  return l10n.auth_please_enter_last_name;
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        decoration: authModernFieldDecoration(hint: l10n.email),
                        validator: (v) {
                          if (v == null || v.isEmpty) return l10n.please_enter_email;
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        textInputAction: TextInputAction.next,
                        decoration: authModernFieldDecoration(
                          hint: l10n.password,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: AppColors.gray60,
                              size: 22,
                            ),
                            onPressed: () =>
                                setState(() => _obscurePassword = !_obscurePassword),
                          ),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) return l10n.please_enter_password;
                          if (v.length < 4) return l10n.auth_password_min_length;
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: _obscureConfirm,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _submit(),
                        decoration: authModernFieldDecoration(
                          hint: l10n.confirm_password,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirm
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: AppColors.gray60,
                              size: 22,
                            ),
                            onPressed: () =>
                                setState(() => _obscureConfirm = !_obscureConfirm),
                          ),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return l10n.auth_please_confirm_password;
                          }
                          if (v != _passwordController.text) {
                            return l10n.auth_passwords_do_not_match;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      AuthPrimaryButton(
                        label: l10n.auth_create_account_button,
                        loading: _loading,
                        onPressed: _submit,
                      ),
                      const SizedBox(height: 24),
                      AuthOrDivider(label: l10n.auth_or),
                      const SizedBox(height: 20),
                      AuthSocialButton(
                        label: l10n.sign_up_with_google,
                        icon: authGoogleLeadingIcon(),
                        onPressed: () => _snack(l10n.auth_coming_soon),
                      ),
                      const SizedBox(height: 10),
                      AuthSocialButton(
                        label: l10n.sign_up_with_apple,
                        icon: const Icon(Icons.apple, color: Colors.white, size: 22),
                        onPressed: () => _snack(l10n.auth_coming_soon),
                      ),
                      const SizedBox(height: 10),
                      AuthSocialButton(
                        label: l10n.auth_sign_up_with_phone_otp,
                        icon: const Icon(Icons.phone_iphone, color: Colors.white, size: 20),
                        onPressed: _openPhone,
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            l10n.already_have_account,
                            style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute<void>(
                                  builder: (_) => const LoginScreen(),
                                ),
                              );
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.redSports,
                              padding: const EdgeInsets.only(left: 4),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              l10n.sign_in,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
