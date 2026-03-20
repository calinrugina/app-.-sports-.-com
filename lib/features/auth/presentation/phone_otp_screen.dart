import 'package:sports_config_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/colors.dart';
import '../providers/auth_provider.dart';
import 'auth_ui.dart';

/// 6-digit OTP + verify. Pops [popCountAfterSuccess] routes on success (demo).
class PhoneOtpScreen extends ConsumerStatefulWidget {
  const PhoneOtpScreen({
    super.key,
    required this.displayPhone,
    required this.popCountAfterSuccess,
  });

  final String displayPhone;
  final int popCountAfterSuccess;

  @override
  ConsumerState<PhoneOtpScreen> createState() => _PhoneOtpScreenState();
}

class _PhoneOtpScreenState extends ConsumerState<PhoneOtpScreen> {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  bool _loading = false;

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String get _code => _controllers.map((c) => c.text).join();

  void _onDigit(int index, String value) {
    if (value.length > 1) {
      // paste
      final digits = value.replaceAll(RegExp(r'\D'), '');
      for (var i = 0; i < 6; i++) {
        _controllers[i].text = i < digits.length ? digits[i] : '';
      }
      if (digits.length >= 6) {
        _focusNodes[5].requestFocus();
      } else if (digits.isNotEmpty) {
        _focusNodes[digits.length.clamp(0, 5)].requestFocus();
      }
      setState(() {});
      return;
    }
    if (value.isNotEmpty && index < 5) {
      _focusNodes[index + 1].requestFocus();
    }
    setState(() {});
  }

  Future<void> _verify() async {
    if (_code.length < 6) return;
    setState(() => _loading = true);
    await ref.read(authProvider.notifier).login();
    if (!mounted) return;
    setState(() => _loading = false);
    final nav = Navigator.of(context);
    var n = widget.popCountAfterSuccess;
    while (n > 0 && nav.canPop()) {
      nav.pop();
      n--;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AuthHeroHeader(
            title: l10n.auth_phone_verification_title,
            subtitle: l10n.auth_phone_verification_subtitle,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    l10n.auth_enter_the_code,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A2744),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.auth_code_sent_to,
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.displayPhone,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 28),
                  Row(
                    children: List.generate(6, (i) {
                      return Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(left: i == 0 ? 0 : 3, right: i == 5 ? 0 : 3),
                          child: SizedBox(
                            height: 52,
                            child: TextField(
                              controller: _controllers[i],
                              focusNode: _focusNodes[i],
                              textAlign: TextAlign.center,
                              keyboardType: TextInputType.number,
                              maxLength: 1,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                              decoration: InputDecoration(
                                counterText: '',
                                filled: true,
                                fillColor: const Color(0xFF3D3D3D),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide.none,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(color: AppColors.redSports, width: 1.5),
                                ),
                              ),
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                              onChanged: (v) {
                                if (v.isEmpty) {
                                  if (i > 0) _focusNodes[i - 1].requestFocus();
                                  setState(() {});
                                  return;
                                }
                                if (v.length > 1) {
                                  _onDigit(i, v);
                                  return;
                                }
                                if (i < 5 && v.isNotEmpty) {
                                  _focusNodes[i + 1].requestFocus();
                                }
                                setState(() {});
                              },
                              onTap: () {
                                _controllers[i].selection = TextSelection(
                                  baseOffset: 0,
                                  extentOffset: _controllers[i].text.length,
                                );
                              },
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 24),
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        l10n.auth_didnt_receive_code,
                        style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                      ),
                      TextButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(l10n.auth_code_resent_demo)),
                          );
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.redSports,
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          l10n.auth_resend,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  AuthPrimaryButton(
                    label: l10n.auth_verify,
                    loading: _loading,
                    onPressed: _code.length == 6 ? () => _verify() : null,
                  ),
                  SizedBox(height: MediaQuery.paddingOf(context).bottom + 8),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
