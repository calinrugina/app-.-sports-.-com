import 'package:sports_config_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'auth_ui.dart';
import 'phone_otp_screen.dart';

class CountryDialOption {
  const CountryDialOption({required this.flag, required this.name, required this.dial});
  final String flag;
  final String name;
  final String dial;
}

const List<CountryDialOption> kDefaultCountryDials = [
  CountryDialOption(flag: '🇬🇧', name: 'United Kingdom', dial: '+44'),
  CountryDialOption(flag: '🇺🇸', name: 'United States', dial: '+1'),
  CountryDialOption(flag: '🇷🇴', name: 'Romania', dial: '+40'),
  CountryDialOption(flag: '🇪🇸', name: 'Spain', dial: '+34'),
  CountryDialOption(flag: '🇮🇳', name: 'India', dial: '+91'),
];

/// Enter phone number → navigate to OTP. [popCountAfterOtp] = total pops after verify (incl. OTP).
class PhoneAuthScreen extends StatefulWidget {
  const PhoneAuthScreen({
    super.key,
    required this.popCountAfterOtp,
    this.isSignUp = false,
  });

  final int popCountAfterOtp;
  final bool isSignUp;

  @override
  State<PhoneAuthScreen> createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends State<PhoneAuthScreen> {
  final _phoneController = TextEditingController();
  CountryDialOption _country = kDefaultCountryDials.first;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _continue() {
    final digits = _phoneController.text.replaceAll(RegExp(r'\s'), '');
    if (digits.isEmpty) return;
    final display = '${_country.dial} $digits';
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => PhoneOtpScreen(
          displayPhone: display,
          popCountAfterSuccess: widget.popCountAfterOtp,
        ),
      ),
    );
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
            title: widget.isSignUp ? l10n.auth_create_account_title : l10n.auth_sign_in_title,
            subtitle: widget.isSignUp
                ? l10n.auth_create_account_subtitle
                : l10n.auth_sign_in_subtitle,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AuthOrDivider(label: l10n.auth_or),
                  const SizedBox(height: 20),
                  Text(
                    widget.isSignUp ? l10n.auth_sign_up_with_phone_otp : l10n.auth_sign_in_with_phone_otp,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                      color: Color(0xFF1A2744),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _PhoneRow(
                    country: _country,
                    controller: _phoneController,
                    onCountryChanged: (c) => setState(() => _country = c),
                  ),
                  const SizedBox(height: 28),
                  AuthPrimaryButton(
                    label: l10n.auth_send_code,
                    loading: false,
                    onPressed: _continue,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PhoneRow extends StatelessWidget {
  const _PhoneRow({
    required this.country,
    required this.controller,
    required this.onCountryChanged,
  });

  final CountryDialOption country;
  final TextEditingController controller;
  final ValueChanged<CountryDialOption> onCountryChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        children: [
          Material(
            color: const Color(0xFFE8E8E8),
            child: InkWell(
              onTap: () async {
                final picked = await showModalBottomSheet<CountryDialOption>(
                  context: context,
                  builder: (ctx) => SafeArea(
                    child: ListView(
                      shrinkWrap: true,
                      children: kDefaultCountryDials
                          .map(
                            (c) => ListTile(
                              leading: Text(c.flag, style: const TextStyle(fontSize: 22)),
                              title: Text(c.name),
                              trailing: Text(c.dial, style: const TextStyle(fontWeight: FontWeight.w600)),
                              onTap: () => Navigator.pop(ctx, c),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                );
                if (picked != null) onCountryChanged(picked);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(country.flag, style: const TextStyle(fontSize: 20)),
                    const SizedBox(width: 6),
                    Icon(Icons.arrow_drop_down, color: Colors.grey.shade700, size: 22),
                  ],
                ),
              ),
            ),
          ),
          Container(width: 1, height: 48, color: Colors.grey.shade300),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.phone,
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d\s]'))],
              decoration: InputDecoration(
                hintText: '${country.dial}  0734000000',
                hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 15),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                suffixIcon: ValueListenableBuilder<TextEditingValue>(
                  valueListenable: controller,
                  builder: (_, v, __) {
                    if (v.text.isEmpty) return const SizedBox.shrink();
                    return IconButton(
                      icon: Icon(Icons.close, size: 20, color: Colors.grey.shade600),
                      onPressed: () => controller.clear(),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
