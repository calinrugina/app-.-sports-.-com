import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../config/providers/config_provider.dart';
import '../../../core/network/media_headers.dart';
import '../../media/presentation/video_player_dialog.dart';

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
        const SnackBar(content: Text('URL-ul stream-ului lipsește!')),
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

    return configAsync.when(
      data: (config) {
        if (config == null) {
          return const Center(child: Text('No config loaded'));
        }
        final sports = (config['sports'] as List?) ?? [];
        final List<Map<String, dynamic>> allStreams = [];

        for (final s in sports) {
          final sport = s as Map<String, dynamic>;
          final streams = sport['livestreams'] as List?;
          if (streams != null) {
            for (final st in streams) {
              allStreams.add({
                'sportName': sport['name'],
                ...((st as Map).cast<String, dynamic>()),
              });
            }
          }
        }

        if (allStreams.isEmpty) {
          return const Center(child: Text('No live streams available'));
        }

        return ListView.builder(
          itemCount: allStreams.length,
          itemBuilder: (context, index) {
            final item = allStreams[index];
            final canPlay = _canPlay(item);
            final title = item['title']?.toString() ?? 'Live Stream';
            final description = item['description']?.toString() ?? item['sportName']?.toString() ?? '';
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


            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: InkWell(
                onTap: () {
                  if (canPlay) {
                    _showVideoPlayer(context, item);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Stream-ul va începe la ${countdownText.replaceAll("Start: ", "")}')),
                    );
                  }
                },
                borderRadius: BorderRadius.circular(12),
                child: Card(
                  elevation: 4,
                  clipBehavior: Clip.antiAlias,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
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
                                errorBuilder: (context, error, stackTrace) =>
                                const Center(child: Icon(Icons.live_tv, size: 50, color: Colors.grey)),
                              )
                            else
                              Container(
                                color: Colors.black,
                                child: const Center(child: Icon(Icons.live_tv, size: 50, color: Colors.white)),
                              ),

                            // 2. Overlay (Gradient și Buton)
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [Colors.black.withOpacity(0.1), Colors.black.withOpacity(0.5)],
                                ),
                              ),
                            ),

                            // 3. Iconița Play/Ceas (Centrală)
                            Center(
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: canPlay ? Colors.red.withOpacity(0.8) : Colors.black.withOpacity(0.6),
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 3,
                                  ),
                                ),
                                child: Icon(
                                  canPlay ? Icons.play_arrow : Icons.schedule,
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
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: canPlay ? Colors.black : Colors.grey[700],
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              description,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            if (countdownText.isNotEmpty && !canPlay)
                              Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Text(
                                  countdownText,
                                  style: const TextStyle(
                                    color: Colors.red,
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
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(child: Text('Error loading live: $e')),
    );
  }
}