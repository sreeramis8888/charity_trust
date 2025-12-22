import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Annujoom/src/data/constants/color_constants.dart';
import 'package:Annujoom/src/data/constants/style_constants.dart';
import 'package:Annujoom/src/data/models/promotions_model.dart';
import 'package:Annujoom/src/data/providers/promotions_provider.dart';
import 'package:Annujoom/src/interfaces/components/loading_indicator.dart';
import 'package:Annujoom/src/interfaces/components/cards/video_card.dart';

class VideosPage extends ConsumerWidget {
  const VideosPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final videosAsync = ref.watch(
      promotionsListProvider(type: 'video'),
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: kTextColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Videos',
          style: kHeadTitleSB.copyWith(fontSize: 18),
        ),
        centerTitle: false,
      ),
      body: videosAsync.when(
        data: (data) {
          final videos = _parseVideos(data);
          if (videos.isEmpty) {
            return Center(
              child: Text(
                'No videos available',
                style: kBodyTitleR.copyWith(color: kSecondaryTextColor),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: videos.length,
            itemBuilder: (context, index) {
              final video = videos[index];
              final videoId = extractYouTubeVideoId(video.link ?? '');
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: videoId != null
                    ? YoutubeVideoCard(
                        videoId: videoId,

                      )
                    : Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.grey[300],
                        ),
                        height: 200,
                        child: const Center(
                          child: Text('Invalid video link'),
                        ),
                      ),
              );
            },
          );
        },
        loading: () => Center(
          child: LoadingAnimation(),
        ),
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Error loading videos',
                style: kBodyTitleR.copyWith(color: kSecondaryTextColor),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref
                      .read(promotionsListProvider(type: 'video')
                          .notifier)
                      .refresh();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Promotions> _parseVideos(Map<String, dynamic> data) {
    try {
      final videosList = data['data'] as List?;
      if (videosList == null) return [];
      return videosList
          .map((item) => Promotions.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }
}
