import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/providers/config_provider.dart';
import '../../../core/network/media_headers.dart';

class LiveScreen extends ConsumerWidget {
  const LiveScreen({super.key});

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
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                leading: item['thumbnail_url'] != null
                    ? Image.network(
                        item['thumbnail_url'],
                        width: 80,
                        fit: BoxFit.cover,
                        headers: mediaHeaders,
                      )
                    : const Icon(Icons.live_tv),
                title: Text(item['title']?.toString() ?? 'Live stream'),
                subtitle: Text(
                  item['description']?.toString() ??
                      (item['sportName']?.toString() ?? ''),
                ),
                trailing: const Icon(Icons.play_arrow),
                onTap: () {
                  // TODO: navigate to a real live player screen
                },
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
