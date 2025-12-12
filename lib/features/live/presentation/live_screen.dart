import 'package:sports_config_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:sports_config_app/core/app_config.dart';
import '../../../core/app_functions.dart';
import '../../../core/language/language_provider.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/widgets/section_header.dart';
import '../../config/providers/config_provider.dart';
import '../../../core/network/media_headers.dart';
import '../../media/presentation/video_listing_two_columns.dart';
import '../../media/presentation/video_player_dialog.dart';
import '../../media/presentation/videos_listing.dart';

class LiveScreen extends ConsumerWidget {
  const LiveScreen({super.key});

  // Funcție utilitară pentru a verifica dacă stream-ul poate fi redat
  bool _canPlay(Map<String, dynamic> item) {
    try {
      final countdownActive = item["countdown_active"] == 1;
      final countdownEndStr = item["countdown_end"]?.toString();

      if (!countdownActive || countdownEndStr == null) {
        // Dacă nu e activ sau nu are dată de sfârșit, ar trebui să poată fi redat (Live Now)
        return true;
      }

      // Parsarea datei de sfârșit (asumat ca fiind format ISO 8601, ex: "2025-11-02T13:43:00.000000Z")
      final countdownEnd = DateTime.parse(countdownEndStr).toLocal();
      final now = DateTime.now();

      // Condiția de redare: countdown_active=1 ȘI countdown_end < now()
      return countdownActive && countdownEnd.isBefore(now);
    } catch (e) {
      // Logica de parsare a eșuat sau câmpurile lipsesc, presupunem că poate fi redat pentru siguranță
      return true;
    }
  }

  // Funcție pentru a afișa dialogul video
  void _showVideoPlayer(BuildContext context, Map<String, dynamic> item) {
    if (item['stream_url'] == null) {
      ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(content: Text(AppLocalizations.of(context)!.no_url)),
      );
      return;
    }

    showDialog(
      context: context,
      useSafeArea: true,
      builder: (context) => VideoPlayerDialog(
        videoUrl: item['stream_url'],
        title: item['title'] ?? 'Stream Live',
      ),
    );
  }



  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final configAsync = ref.watch(configProvider);

    final selectedLanguage = ref.watch(languageProvider);
    final String languageCode =
        selectedLanguage.isNotEmpty ? selectedLanguage : 'en';

    final themeMode = ref.watch(themeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Map<String, dynamic> firstSport = {};
    return configAsync.when(
      data: (config) {
        if (config == null) {
          return  Center(child: Text(AppLocalizations.of(context)!.no_config_loaded));
        }
        final sports = (config['sports'] as List?) ?? [];
        final List<Map<String, dynamic>> allStreams = [];

        for (final s in sports) {
          final sport = s as Map<String, dynamic>;
          final streams = sport['livestreams'] as List?;
          if (streams != null) {
            firstSport = sport;
            for (final st in streams) {
              allStreams.add({
                'sportName': sport['name'],
                ...((st as Map).cast<String, dynamic>()),
              });
            }
          }
        }

        if (allStreams.isEmpty) {
          return  Center(child: Text(AppLocalizations.of(context)!.no_live_streams_available));
        }
        return ListView(
          children: [
            ListView.builder(
              shrinkWrap:
                  true, // ESENȚIAL: Ocupă doar spațiul necesar elementelor.
              physics: const NeverScrollableScrollPhysics(), // ESENȚIAL: Dezactivează scroll-ul intern.
              itemCount: allStreams.length,
              itemBuilder: (context, index) {
                final item = allStreams[index];

                final canPlay = _canPlay(item);
                final title = item['title']?.toString() ?? 'Live Stream';
                final sportName = item['sportName']?.toString() ?? '';

                final description = item['description']?.toString() ??
                    item['sportName']?.toString() ??
                    '';
                final thumbnailUrl = item['thumbnail_url']?.toString();
                final countdownEndStr = item["countdown_end"]?.toString();

                String countdownText = '';

                if (item["countdown_active"] == 1 && countdownEndStr != null) {
                  try {
                    final countdownEnd =
                        DateTime.parse(countdownEndStr).toLocal();
                    final formatter = DateFormat('EEE, MMM d, HH:mm');
                    countdownText = 'Start: ${formatter.format(countdownEnd)}';
                  } catch (_) {
                    countdownText = 'Data start invalidă';
                  }
                }
                final textTheme = Theme.of(context).textTheme;

                return Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: AppConfig.appPadding,
                        horizontal: AppConfig.appPadding),
                    child: Column(
                      children: [
                        SectionHeader(
                          title: sportName,
                          titleRed: AppLocalizations.of(context)!.live_now,
                          moreLabel: null,
                          onMore: () {},
                        ),
                        InkWell(
                            onTap: () {
                              if (canPlay) {
                                _showVideoPlayer(context, item);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          'LiveStream will start ${countdownText.replaceAll("Start: ", "")}', style:  Theme.of(context)
                                          .textTheme
                                          .labelSmall!.copyWith(color: AppColors.redSports),)),
                                );
                              }
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Column(
                              children: [
                                Card(
                                  clipBehavior: Clip.antiAlias,
                                  surfaceTintColor:
                                      Colors.transparent, // Material 3 fix
                                  shadowColor: Colors.transparent,
                                  shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.zero),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // --- Zona Imagine și Buton Play ---
                                      AspectRatio(
                                        aspectRatio: 16 / 9,
                                        child: Stack(
                                          fit: StackFit.expand,
                                          children: [
                                            // 1. Imaginea Thumbnail
                                            if (thumbnailUrl != null)
                                              Image.network(
                                                thumbnailUrl,
                                                fit: BoxFit.cover,
                                                headers: mediaHeaders,
                                                errorBuilder: (context, error,
                                                        stackTrace) =>
                                                    Image.asset('assets/images/smaail.png', fit: BoxFit.cover,),
                                              )
                                            else
                                              Image.asset('assets/images/smaail.png', fit: BoxFit.cover,),

                                            // 3. Iconița Play/Ceas (Centrală)
                                            Align(
                                              alignment: Alignment.center,
                                              child: SvgIconLoader(
                                                iconUrl: '',
                                                localAssetPath: 'assets/images/play_icon.svg',
                                                size: 48,
                                                headers: mediaHeaders,
                                                color: Colors.white,
                                                backgroundColor: Colors.black.withOpacity(0.2),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      // --- Zona Text Sub Imagine ---
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: AppConfig.smallSpace),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const SizedBox(height: AppConfig.bigSpace),
                                            Text(
                                              title,
                                              overflow: TextOverflow.ellipsis,
                                              style: textTheme.titleLarge,
                                            ),
                                            const SizedBox(height: AppConfig.smallSpace),
                                            Text(
                                              description,
                                              style: textTheme.bodyMedium,
                                            ),
                                            if (countdownText.isNotEmpty &&
                                                !canPlay)
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 4.0),
                                                child: Text(
                                                  countdownText,
                                                  style: Theme.of(context)
                                                    .textTheme
                                                    .titleLarge!.copyWith(color: AppColors.redSports),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            )),
                      ],
                    ));
              },
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: AppConfig.appPadding),
              child: SectionHeader(
                title: firstSport['name'],
                moreLabel: AppLocalizations.of(context)!.see_more,
                onMore: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => VideosListing(
                        title: firstSport['name'],
                        mpids: firstSport['mpid'],
                        languageCode: languageCode,
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppConfig.appPadding),
                child: VideosGridTwoColumns(
                  title: firstSport['name'],
                  mpids: firstSport['mpid'],
                  languageCode: languageCode,
                  shrinkWrap: true,
                  showMore: true,
                  // physics: const NeverScrollableScrollPhysics(),
                  // physics: const BouncingScrollPhysics(),
                ))
          ],
        );
        return ListView.builder(
          itemCount: allStreams.length,
          itemBuilder: (context, index) {
            final item = allStreams[index];
            SportsAppLogger.log(item);

            final canPlay = _canPlay(item);
            final title = item['title']?.toString() ?? 'Live Stream';
            final description = item['description']?.toString() ??
                item['sportName']?.toString() ??
                '';
            final thumbnailUrl = item['thumbnail_url']?.toString();
            final countdownEndStr = item["countdown_end"]?.toString();

            String countdownText = '';

            if (item["countdown_active"] == 1 && countdownEndStr != null) {
              try {
                final countdownEnd = DateTime.parse(countdownEndStr).toLocal();
                final formatter = DateFormat('EEE, MMM d, HH:mm');
                countdownText = 'Start: ${formatter.format(countdownEnd)}';
              } catch (_) {
                countdownText = 'Data start invalidă';
              }
            }
            final textTheme = Theme.of(context).textTheme;

            return Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: AppConfig.appPadding,
                    horizontal: AppConfig.appPadding),
                child: Column(
                  children: [
                    InkWell(
                        onTap: () {
                          if (canPlay) {
                            _showVideoPlayer(context, item);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(AppLocalizations.of(context)!.stream_start_at)),
                            );
                          }
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Column(
                          children: [
                            Card(
                              clipBehavior: Clip.antiAlias,
                              surfaceTintColor:
                                  Colors.transparent, // Material 3 fix
                              shadowColor: Colors.transparent,
                              shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.zero),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // --- Zona Imagine și Buton Play ---
                                  AspectRatio(
                                    aspectRatio: 16 / 9,
                                    child: Stack(
                                      fit: StackFit.expand,
                                      children: [
                                        // 1. Imaginea Thumbnail
                                        if (thumbnailUrl != null)
                                          Image.network(
                                            thumbnailUrl,
                                            fit: BoxFit.cover,
                                            headers: mediaHeaders,
                                            errorBuilder: (context, error,
                                                    stackTrace) =>
                                                Container(
                                                    color: AppColors.gray60),
                                          )
                                        else
                                          Container(
                                            color: Colors.black,
                                            child: const Center(
                                                child: Icon(Icons.live_tv,
                                                    size: 50,
                                                    color: Colors.white)),
                                          ),

                                        // 2. Overlay (Gradient și Buton)
                                        Container(
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              begin: Alignment.topCenter,
                                              end: Alignment.bottomCenter,
                                              colors: [
                                                Colors.black.withOpacity(0.1),
                                                Colors.black.withOpacity(0.5)
                                              ],
                                            ),
                                          ),
                                        ),

                                        // 3. Iconița Play/Ceas (Centrală)
                                        Center(
                                          child: AnimatedContainer(
                                            duration: const Duration(
                                                milliseconds: 200),
                                            // padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: canPlay
                                                  ? AppColors.redSports
                                                      .withOpacity(0.8)
                                                  : Colors.black
                                                      .withOpacity(0.6),
                                              border: Border.all(
                                                color: Colors.white,
                                                width: 3,
                                              ),
                                            ),
                                            child: Icon(
                                              canPlay
                                                  ? Icons.play_arrow
                                                  : Icons.schedule,
                                              size: 48,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // --- Zona Text Sub Imagine ---
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: AppConfig.smallSpace),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          title,
                                          overflow: TextOverflow.ellipsis,
                                          style: textTheme.titleLarge,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          description,
                                          style: textTheme.bodyMedium,
                                        ),
                                        if (countdownText.isNotEmpty &&
                                            !canPlay)
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(top: 4.0),
                                            child: Text(
                                              countdownText,
                                              style: const TextStyle(
                                                color: AppColors.redSports,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )),
                  ],
                ));
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(child: Text(AppLocalizations.of(context)!.error_loading_live_e(e.toString()))),
    );
  }
}
