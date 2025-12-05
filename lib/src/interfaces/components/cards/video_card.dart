  import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

Widget youtubeVideoCard({
    required String videoId,
    required String title,
  }) {
    final ytController = YoutubePlayerController(
      initialVideoId: videoId,
      flags: const YoutubePlayerFlags(
        disableDragSeek: true,
        autoPlay: false,
        loop: true,
        mute: false,
        controlsVisibleAtStart: true,
        enableCaption: true,
        isLive: false,
      ),
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: YoutubePlayer(
        controller: ytController,
        showVideoProgressIndicator: true,
        aspectRatio: 16 / 9,
      ),
    );
  }