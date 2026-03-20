import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';

// ——— Colors matching design ———
const Color _authHeaderBlack = Color(0xFF0D0D0D);
const Color _authFieldFill = Color(0xFFECECEC);
const Color _authFormGrayBg = Color(0xFFF2F2F2);

/// SPORTS (red italic) + .COM (white)
class AuthSportsComLogo extends StatelessWidget {
  const AuthSportsComLogo({super.key, this.size = 22});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          'SPORTS',
          style: TextStyle(
            color: AppColors.redSports,
            fontSize: size,
            fontWeight: FontWeight.w800,
            fontStyle: FontStyle.italic,
            letterSpacing: -0.5,
            height: 1,
          ),
        ),
        Text(
          '.COM',
          style: TextStyle(
            color: Colors.white,
            fontSize: size * 0.72,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
            height: 1,
          ),
        ),
      ],
    );
  }
}

/// Red decorative shapes on the right of the header (abstract “hero”).
class _AuthHeaderDecoration extends StatelessWidget {
  const _AuthHeaderDecoration();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Align(
        alignment: Alignment.centerRight,
        child: CustomPaint(
          size: const Size(120, 160),
          painter: _RedBlocksPainter(),
        ),
      ),
    );
  }
}

class _RedBlocksPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = AppColors.redSports.withValues(alpha: 0.9);
    canvas.save();
    canvas.translate(size.width * 0.35, size.height * 0.1);
    canvas.rotate(0.15);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, 38, 52),
        const Radius.circular(6),
      ),
      paint,
    );
    canvas.restore();
    canvas.save();
    canvas.translate(size.width * 0.05, size.height * 0.35);
    canvas.rotate(-0.08);
    paint.color = AppColors.redSports.withValues(alpha: 0.75);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, 44, 36),
        const Radius.circular(5),
      ),
      paint,
    );
    canvas.restore();
    canvas.save();
    canvas.translate(size.width * 0.45, size.height * 0.55);
    canvas.drawCircle(const Offset(18, 18), 16, paint..color = AppColors.redSports);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Dark header: back, logo, title, subtitle, decoration.
class AuthHeroHeader extends StatelessWidget {
  const AuthHeroHeader({
    super.key,
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: _authHeaderBlack,
      child: Stack(
        children: [
          const Positioned.fill(child: _AuthHeaderDecoration()),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 16, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                      onPressed: () => Navigator.of(context).maybePop(),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Center(child: AuthSportsComLogo(size: 24)),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.only(right: 100),
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontFamily: 'Bebas Neue',
                        fontSize: 34,
                        height: 1.05,
                        color: Colors.white,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.only(right: 24),
                    child: Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 14,
                        height: 1.35,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
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

/// Flat filled field: light grey, rounded, no visible border (sign-in design).
InputDecoration authModernFieldDecoration({
  required String hint,
  Widget? suffixIcon,
}) {
  return InputDecoration(
    hintText: hint,
    hintStyle: TextStyle(color: Colors.grey.shade600, fontSize: 15),
    filled: true,
    fillColor: _authFieldFill,
    isDense: true,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: AppColors.redSports, width: 1.2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: Colors.red.shade400, width: 1),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: Colors.red.shade700, width: 1.2),
    ),
    suffixIcon: suffixIcon,
  );
}

class AuthOrDivider extends StatelessWidget {
  const AuthOrDivider({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Divider(color: Colors.grey.shade300, thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            label,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
          ),
        ),
        Expanded(child: Divider(color: Colors.grey.shade300, thickness: 1)),
      ],
    );
  }
}

/// Primary red full-width button.
class AuthPrimaryButton extends StatelessWidget {
  const AuthPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
  });

  final String label;
  /// Null disables the button.
  final VoidCallback? onPressed;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: loading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.redSports,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.redSports.withValues(alpha: 0.6),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: loading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  letterSpacing: 1,
                ),
              ),
      ),
    );
  }
}

/// Black social / alt login button.
class AuthSocialButton extends StatelessWidget {
  const AuthSocialButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final Widget icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget authGoogleLeadingIcon() {
  return Container(
    width: 22,
    height: 22,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(4),
    ),
    alignment: Alignment.center,
    child: const Text(
      'G',
      style: TextStyle(
        color: Color(0xFF4285F4),
        fontWeight: FontWeight.bold,
        fontSize: 14,
        height: 1,
      ),
    ),
  );
}

/// Optional: light gray panel behind signup form only.
Color get authSignupFormBackground => _authFormGrayBg;
