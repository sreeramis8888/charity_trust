import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class YoutubeVideoCard extends StatefulWidget {
  final String videoId;
  final String title;

  const YoutubeVideoCard({
    super.key,
    required this.videoId,
    required this.title,
  });

  @override
  State<YoutubeVideoCard> createState() => _YoutubeVideoCardState();
}

class _YoutubeVideoCardState extends State<YoutubeVideoCard> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();

    _controller = YoutubePlayerController(
      initialVideoId: widget.videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: false,
        loop: false,disableDragSeek: true,
        mute: false,
        controlsVisibleAtStart: true,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: YoutubePlayerBuilder(
        player: YoutubePlayer(
          controller: _controller,
          showVideoProgressIndicator: true,
          aspectRatio: 16 / 9,
        ),
        builder: (context, player) {
          return player;
        },
      ),
    );
  }
}

String? extractYouTubeVideoId(String url) {
  final uri = Uri.tryParse(url);
  if (uri == null || uri.host.isEmpty) return null;

  final host = uri.host.replaceFirst('www.', '');

  // Handle: https://www.youtube.com/watch?v=VIDEO_ID
  if (host.contains('youtube.com') && uri.path == '/watch') {
    return uri.queryParameters['v'];
  }

  // Handle: https://youtu.be/VIDEO_ID
  if (host.contains('youtu.be')) {
    return uri.pathSegments.isNotEmpty ? uri.pathSegments.first : null;
  }

  // Handle: https://www.youtube.com/embed/VIDEO_ID
  if (host.contains('youtube.com') &&
      uri.pathSegments.isNotEmpty &&
      uri.pathSegments.first == 'embed') {
    return uri.pathSegments.length > 1 ? uri.pathSegments[1] : null;
  }

  // Handle: https://www.youtube.com/shorts/VIDEO_ID
  if (host.contains('youtube.com') &&
      uri.pathSegments.isNotEmpty &&
      uri.pathSegments.first == 'shorts') {
    return uri.pathSegments.length > 1 ? uri.pathSegments[1] : null;
  }

  return null;
}
