import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/network/media_headers.dart';
import '../../../core/theme/colors.dart';
import '../../../core/widgets/section_header.dart';
import '../../media/presentation/video_list_for_mpids.dart';

class StudioScreen extends StatefulWidget {
  final List<dynamic> menuAreas;
  final String languageCode;

  const StudioScreen({
    super.key,
    required this.menuAreas,
    required this.languageCode,
  });

  @override
  State<StudioScreen> createState() => _StudioScreenState();
}

class _StudioScreenState extends State<StudioScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic>? studiosArea;

    for (final area in widget.menuAreas) {
      final m = area as Map<String, dynamic>;
      if (m['name']?.toString() == 'Sports Studios') {
        studiosArea = m;
        break;
      }
    }

    if (studiosArea == null) {
      return const Center(child: Text('No Sports Studios configured'));
    }

    final areas = studiosArea['areas'] as List? ?? [];

    if (areas.isEmpty) {
      return const Center(child: Text('No studios areas available'));
    }

    if (_selectedIndex >= areas.length) {
      _selectedIndex = 0;
    }

    final selectedArea = areas[_selectedIndex] as Map<String, dynamic>;
    final String selectedName = selectedArea['name']?.toString() ?? '';
    final String? selectedMpids =
        (selectedArea['mpids'] ?? selectedArea['mpid'])?.toString();

    return Column(
      children: [
        // carusel cu toate studiourile, similar cu bara de sporturi
        Container(
          color: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: SizedBox(
            height: 80,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: areas.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final area = areas[index] as Map<String, dynamic>;
                final name = area['name']?.toString() ?? '';
                final iconUrl = area['icon']?.toString();
                final isSelected = index == _selectedIndex;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedIndex = index;
                    });
                  },
                  child: Container(
                    width: 90,
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.red : Colors.black,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 6),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (iconUrl != null && iconUrl.isNotEmpty)
                          SizedBox(
                            height: 28,
                            child: SvgPicture.network(
                              iconUrl,
                              headers: mediaHeaders,
                              colorFilter: const ColorFilter.mode(
                                Colors.white,
                                BlendMode.srcIn,
                              ),
                            ),
                          )
                        else
                          const Icon(
                            Icons.tv,
                            color: Colors.white,
                            size: 22,
                          ),
                        const SizedBox(height: 4),
                        Text(
                          name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: SectionHeader(title: selectedName),
              ),
              SliverToBoxAdapter(
                child: selectedMpids != null &&
                        selectedMpids.trim().isNotEmpty
                    ? VideoListForMpids(
                        mpids: selectedMpids,
                        languageCode: widget.languageCode,
                      )
                    : const Padding(
                        padding: EdgeInsets.all(16),
                        child: Text('No videos configured for this studio.'),
                      ),
              ),
              const SliverToBoxAdapter(
                child: SizedBox(height: 24),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
