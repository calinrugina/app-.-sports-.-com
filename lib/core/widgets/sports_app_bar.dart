import 'package:sports_config_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../features/asset/presentation/listing_assets.dart';
import '../../features/config/providers/config_provider.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/more/presentation/notifications_settings_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../app_config.dart';
import '../app_functions.dart';
import '../language/language_provider.dart';
import '../network/media_headers.dart';
import '../theme/colors.dart';

class SportsAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const SportsAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final configAsync = ref.watch(configProvider);
    final selectedLanguage = ref.watch(languageProvider);

    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.black,
      titleSpacing: 16,
      title: Row(
        children: [
          // configAsync.when(
          //   data: (cfg) {
          //     final logoUrl = cfg?['design']?['logo']?.toString();
          //     if (logoUrl != null && logoUrl.isNotEmpty) {
          //       return SvgPicture.network(
          //         logoUrl,
          //         height: 20,
          //         headers: mediaHeaders,
          //
          //       );
          //     }
          //     return const Text(
          //       AppConfig.appName,
          //       style: TextStyle(
          //         fontWeight: FontWeight.bold,
          //         color: Colors.white,
          //       ),
          //     );
          //   },
          //   loading: () => const SizedBox(
          //     height: 24,
          //     width: 100,
          //     child: Align(
          //       alignment: Alignment.centerLeft,
          //       child: CircularProgressIndicator(strokeWidth: 1),
          //     ),
          //   ),
          //   error: (e, st) => const Text(
          //     AppConfig.appName,
          //     style: TextStyle(
          //       fontWeight: FontWeight.bold,
          //       color: Colors.white,
          //     ),
          //   ),
          // ),
          InkWell(
            onTap: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            child: SvgPicture.asset(
              'assets/images/logo-top.svg',
              height: 24,
            ),
          ),

          const Spacer(),
          IconButton(
            icon: SvgPicture.asset(
              'assets/images/search.svg',
              height: 24,
              colorFilter: const ColorFilter.mode(
                Colors.white,
                BlendMode.srcIn,
              ),
            ),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (ctx) => _SearchSheet(
                  sport: const {},
                  languageCode: selectedLanguage,
                ),
              );
            },
          ),
          // V1.1.0 - no notifications
          // IconButton(
          //   icon: SvgPicture.asset(
          //     'assets/images/bell.svg',
          //     height: 24,
          //     colorFilter: const ColorFilter.mode(
          //       Colors.white,
          //       BlendMode.srcIn,
          //     ),
          //   ),
          //   onPressed: () {
          //     Navigator.of(context).push(
          //       MaterialPageRoute(
          //         builder: (_) => const NotificationsSettingsScreen(),
          //       ),
          //     );
          //   },
          // ),


          // IconButton(
          //   onPressed: () {
          //     Navigator.of(context).push(
          //       MaterialPageRoute(
          //         builder: (_) => const ProfileScreen(),
          //       ),
          //     );
          //   },
          //   icon: const CircleAvatar(
          //     radius: 14,
          //     backgroundColor: Colors.white,
          //     child: CircleAvatar(
          //       radius: 12,
          //       backgroundColor: AppColors.redSports,
          //       child: Icon(
          //         Icons.person,
          //         size: 16,
          //         color: Colors.white,
          //       ),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}

enum SearchTarget { videos, articles, both }

class _SearchSheet extends StatefulWidget {
  final Map<String, dynamic> sport;
  final String languageCode;

  const _SearchSheet({
    required this.sport,
    required this.languageCode,
  });

  @override
  State<_SearchSheet> createState() => _SearchSheetState();
}

class _SearchSheetState extends State<_SearchSheet> {
  final _ctrl = TextEditingController();
  SearchTarget _target = SearchTarget.videos;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _doSearch() {
    final q = _ctrl.text.trim();
    if (q.isEmpty) return;

    Navigator.of(context).pop(); // închide sheet-ul

    final isBoth = _target == SearchTarget.both;
    final contentType = _target == SearchTarget.videos
        ? 'video'
        : _target == SearchTarget.articles
            ? 'article'
            : 'video'; // block default when both
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AssetsListingPage(
          client: mediaPlatformClient,
          block: createSearchBlock(q, contentType: contentType),
          title: q,
          searchQuery: q,
          searchBothTypes: isBoth,
          lang: widget.languageCode,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: AppConfig.bigSpace,
        right: AppConfig.bigSpace,
        top: AppConfig.bigSpace,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Search', style: Theme.of(context).textTheme.headlineLarge),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: RadioListTile<SearchTarget>(
                  contentPadding: EdgeInsets.zero,
                  title: Text(AppLocalizations.of(context)!.videos,
                      style: Theme.of(context).textTheme.bodyMedium),
                  value: SearchTarget.videos,
                  groupValue: _target,
                  onChanged: (v) => setState(() => _target = v!),
                ),
              ),
              Expanded(
                child: RadioListTile<SearchTarget>(
                  contentPadding: EdgeInsets.zero,
                  title: Text(AppLocalizations.of(context)!.news,
                      style: Theme.of(context).textTheme.bodyMedium),
                  value: SearchTarget.articles,
                  groupValue: _target,
                  onChanged: (v) => setState(() => _target = v!),
                ),
              ),
              Expanded(
                child: RadioListTile<SearchTarget>(
                  contentPadding: EdgeInsets.zero,
                  title: Text('Both', style: Theme.of(context).textTheme.bodyMedium),
                  value: SearchTarget.both,
                  groupValue: _target,
                  onChanged: (v) => setState(() => _target = v!),
                ),
              ),
            ],
          ),
          TextField(
            controller: _ctrl,
            textInputAction: TextInputAction.search,
            onSubmitted: (_) => _doSearch(),
            decoration: InputDecoration(
              hintText: l10n.search_articles_videos_teams,
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.search),
            ),
          ),
          const SizedBox(height: AppConfig.smallSpace),
          ElevatedButton(
            onPressed: _doSearch,
            child: Text(l10n.search_articles_videos_teams,
                style: Theme.of(context)
                    .textTheme
                    .labelSmall!
                    .copyWith(color: Colors.white)),
          ),
          const SizedBox(height: AppConfig.smallSpace),
          OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.close,
                style: Theme.of(context)
                    .textTheme
                    .labelSmall!
                    .copyWith(color: Colors.white)),
          ),
          const SizedBox(height: AppConfig.bigSpace),
        ],
      ),
    );
  }
}

class _NotificationsSheet extends StatelessWidget {
  const _NotificationsSheet();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Notifications',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          SizedBox(height: 10),
          Text(
            'No notifications yet. (TODO: implement real notifications)',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          SizedBox(height: 10),
        ],
      ),
    );
  }
}

class _AccountSheet extends ConsumerWidget {
  const _AccountSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoggedIn = ref.watch(authProvider);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Account',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          if (!isLoggedIn) ...[
            Text(AppLocalizations.of(context)!.user_not_logged_in),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const LoginScreen(),
                  ),
                );
              },
              child: Text(AppLocalizations.of(context)!.login_sign_up),
            ),
          ] else ...[
            Text(AppLocalizations.of(context)!.you_are_logged_in),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () async {
                await ref.read(authProvider.notifier).logout();
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                }
              },
              icon: const Icon(Icons.logout),
              label: Text(AppLocalizations.of(context)!.logout),
            ),
          ],
          const SizedBox(height: 8),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(AppLocalizations.of(context)!.close),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
