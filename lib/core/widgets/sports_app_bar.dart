import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../features/config/providers/config_provider.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/more/presentation/notifications_settings_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../app_config.dart';
import '../app_functions.dart';
import '../network/media_headers.dart';
import '../theme/colors.dart';

class SportsAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const SportsAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final configAsync = ref.watch(configProvider);

    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.black,
      titleSpacing: 16,
      title: Row(
        children: [
          configAsync.when(
            data: (cfg) {
              final logoUrl = cfg?['design']?['logo']?.toString();
              if (logoUrl != null && logoUrl.isNotEmpty) {
                return SvgPicture.network(
                  logoUrl,
                  height: 25,
                  headers: mediaHeaders,

                );
              }
              return const Text(
                AppConfig.appName,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              );
            },
            loading: () => const SizedBox(
              height: 24,
              width: 100,
              child: Align(
                alignment: Alignment.centerLeft,
                child: CircularProgressIndicator(strokeWidth: 1),
              ),
            ),
            error: (e, st) => const Text(
              AppConfig.appName,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (ctx) => const _SearchSheet(),
              );
            },
          ),

          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.white),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const NotificationsSettingsScreen(),
                ),
              );
            },
          ),
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

class _SearchSheet extends StatelessWidget {
  const _SearchSheet();

  @override
  Widget build(BuildContext context) {
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
          Text(
            'Search',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 5),
          const TextField(
            decoration: InputDecoration(
              hintText: 'Search articles, videos, teams...',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.search),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Close', style: Theme.of(context).textTheme.labelSmall!.copyWith(color: Colors.white),),
          ),
          const SizedBox(height: 16),
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
        children:  [
          Text(
            'Notifications',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          SizedBox(height: 10),
          Text('No notifications yet. (TODO: implement real notifications)', style: Theme.of(context).textTheme.bodyMedium,),
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
            const Text('User not logged in.'),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const LoginScreen(),
                  ),
                );
              },
              child: const Text('Login / Sign up'),
            ),
          ] else ...[
            const Text('You are logged in.'),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () async {
                await ref.read(authProvider.notifier).logout();
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                }
              },
              icon: const Icon(Icons.logout),
              label: const Text('Logout'),
            ),
          ],
          const SizedBox(height: 8),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Close'),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

